# Release History Audit

**Audit date:** 2026-11-18  
**Main SHA:** `45e4202b03a434459e4c021a04efa7e8396359db`

## Main app identity
Main `pubspec.yaml` blob `068760c1d3d6495108157a733199f82f104d787f` declares application version `1.0.1+2`.

## GitHub release records
GitHub Releases API returned exactly two records:
| Tag | Name | Draft | Prerelease | Created / published | Assets |
|---|---|---|---|---|---|
| `v0.1.0-arvin-33ed363` | Arvin 1.0.1+2 (build 2) | true | true | 2026-10-09 | `artifact.sha256`, `release-evidence.txt`; both download count 0 |
| `v0.1.0-arvin-dd95132` | Arvin 1.0.1+2 (build 2) | true | true | 2026-10-09 | `artifact.sha256`, `release-evidence.txt`; both download count 0 |

Both release bodies explicitly state **UNAPPROVED — NOT A RELEASE CANDIDATE** and require product release gate #2102 and regression lane #1901 to close before publication.

Repository tags:
- `v0.1.0-arvin-33ed363` → `33ed363eba1ccf6938b0c40113b1391baf2ce792`, commit dated 2026-10-09.
- `v0.1.0-arvin-b842e5b` → `b842e5b7f9409929e76c4e2f22213cdf3a5191ed`, commit dated 2026-10-07.
- `v0.1.0-arvin-dd95132` → `dd95132cca2cbc3b20e3318f3f52a84875609f08`, commit dated 2026-10-09.

These tags predate the V19 PR/source snapshot dated 2026-11-11/14. No V19/V20 tag or published GitHub release was found in the repository records reviewed.

## Release workflow
Main `.github/workflows/release.yml` blob `c5f45b9b1d66db22a585b0637a24537aeb95d098` is manually dispatched with a caller-supplied tag. The presence of this workflow is not proof that a production release occurred.

Latest observed Main run for the production orchestrator: run `44381381686`, SHA `45e4202b03a434459e4c021a04efa7e8396359db`, conclusion SUCCESS. On the same Main head, Final Head Release Validation and Release Closure were SKIPPED in the observed run set. Orchestrator success is not a release.

## What can and cannot be concluded
**Proven:** no V19/V20 published GitHub release is present in the inspected GitHub Releases records; the only two GitHub release objects are drafts/prereleases explicitly labelled unapproved; the tags are earlier than the V19 candidate.

**Not proven:** whether a binary was sideloaded, distributed through Google Play, private testing, direct APK sharing, or another channel. Play Console, external artifact stores, telemetry and actual devices were not accessible.

**Conclusion:** V19 delivery to users is **NOT EVIDENCED / UNKNOWN**, not categorically disproven. A definitive statement requires store-console release history, signed artifact provenance and a user/device database inventory.
