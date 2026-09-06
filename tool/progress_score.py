#!/usr/bin/env python3
import argparse
import json
import re
from pathlib import Path

EXTENSION_SCORECARD = Path('docs/progress_scorecard.json')
PROJECT_SCORECARD = Path('docs/project_completion_scorecard.json')
EXPECTED_FEATURE_IDS = set(range(1, 20))
EXPECTED_GATE_IDS = set('ABCDEFGH')
ALLOWED_STAGES = {0, 10, 25, 40, 55, 70, 85, 100}
WAVE_X1 = {1, 2, 3, 6, 7, 10, 11, 17}
SHA_RE = re.compile(r'^[0-9a-f]{40}$')


def rounded_percent(points: int, maximum: int) -> float:
    return round(points / maximum * 100, 1)


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding='utf-8'))


EVIDENCE_STATUSES = {'PASS', 'FAIL', 'BLOCKED'}


def _validate_main_sha(main_sha: str) -> None:
    if not isinstance(main_sha, str) or not SHA_RE.fullmatch(main_sha):
        raise ValueError('current main SHA must be a full 40-character commit SHA')


def _evidence_status(main_sha: str, evidence: dict | None) -> str:
    if evidence is None:
        return 'BLOCKED'
    if not isinstance(evidence, dict):
        raise ValueError('gate evidence must be an object')

    status = evidence.get('status')
    if status not in EVIDENCE_STATUSES:
        raise ValueError(
            f"gate evidence status must be one of {sorted(EVIDENCE_STATUSES)}"
        )

    evidence_sha = evidence.get('sha')
    if not isinstance(evidence_sha, str) or not SHA_RE.fullmatch(evidence_sha):
        return 'BLOCKED'
    if evidence_sha != main_sha:
        return 'BLOCKED'
    return status


def render_dashboard(
    current_main_sha: str,
    gate_evidence: dict,
    project_path: Path = PROJECT_SCORECARD,
    extension_path: Path = EXTENSION_SCORECARD,
) -> str:
    """Render scorecards and exact-main gate evidence without network access."""
    _validate_main_sha(current_main_sha)
    if not isinstance(gate_evidence, dict):
        raise ValueError('gate evidence must be an object keyed by gate ID')

    project_data = load_json(project_path)
    extension_data = load_json(extension_path)
    project = validate_project(project_data)
    extension = validate_extension(extension_data)

    unknown_gates = set(gate_evidence) - EXPECTED_GATE_IDS
    if unknown_gates:
        raise ValueError(f'unknown gate evidence: {sorted(unknown_gates)}')

    lines = [
        '# Arvin progress dashboard',
        '',
        f'Current main: `{current_main_sha}`',
        '',
        '## Whole-project completion',
        '',
        f"**{project['total_percent']:.1f}%** — 8 canonical delivery gates",
        '',
        '| Gate | Scorecard stage | Evidence |',
        '| --- | ---: | --- |',
    ]
    gates_by_id = {gate['id']: gate for gate in project_data['gates']}
    for gate_id in sorted(EXPECTED_GATE_IDS):
        gate = gates_by_id[gate_id]
        status = _evidence_status(current_main_sha, gate_evidence.get(gate_id))
        lines.append(f"| {gate_id} | {gate['stage']}% | {status} |")

    lines.extend(
        [
            '',
            '## 19-feature extension',
            '',
            f"**{extension['overall_percent']:.1f}%** — 19-feature extension roadmap",
            '',
            f"Wave X1: **{extension['wave_x1_percent']:.1f}%**",
            '',
            'The whole-project and 19-feature extension metrics are separate '
            'scorecard calculations.',
            '',
        ]
    )
    return '\n'.join(lines)


def validate_allowed_stages(data: dict, label: str, errors: list[str]) -> None:
    declared = set(data.get('allowed_stages', []))
    if declared != ALLOWED_STAGES:
        errors.append(
            f'{label}.allowed_stages must be {sorted(ALLOWED_STAGES)}, '
            f'found {sorted(declared)}'
        )


def validate_baseline_sha(data: dict, label: str, errors: list[str]) -> None:
    sha = data.get('baseline_main_sha')
    if not isinstance(sha, str) or not SHA_RE.fullmatch(sha):
        errors.append(f'{label}.baseline_main_sha must be a full 40-char commit SHA')


