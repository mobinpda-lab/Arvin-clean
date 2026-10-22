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
require(build, 'lane: [analyze, test-0, test-1, test-2, test-3, test-4, test-5]', str(build_path))
require(build, 'flutter test --total-shards 6 --shard-index', str(build_path))
forbid(build, 'run: flutter test\\n', str(build_path))
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
forbid(parallel, 'surface:', str(parallel_path))
forbid(parallel, 'flutter test', str(parallel_path))
forbid(parallel, 'jobs:\n  quality:', str(parallel_path))
forbid(parallel, 'flutter analyze --no-fatal-infos', str(parallel_path))
forbid(parallel, 'android-release:', str(parallel_path))
forbid(parallel, '- name: Build release APK', str(parallel_path))

# Device Smoke must cover PRs targeting integration branches and Draft PRs too.
device_pull_request = device.split("  pull_request:\n", 1)[1].split("  workflow_dispatch:", 1)[0]
forbid(device_pull_request, "branches: [main, master]", str(device_path) + " pull_request")
require(device, 'types: [opened, synchronize, reopened, ready_for_review]', str(device_path))
require(device, 'workflow_dispatch:', str(device_path))
require(device, '# Validate PRs targeting integration branches too; product code can live there before main integration.', str(device_path))
require(device, '# Draft PRs need CI evidence before they are marked ready; this job never promotes or merges.', str(device_path))
forbid(device, "if: github.event_name != 'pull_request' || github.event.pull_request.draft == false", str(device_path))
# Device Smoke must retain every canonical scenario mapping whether the
# workflow uses a static YAML matrix or a generated JSON include matrix.
canonical_scenarios = {
    'home': 'integration_test/android_home_smoke_test.dart',
    'quick-capture': 'integration_test/android_quick_capture_smoke_test.dart',
    'sql-persistence': 'integration_test/android_sql_persistence_smoke_test.dart',
    'sql-migration': 'integration_test/android_upgrade_migration_smoke_test.dart',
    'backup-restore': 'integration_test/android_backup_restore_sql_smoke_test.dart',
    'people': 'integration_test/android_people_smoke_test.dart',
    'calendar': 'integration_test/calendar_card_interaction_test.dart',
}
for scenario, test_file in canonical_scenarios.items():
    static_mapping = f'scenario: {scenario}' in device and f'test_file: {test_file}' in device
    dynamic_mapping = f'"scenario":"{scenario}","test_file":"{test_file}"' in device
    if not (static_mapping or dynamic_mapping):
        raise SystemExit(
            f'Fast Lane contract missing in {device_path}: '
            f'{scenario} -> {test_file}'
        )

# Exact-SHA manual dispatch must be fail-closed before the emulator/test step.
for token in (
    'target_sha:',
    'run_calendar:',
    'run_sql_persistence:',
    'run_sql_migration:',
    'RUN_SQL_MIGRATION: ${{ inputs.run_sql_migration }}',
    'ref: ${{ github.event_name == \'workflow_dispatch\' && inputs.target_sha || github.sha }}',
    'name: Record and verify checkout revision',
    'actual="$(git rev-parse HEAD)"',
    'echo "CHECKOUT_SHA=$actual"',
    'echo "EXACT_TARGET_SHA=$actual"',
    'CHECKOUT SHA mismatch: expected $TARGET_SHA, got $actual',
):
    require(device, token, str(device_path))
require(device, 'if [ "$actual" != "$TARGET_SHA" ]; then', str(device_path))
require(device, 'exit 1', str(device_path))

require(device, 'max-parallel: 2', str(device_path))
require(device, 'flutter drive --driver=test_driver/integration_test.dart', str(device_path))
forbid(device, 'adb exec-out screencap -p', str(device_path))
driver_path = Path('test_driver/integration_test.dart')
if not driver_path.is_file():
    raise SystemExit(f'Fast Lane screenshot driver missing: {driver_path}')
driver = driver_path.read_text(encoding='utf-8')
require(driver, 'integrationDriver(', str(driver_path))
require(driver, 'onScreenshot:', str(driver_path))
require(driver, 'artifacts/device-smoke/$screenshotName.png', str(driver_path))
forbidden_device_parallel = 'max-parallel: 1'
forbid(device, forbidden_device_parallel, str(device_path))

print('Arvin Fast Lane workflow contract: OK')
