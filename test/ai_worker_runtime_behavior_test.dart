import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AI worker runtime normalizes and rejects malformed patches', () {
    if (!Platform.isLinux && !Platform.isMacOS) return;

    const script = r'''
import importlib.util
import time

spec = importlib.util.spec_from_file_location(
    "arvin_agent_runtime",
    ".github/arvin/agent-runtime.py",
)
runtime = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runtime)

valid = """prose before patch
```diff
diff --git a/lib/a.dart b/lib/a.dart
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1 +1 @@
-old
+new
```
trailing prose
"""
normalized = runtime.normalize_diff(valid)
assert normalized.startswith("diff --git a/lib/a.dart b/lib/a.dart")
assert normalized.endswith("+new")
ok, message = runtime.validate_diff_structure(normalized)
assert ok, message

hunk_only = """@@ -1 +1 @@
-old
+new
"""
ok, message = runtime.validate_diff_structure(hunk_only)
assert not ok
assert "diff --git" in message

missing_headers = """diff --git a/lib/a.dart b/lib/a.dart
@@ -1 +1 @@
-old
+new
"""
ok, message = runtime.validate_diff_structure(missing_headers)
assert not ok
assert "---" in message and "+++" in message

try:
    runtime.next_provider_timeout(time.monotonic() - 1)
except TimeoutError as exc:
    assert "retry budget exhausted" in str(exc)
else:
    raise AssertionError("expired provider deadline must fail")
''';

    final result = Process.runSync('python3', ['-c', script]);
    expect(
      result.exitCode,
      0,
      reason: '${result.stdout}\n${result.stderr}',
    );
  });
}
