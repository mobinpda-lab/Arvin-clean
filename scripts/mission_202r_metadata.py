#!/usr/bin/env python3
"""Generate and validate mission 202-R metadata and the canonical JSONL trace lifecycle."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
import tempfile
import unittest
from datetime import datetime
from pathlib import Path
from typing import Any

REQUIRED = (
    "mission_id", "repository", "branch", "commit_sha",
    "workflow_run_id", "run_attempt", "trace_file", "trace_sha256",
)
TRACE_REQUIRED = (
    "timestamp", "event", "operation_id", "parent_operation_id",
    "correlation_id", "operation_name", "elapsed_ms", "status", "error_type",
)
EVENTS = {"START", "END", "ERROR"}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _validate_identity(values: dict[str, Any]) -> None:
    if values.get("repository") != "mobinpda-lab/Arvin-clean":
        raise ValueError("repository identity mismatch")
    if not isinstance(values.get("branch"), str) or not values["branch"]:
        raise ValueError("branch identity is invalid")
    if not isinstance(values.get("commit_sha"), str) or not re.fullmatch(r"[0-9a-f]{40}", values["commit_sha"]):
        raise ValueError("commit SHA is invalid")
    run_id = values.get("workflow_run_id")
    if not isinstance(run_id, str) or not run_id.isdigit():
        raise ValueError("workflow Run ID is invalid")
    attempt = values.get("run_attempt")
    if not isinstance(attempt, int) or isinstance(attempt, bool) or attempt < 1:
        raise ValueError("Run Attempt is invalid")


def write_metadata(trace_path: Path, metadata_path: Path, values: dict[str, Any]) -> dict[str, Any]:
    if not trace_path.is_file():
        raise ValueError("required trace file is missing")
    normalized = {**values, "run_attempt": int(values["run_attempt"])}
    _validate_identity(normalized)
    data = {
        "mission_id": "202-R",
        "repository": normalized["repository"],
        "branch": normalized["branch"],
        "commit_sha": normalized["commit_sha"],
        "workflow_run_id": normalized["workflow_run_id"],
        "run_attempt": normalized["run_attempt"],
        "trace_file": trace_path.name,
        "trace_sha256": sha256_file(trace_path),
    }
    metadata_path.parent.mkdir(parents=True, exist_ok=True)
    metadata_path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return data


def _read_trace(trace_path: Path) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    try:
        lines = trace_path.read_text(encoding="utf-8").splitlines()
    except UnicodeDecodeError as exc:
        raise ValueError("JSONL trace is not valid UTF-8") from exc
    if not lines:
        raise ValueError("JSONL trace is empty")
    for number, line in enumerate(lines, 1):
        if not line.strip():
            raise ValueError(f"invalid JSONL record at line {number}: blank line")
        try:
            record = json.loads(line)
        except json.JSONDecodeError as exc:
            raise ValueError(f"invalid JSONL record at line {number}") from exc
        if not isinstance(record, dict):
            raise ValueError(f"invalid JSONL record at line {number}: object required")
        records.append(record)
    return records


def _validate_trace_schema(records: list[dict[str, Any]]) -> None:
    opened: dict[str, dict[str, Any]] = {}
    seen: set[str] = set()
    for number, record in enumerate(records, 1):
        missing = [field for field in TRACE_REQUIRED if field not in record]
        if missing:
            raise ValueError(f"invalid trace fields at line {number}: missing {','.join(missing)}")
        event = record["event"]
        if not isinstance(event, str) or event not in EVENTS or ("event_type" in record and record["event_type"] != event):
            raise ValueError(f"invalid event type at line {number}")
        timestamp = record["timestamp"]
        if not isinstance(timestamp, str) or not timestamp:
            raise ValueError(f"invalid timestamp at line {number}")
        try:
            datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
        except ValueError as exc:
            raise ValueError(f"invalid timestamp at line {number}") from exc
        operation_id = record["operation_id"]
        correlation_id = record["correlation_id"]
        operation_name = record["operation_name"]
        if not isinstance(operation_id, str) or not operation_id:
            raise ValueError(f"invalid operation ID at line {number}")
        if not isinstance(correlation_id, str) or not correlation_id:
            raise ValueError(f"invalid correlation ID at line {number}")
        if not isinstance(operation_name, str) or not operation_name:
            raise ValueError(f"invalid operation name at line {number}")
        elapsed = record["elapsed_ms"]
        if not isinstance(elapsed, int) or isinstance(elapsed, bool) or elapsed < 0:
            raise ValueError(f"invalid elapsed_ms at line {number}")
        status = record["status"]
        expected_status = {"START": "RUNNING", "END": "SUCCESS", "ERROR": "ERROR"}[event]
        if status != expected_status:
            raise ValueError(f"invalid event fields/status at line {number}")
        error_type = record["error_type"]
        if (event == "ERROR" and (not isinstance(error_type, str) or not error_type)) or (event != "ERROR" and error_type is not None):
            raise ValueError(f"invalid event fields/error_type at line {number}")
        if event == "START":
            if operation_id in seen:
                raise ValueError(f"duplicate operation or START: {operation_id}")
            parent_id = record["parent_operation_id"]
            if parent_id is not None:
                if not isinstance(parent_id, str) or not parent_id or parent_id not in opened:
                    raise ValueError(f"invalid parent operation at line {number}")
                if opened[parent_id]["correlation_id"] != correlation_id:
                    raise ValueError(f"invalid correlation ID at line {number}")
            seen.add(operation_id)
            opened[operation_id] = record
        else:
            if operation_id not in opened:
                raise ValueError(f"invalid lifecycle terminal without START: {operation_id}")
            start_record = opened[operation_id]
            if start_record["operation_name"] != operation_name:
                raise ValueError(f"invalid lifecycle operation name: {operation_id}")
            if start_record["correlation_id"] != correlation_id:
                raise ValueError(f"invalid correlation ID: {operation_id}")
            if start_record["parent_operation_id"] != record["parent_operation_id"]:
                raise ValueError(f"invalid parent operation: {operation_id}")
            del opened[operation_id]
    if opened:
        raise ValueError("invalid lifecycle: operation missing END or ERROR")


def validate(trace_path: Path, metadata_path: Path, expected: dict[str, Any]) -> dict[str, Any]:
    if not trace_path.is_file() or not metadata_path.is_file():
        raise ValueError("required trace or metadata file is missing")
    try:
        data = json.loads(metadata_path.read_text(encoding="utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise ValueError("metadata JSON is malformed") from exc
    if not isinstance(data, dict) or any(key not in data for key in REQUIRED):
        raise ValueError("required metadata field is absent")
    if data["mission_id"] != "202-R":
        raise ValueError("mission identity mismatch")
    if data["repository"] != expected["repository"]:
        raise ValueError("repository identity mismatch")
    if data["branch"] != expected["branch"]:
        raise ValueError("branch identity mismatch")
    if data["commit_sha"] != expected["commit_sha"]:
        raise ValueError("commit SHA mismatch")
    if data["workflow_run_id"] != expected["workflow_run_id"]:
        raise ValueError("workflow Run ID mismatch")
    if data["run_attempt"] != expected["run_attempt"]:
        raise ValueError("Run Attempt mismatch")
    _validate_identity(data)
    if data["trace_file"] != trace_path.name:
        raise ValueError("trace filename mismatch")
    if not isinstance(data["trace_sha256"], str) or not re.fullmatch(r"[0-9a-f]{64}", data["trace_sha256"]):
        raise ValueError("trace SHA-256 field is invalid")
    if sha256_file(trace_path) != data["trace_sha256"]:
        raise ValueError("trace SHA-256 digest mismatch")
    _validate_trace_schema(_read_trace(trace_path))
    return data


class MetadataContractTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.trace = self.root / "arvin-async-trace.jsonl"
        self.meta = self.root / "metadata.json"
        self.expected = {
            "repository": "mobinpda-lab/Arvin-clean",
            "branch": "recovery-02/main-based-integration",
            "commit_sha": "a" * 40,
            "workflow_run_id": "123456789",
            "run_attempt": 1,
        }
        self._write_records(self._simple_records())
        write_metadata(self.trace, self.meta, self.expected)

    def tearDown(self) -> None:
        self.tmp.cleanup()

    @staticmethod
    def _event(event: str, op: str = "op-1", parent: str | None = None,
               correlation: str = "corr-1") -> dict[str, Any]:
        return {
            "timestamp": "2026-11-24T08:00:00Z", "event": event,
            "event_type": event, "operation_id": op,
            "parent_operation_id": parent, "correlation_id": correlation,
            "operation_name": "fixture.operation", "elapsed_ms": 0,
            "status": {"START": "RUNNING", "END": "SUCCESS", "ERROR": "ERROR"}[event],
            "error_type": None if event != "ERROR" else "StateError",
        }

    def _simple_records(self) -> list[dict[str, Any]]:
        return [self._event("START"), self._event("END")]

    def _write_records(self, records: list[dict[str, Any]]) -> None:
        self.trace.write_text("".join(json.dumps(row) + "\n" for row in records), encoding="utf-8")

    def _rewrite_meta(self, **changes: Any) -> None:
        data = json.loads(self.meta.read_text(encoding="utf-8"))
        data.update(changes)
        self.meta.write_text(json.dumps(data), encoding="utf-8")

    def _reject(self, pattern: str) -> None:
        with self.assertRaisesRegex(ValueError, pattern):
            validate(self.trace, self.meta, self.expected)

    def test_P01_valid_start_end_lifecycle(self) -> None:
        self.assertEqual(validate(self.trace, self.meta, self.expected)["mission_id"], "202-R")

    def test_P02_valid_nested_lifecycle(self) -> None:
        records = [
            self._event("START", "parent"),
            self._event("START", "child", "parent"),
            self._event("END", "child", "parent"),
            self._event("END", "parent"),
        ]
        self._write_records(records)
        write_metadata(self.trace, self.meta, self.expected)
        validate(self.trace, self.meta, self.expected)

    def test_N01_missing_file(self) -> None:
        self.meta.unlink()
        self._reject("file is missing")
        write_metadata(self.trace, self.meta, self.expected)
        self.trace.unlink()
        self._reject("file is missing")

    def test_N02_invalid_json(self) -> None:
        self.meta.write_text("{broken", encoding="utf-8")
        self._reject("malformed")

    def test_N03_missing_required_field(self) -> None:
        self._rewrite_meta(trace_file=None)
        data = json.loads(self.meta.read_text())
        del data["trace_file"]
        self.meta.write_text(json.dumps(data))
        self._reject("field is absent")

    def test_N04_wrong_mission(self) -> None:
        self._rewrite_meta(mission_id="189-R")
        self._reject("mission identity")

    def test_N05_wrong_repository(self) -> None:
        self._rewrite_meta(repository="other/repository")
        self._reject("repository identity")

    def test_N06_wrong_branch(self) -> None:
        self._rewrite_meta(branch="main")
        self._reject("branch identity")

    def test_N07_wrong_commit_sha(self) -> None:
        self._rewrite_meta(commit_sha="b" * 40)
        self._reject("commit SHA mismatch")

    def test_N08_wrong_workflow_run_id(self) -> None:
        self._rewrite_meta(workflow_run_id="987654321")
        self._reject("workflow Run ID mismatch")

    def test_N09_wrong_run_attempt(self) -> None:
        self._rewrite_meta(run_attempt=2)
        self._reject("Run Attempt mismatch")

    def test_N10_wrong_trace_filename(self) -> None:
        self._rewrite_meta(trace_file="other.jsonl")
        self._reject("trace filename mismatch")

    def test_N11_actual_sha256_mismatch(self) -> None:
        self.trace.write_text(self.trace.read_text() + "{}\n", encoding="utf-8")
        self._reject("digest mismatch")

    def test_N12_invalid_jsonl_record(self) -> None:
        self.trace.write_text('{"event":"START"}\n{broken\n', encoding="utf-8")
        write_metadata(self.trace, self.meta, self.expected)
        self._reject("invalid JSONL record")

    def test_N13_invalid_event_type_or_fields(self) -> None:
        row = self._event("START")
        row["event"] = "BEGIN"
        self._write_records([row])
        write_metadata(self.trace, self.meta, self.expected)
        self._reject("invalid event type")

    def test_N14_duplicate_operation_or_start(self) -> None:
        self._write_records([self._event("START"), self._event("START")])
        write_metadata(self.trace, self.meta, self.expected)
        self._reject("duplicate operation or START")

    def test_N15_invalid_lifecycle(self) -> None:
        self._write_records([self._event("START")])
        write_metadata(self.trace, self.meta, self.expected)
        self._reject("invalid lifecycle")

    def test_N16_invalid_parent_or_correlation(self) -> None:
        self._write_records([
            self._event("START", "parent"),
            self._event("START", "child", "missing-parent"),
            self._event("END", "child", "missing-parent"),
            self._event("END", "parent"),
        ])
        write_metadata(self.trace, self.meta, self.expected)
        self._reject("invalid parent operation")
        self._write_records([
            self._event("START", "parent"),
            self._event("START", "child", "parent", "wrong-correlation"),
            self._event("END", "child", "parent", "wrong-correlation"),
            self._event("END", "parent"),
        ])
        write_metadata(self.trace, self.meta, self.expected)
        self._reject("invalid correlation ID")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true")
    parser.add_argument("--validate", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--trace-file", type=Path, default=Path("arvin-trace/arvin-async-trace.jsonl"))
    parser.add_argument("--metadata-file", type=Path, default=Path("arvin-trace/metadata.json"))
    parser.add_argument("--repository", default=os.environ.get("GITHUB_REPOSITORY", ""))
    parser.add_argument("--branch", default=os.environ.get("GITHUB_HEAD_REF") or os.environ.get("GITHUB_REF_NAME", ""))
    parser.add_argument("--commit-sha", default=os.environ.get("TARGET_SHA", ""))
    parser.add_argument("--workflow-run-id", default=os.environ.get("GITHUB_RUN_ID", ""))
    parser.add_argument("--run-attempt", default=os.environ.get("GITHUB_RUN_ATTEMPT", ""))
    args = parser.parse_args()
    if args.self_test:
        suite = unittest.defaultTestLoader.loadTestsFromTestCase(MetadataContractTests)
        return 0 if unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful() else 1
    values = {
        "repository": args.repository, "branch": args.branch,
        "commit_sha": args.commit_sha, "workflow_run_id": args.workflow_run_id,
        "run_attempt": args.run_attempt,
    }
    if not all(values.values()):
        raise SystemExit("required GitHub execution identity is unavailable")
    if args.write:
        write_metadata(args.trace_file, args.metadata_file, values)
    if args.validate:
        validate(args.trace_file, args.metadata_file, {**values, "run_attempt": int(args.run_attempt)})
    print("MISSION_202R_METADATA=VALID")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError) as exc:
        print(f"MISSION_202R_METADATA=INVALID: {exc}", file=sys.stderr)
        sys.exit(1)
