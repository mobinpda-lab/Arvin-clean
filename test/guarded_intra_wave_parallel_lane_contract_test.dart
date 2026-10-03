import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guarded intra-wave lane is explicit opt-in and fail-closed', () {
    final workflow = File(
      '.github/workflows/arvin-intra-wave-parallel-lane.yml',
    ).readAsStringSync();

    expect(workflow, contains('enable_parallel:'));
    expect(workflow, contains('default: false'));
    expect(workflow, contains(r'test "$ENABLE_PARALLEL" = "true"'));
    expect(workflow, contains('factory:parallel-approved'));
    expect(workflow, contains('EXPECTED_MAIN_SHA'));
    expect(workflow, contains(r'test "$actual" = "$EXPECTED_MAIN_SHA"'));
    expect(workflow, contains('ARVIN RECOVERY WAVE'));
    expect(workflow, contains('factory:leased'));
    expect(workflow, contains('factory:in-progress'));
    expect(workflow, contains('fail-fast: false'));
    expect(workflow, contains('matrix:'));
    expect(
      workflow,
      contains('area: [followup, calendar, backup, typography, guide, release]'),
    );
  });
}
