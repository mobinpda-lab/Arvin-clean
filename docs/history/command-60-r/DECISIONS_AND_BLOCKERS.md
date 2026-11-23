# DECISIONS AND BLOCKERS — COMMAND 60-R

## New owner decisions from COMMAND 60-R
- REV10 is the official product requirements and design authority.
- Full redesign of all real pages is authorized; do not request repeated approval.
- Five independent execution branches A–E are authorized. This is newer than the older one-active-branch governance text.
- No Main write, merge, public release, deployment or production-user migration is authorized.
- Preserve historical V19 installer and V7 fixture.
- Do not delete/weaken failing tests.
- No feature may be called complete based on appearance alone.

## Confirmed existing REV10 decisions
- Home filters: Time, Center, Project, Category, Tag; OR within a dimension, AND across dimensions.
- Center↔Project M2M; Project↔Category M2M; Task direct links optional 0..1; Task↔Tag M2M.
- Local-first; multi-device sync suspended.
- Legacy Follow-up metadata retained for compatibility.

## Open blockers
- Font authority conflict between historical VazirHarf v34.003 owner instruction and later Vazirmatn entries in current product decisions.
- No VazirHarf v34.003 ZIP found in current available file listing; Vazirmatn v33.003 archive verified.
- V7→V20 sequential migration not proven.
- Occurrence parity and V19 NULL/unknown-field/reopen failures.
- V8→V9 test executor lifecycle issue.
- Person Directory delete dialog test failure.
- COMMAND 20-E final acceptance gate false.
- Full page route inventory, screenshot evidence and physical phone acceptance remain incomplete.

## Decision rule
If an older document conflicts with an explicit newer owner instruction, this mission follows COMMAND 60-R. Preserve the older text as history and record the supersession here; do not rewrite Main or erase the historical record.
