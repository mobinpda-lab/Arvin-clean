import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Wave 0 recovery authority keeps every owner requirement discoverable', () {
    final audit = File('docs/ARVIN_RECOVERY_WAVE0_EXACT_MAIN_AUDIT_2026-09-12.md')
        .readAsStringSync();
    final ui = File('docs/ARVIN_UI_CANONICAL.md').readAsStringSync();
    final authority = File('docs/DOCUMENT_AUTHORITY_INDEX.md').readAsStringSync();
    final execution =
        File('docs/ARVIN_RECOVERY_WAVE_EXECUTION_2026-09-12.md')
            .readAsStringSync();

    expect(audit, contains('Parent ledger: #845'));
    for (var issue = 846; issue <= 853; issue++) {
      expect(audit, contains('#$issue'), reason: 'Wave issue #$issue must remain mapped');
      expect(execution, contains('#$issue'),
          reason: 'Execution map must retain Wave #$issue');
    }

    expect(ui, contains('Home must no longer show the visible `کارهای من`'));
    expect(ui, contains('move the work filters/categories into `بیشتر`'));
    expect(ui, contains('full-screen/near-full-screen'));
    expect(authority, contains('Current owner recovery ledger'));
    expect(authority, contains('GitHub Issue #845'));
    expect(authority,
        contains('docs/ARVIN_RECOVERY_WAVE0_EXACT_MAIN_AUDIT_2026-09-12.md'));

    expect(audit, contains('ProjectDeleteBlocked'));
    expect(audit, contains('CalendarProviderSyncExecutor'));
    expect(audit, contains('CanonicalNotebookRepository'));
    expect(audit, contains('AppSettingsService'));
    expect(audit, contains('backup_schedule_page.dart'));

    expect(audit, contains('Dropbox remains out of scope for v1'));
    expect(audit, contains('Wave 0 may close only when'));
  });
}