def validate_extension(data: dict) -> dict:
    errors: list[str] = []
    features = data.get('features', [])
    ids = [feature.get('id') for feature in features]

    if len(features) != 19:
        errors.append(f'extension: expected 19 features, found {len(features)}')
    if set(ids) != EXPECTED_FEATURE_IDS:
        errors.append(
            f'extension: feature ids must be exactly 1..19, found {sorted(set(ids))}'
        )
    if len(ids) != len(set(ids)):
        errors.append('extension: feature ids must be unique')

    for feature in features:
        stage = feature.get('stage')
        if stage not in ALLOWED_STAGES:
            errors.append(
                f"extension: feature {feature.get('id')} has invalid stage {stage}; "
                f'allowed={sorted(ALLOWED_STAGES)}'
            )
        evidence = feature.get('evidence')
        if stage and (not isinstance(evidence, list) or not evidence):
            errors.append(
                f"extension: feature {feature.get('id')} has progress credit but no evidence"
            )

    points = sum(feature.get('stage', 0) for feature in features)
    x1_points = sum(
        feature.get('stage', 0)
        for feature in features
        if feature.get('id') in WAVE_X1
    )
    calculated = {
        'overall_percent': rounded_percent(points, 19 * 100),
        'wave_x1_percent': rounded_percent(x1_points, len(WAVE_X1) * 100),
        'features_at_core_or_better': sum(
            1 for feature in features if feature.get('stage', 0) >= 40
        ),
        'features_started': sum(
            1 for feature in features if feature.get('stage', 0) > 0
        ),
        'features_done': sum(
            1 for feature in features if feature.get('stage', 0) == 100
        ),
    }

    reported = data.get('reported_metrics', {})
    for key, value in calculated.items():
        if reported.get(key) != value:
            errors.append(
                f'extension.reported_metrics.{key}={reported.get(key)!r} '
                f'does not match calculated value {value!r}'
            )

    validate_allowed_stages(data, 'extension', errors)
    validate_baseline_sha(data, 'extension', errors)

    declared_x1 = set(data.get('wave_x1_feature_ids', []))
    if declared_x1 != WAVE_X1:
        errors.append(
            f'extension.wave_x1_feature_ids must be {sorted(WAVE_X1)}, '
            f'found {sorted(declared_x1)}'
        )

    if errors:
        raise SystemExit(
            'Extension progress scorecard validation failed:\n- ' + '\n- '.join(errors)
        )

    return calculated


def validate_project(data: dict) -> dict:
    errors: list[str] = []
    gates = data.get('gates', [])
    ids = [gate.get('id') for gate in gates]

    if len(gates) != 8:
        errors.append(f'project: expected 8 gates, found {len(gates)}')
    if set(ids) != EXPECTED_GATE_IDS:
        errors.append(
            f'project: gate ids must be exactly A..H, found {sorted(set(ids))}'
        )
    if len(ids) != len(set(ids)):
        errors.append('project: gate ids must be unique')

    for gate in gates:
        stage = gate.get('stage')
        if stage not in ALLOWED_STAGES:
            errors.append(
                f"project: gate {gate.get('id')} has invalid stage {stage}; "
                f'allowed={sorted(ALLOWED_STAGES)}'
            )
        evidence = gate.get('evidence')
        if stage and (not isinstance(evidence, list) or not evidence):
            errors.append(
                f"project: gate {gate.get('id')} has progress credit but no evidence"
            )
        note = gate.get('note')
        if not isinstance(note, str) or not note.strip():
            errors.append(f"project: gate {gate.get('id')} must explain its current stage")

    points = sum(gate.get('stage', 0) for gate in gates)
    calculated = {
        'total_percent': rounded_percent(points, 8 * 100),
        'gates_started': sum(1 for gate in gates if gate.get('stage', 0) > 0),
        'gates_core_or_better': sum(
            1 for gate in gates if gate.get('stage', 0) >= 40
        ),
        'gates_integrated_or_better': sum(
            1 for gate in gates if gate.get('stage', 0) >= 55
        ),
        'gates_done': sum(1 for gate in gates if gate.get('stage', 0) == 100),
    }

    reported = data.get('reported_metrics', {})
    for key, value in calculated.items():
        if reported.get(key) != value:
            errors.append(
                f'project.reported_metrics.{key}={reported.get(key)!r} '
                f'does not match calculated value {value!r}'
            )

    validate_allowed_stages(data, 'project', errors)
    validate_baseline_sha(data, 'project', errors)

    if data.get('source_roadmap') != 'docs/PROJECT_ROADMAP_2026-08-14.md':
        errors.append(
            'project.source_roadmap must remain docs/PROJECT_ROADMAP_2026-08-14.md '
            'unless the denominator is changed by an explicit governance update'
        )

    if errors:
        raise SystemExit(
            'Total project scorecard validation failed:\n- ' + '\n- '.join(errors)
        )

    return calculated


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--check',
        action='store_true',
        help='validate the committed whole-project and extension scorecards',
    )
    parser.add_argument(
        '--render',
        action='store_true',
        help='render a deterministic Markdown dashboard from exact-main evidence',
    )
    parser.add_argument(
        '--main-sha',
        help='current main commit SHA used to validate supplied evidence',
    )
    parser.add_argument(
        '--evidence-file',
        type=Path,
        help='JSON object keyed by gate ID with status and sha fields',
    )
    args = parser.parse_args()

    if args.render:
        if args.main_sha is None or args.evidence_file is None:
            parser.error('--render requires --main-sha and --evidence-file')
        evidence = load_json(args.evidence_file)
        print(render_dashboard(args.main_sha, evidence))
        return

    project = validate_project(load_json(PROJECT_SCORECARD))
    extension = validate_extension(load_json(EXTENSION_SCORECARD))

    print(f"Arvin TOTAL project completion: {project['total_percent']:.1f}%")
    print(
        'Project gates: '
        f"started={project['gates_started']}/8, "
        f"core+={project['gates_core_or_better']}/8, "
        f"integrated+={project['gates_integrated_or_better']}/8, "
        f"done={project['gates_done']}/8"
    )
    print(f"19-feature extension roadmap: {extension['overall_percent']:.1f}%")
    print(f"Wave X1 extension progress: {extension['wave_x1_percent']:.1f}%")
    print(
        'Extension features: '
        f"started={extension['features_started']}/19, "
        f"core+={extension['features_at_core_or_better']}/19, "
        f"done={extension['features_done']}/19"
    )

    if args.check:
        print('Official progress validation: OK')


if __name__ == '__main__':
    main()
