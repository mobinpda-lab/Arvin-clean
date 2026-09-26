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

require(build, "branches: [main, master]", str(build_path))
require(build, 'types: [opened, synchronize, reopened]', str(build_path))
require(build, '# Draft PRs are valid product work and must receive real quality/build evidence.', str(build_path))
require(build, 'quality:', str(build_path))
require(build, 'apk:', str(build_path))
forbid(build, 'needs: quality', str(build_path))
require(build, 'lane: [analyze, test-0, test-1, test-2, test-3]', str(build_path))
require(build, 'flutter test --total-shards 4 --shard-index', str(build_path))
forbid(build, 'run: flutter test\n', str(build_path))
require(build, 'variant: [release, debug]', str(build_path))
require(build, '- name: Android V2 audit', str(build_path))
require(build, '- name: Build APK', str(build_path))
require(build, 'flutter build apk --${{ matrix.variant }}', str(build_path))
require(build, 'arvin-${{ matrix.variant }}-apk', str(build_path))
forbid(build, '- name: Build release APK', str(build_path))
forbid(build, '- name: Build debug APK', str(build_path))

require(parallel, "'wave/**'", str(parallel_path))
require(parallel, "'ci/**'", str(parallel_path))
for forbidden_push_branch in ("'feat/**'", "'fix/**'", "'test/**'"):
    if forbidden_push_branch in parallel:
        raise SystemExit(f'{parallel_path} must not validate normal PR branches twice: {forbidden_push_branch}')
require(parallel, 'contract:', str(parallel_path))
require(parallel, 'surface:', str(parallel_path))
require(parallel, 'flutter test', str(parallel_path))
forbid(parallel, 'jobs:\n  quality:', str(parallel_path))
forbid(parallel, 'flutter analyze --no-fatal-infos', str(parallel_path))
forbid(parallel, 'android-release:', str(parallel_path))
forbid(parallel, '- name: Build release APK', str(parallel_path))

require(device, "branches: [main, master]", str(device_path))
require(device, 'types: [opened, synchronize, reopened, ready_for_review]', str(device_path))
require(device, 'workflow_dispatch:', str(device_path))
require(device, "if: github.event_name != 'pull_request' || github.event.pull_request.draft == false", str(device_path))
require(device, 'integration_test/android_home_smoke_test.dart', str(device_path))
require(device, 'integration_test/android_people_smoke_test.dart', str(device_path))
require(device, 'max-parallel: 4', str(device_path))
forbidden_device_parallel = 'max-parallel: 1'
forbid(device, forbidden_device_parallel, str(device_path))

print('Arvin Fast Lane workflow contract: OK')
