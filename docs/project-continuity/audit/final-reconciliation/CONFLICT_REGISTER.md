# CONFLICT REGISTER
Authority: newest explicit Product Owner directive wins. Preserve superseded evidence; do not reactivate it.

| ID | Conflict | Older source | Current owner decision | Disposition |
|---|---|---|---|---|
| C-01 | Home filter count | PR #3622 requires four primary filters and moves Center to More. | Five dimensions including Center. | #3622 Home behavior SUPERSEDED; preserve useful tests, adapt UI to five. |
| C-02 | Home filter order | PR #3569 and older docs place Center last. | Time → Center → Project → Category → Tag. | Adapt to owner order. |
| C-03 | Primary brand color | PR #3567 proposes #078B91 teal. | Primary Blue #4169A1. | Teal may not be Primary; retain only if independently approved as semantic accent. |
| C-04 | Schema target | Historical #3384/#3463 chain targets v19/v20. | v7→v9. | v19/v20 historical evidence only; no blind migration import. |
| C-05 | Reminder UX | Older notification-only/overlay assumptions. | Four ordered actions Stop, Follow-up, Snooze, Complete. | Issue #3646 remains P0 and NOT ACCEPTED; do not infer overlay permission behavior. |
| C-06 | Governance route | Historical commands name #3052/#3384/#3463. | REV10 + owner addenda; #3495 sole route. | Old route references historical/superseded. |
| C-07 | APK release identity | pubspec.yaml 1.0.1+2. | Actual uploaded APK 1.0-staging / code1 / staging package. | Artifact is not production candidate and is not SHA-attributed. |
| C-08 | Font weight coverage | APK/source manifests list 400/500/700. | Owner target 300/400/500/600/700. | Missing weights/coverage require audit; do not claim full contract. |
| C-09 | Reminder/Follow-up Calendar projection | Legacy Follow-up reminder metadata may be misread as separate event. | Historical Follow-up remains independent; no automatic Calendar Reminder. | Preserve contract and regression coverage. |
| C-10 | Commit inventory | PR metadata reports 691 commits; inspected PR commit endpoint returned 250 records. | Full commit reconciliation required. | COMMIT_RECONCILIATION.csv PARTIAL; 441 commit records remain unenumerated by this retrieval. |

No unresolved semantic ambiguity is silently implemented. Owner decisions are required only where the current directive does not define meaning or platform behavior.