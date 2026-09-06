import importlib.util
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).with_name('progress_score.py')
SPEC = importlib.util.spec_from_file_location('progress_score', MODULE_PATH)
progress_score = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(progress_score)


MAIN_SHA = 'a' * 40


def evidence(status='PASS', sha=MAIN_SHA):
    return {'status': status, 'sha': sha}


class ProgressDashboardTest(unittest.TestCase):
    def all_gate_evidence(self, status='PASS', sha=MAIN_SHA):
        return {
            gate_id: evidence(status, sha)
            for gate_id in 'ABCDEFGH'
        }

    def test_pass_evidence_is_rendered(self):
        markdown = progress_score.render_dashboard(
            MAIN_SHA,
            self.all_gate_evidence(),
        )

        self.assertIn('| A | 70% | PASS |', markdown)
        self.assertIn('## Whole-project completion', markdown)
        self.assertIn('## 19-feature extension', markdown)

    def test_fail_and_blocked_evidence_are_rendered(self):
        gate_evidence = self.all_gate_evidence()
        gate_evidence['A'] = evidence('FAIL')
        gate_evidence['B'] = evidence('BLOCKED')

        markdown = progress_score.render_dashboard(MAIN_SHA, gate_evidence)

        self.assertIn('| A | 70% | FAIL |', markdown)
        self.assertIn('| B | 70% | BLOCKED |', markdown)

    def test_stale_pass_evidence_is_blocked(self):
        gate_evidence = self.all_gate_evidence(sha='b' * 40)

        markdown = progress_score.render_dashboard(MAIN_SHA, gate_evidence)

        self.assertNotIn('| A | 70% | PASS |', markdown)
        self.assertIn('| A | 70% | BLOCKED |', markdown)

    def test_invalid_main_sha_is_rejected(self):
        with self.assertRaises(ValueError):
            progress_score.render_dashboard('not-a-sha', {})

    def test_output_is_stable(self):
        gate_evidence = self.all_gate_evidence()

        first = progress_score.render_dashboard(MAIN_SHA, gate_evidence)
        second = progress_score.render_dashboard(MAIN_SHA, gate_evidence)

        self.assertEqual(first, second)


if __name__ == '__main__':
    unittest.main()
