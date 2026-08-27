from pathlib import Path


def require(text: str, token: str, source: str) -> None:
    if token not in text:
        raise SystemExit(f"Fast Lane contract missing in {source}: {token}")


def forbid(text: str, token: str, source: str) -> None:
    if token in text:
        raise SystemExit(f"Fast Lane contract forbids in {source}: {token}")


build_path = Path('.github/workflows/build.yml')
parallel_path = Path('.github/workflows/parallel-wave.yml')
device_path = Path('.github/workflows/device-smoke.yml')

build = build_path.read_text(encoding='utf-8')
parallel = parallel_path.read_text(encoding='utf-8')
device = device_path.read_text(encoding='utf-8')

require(build, "branches: [main, master, 'gate/**']", str(build_path))
require(build, 'types: [opened, synchronize, reopened, ready_for_review]', str(build_path))
require(build, "if: github.event_name != 'pull_request' || github.event.pull_request.draft == false", str(build_path))
require(build, '- name: Android V2 audit', str(build_path))
require(build, '- name: Build release APK', str(build_path))
require(build, '- name: Build debug APK', str(build_path))

# Automation branches keep push validation; normal product branches must use one PR path.
require(parallel, "'wave/**'", str(parallel_path))
require(parallel, "'ci/**'", str(parallel_path))
for forbidden_push_branch in ("'feat/**'", "'fix/**'", "'test/**'"):
    if forbidden_push_branch in parallel:
        raise SystemExit(
            f'{parallel_path} must not validate normal PR branches twice: '
            f'{forbidden_push_branch}'
        )
require(parallel, 'quality:', str(parallel_path))
require(parallel, 'surface:', str(parallel_path))
require(parallel, 'flutter analyze --no-fatal-infos', str(parallel_path))
require(parallel, 'flutter test', str(parallel_path))
forbid(parallel, 'android-release:', str(parallel_path))
forbid(parallel, '- name: Build release APK', str(parallel_path))

# Device Smoke has a deterministic exact-ref lane for automation/API-driven delivery.
require(device, "branches: [main, master, 'device/**']", str(device_path))
require(device, 'types: [opened, synchronize, reopened, ready_for_review]', str(device_path))
require(device, 'workflow_dispatch:', str(device_path))
require(device, "if: github.event_name != 'pull_request' || github.event.pull_request.draft == false", str(device_path))
require(device, 'integration_test/android_home_smoke_test.dart', str(device_path))

print('Arvin Fast Lane workflow contract: OK')
