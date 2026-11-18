# Historical Migration Path Decision

## Accepted path: A — Direct v7 → v19 Installer invocation on a disposable copy

The historical v19 source contains explicit compatibility logic for the Main v7 legacy structures. The original Installer was run against an independent physical copy of the approved v7 fixture and completed successfully.

Verified transformations include:
- Task legacy scheduling columns into canonical compatibility/reminder structures;
- legacy Follow-up rows into `follow_up_records`;
- People and Task-person data into `persons`, `person_directory` and `task_persons`;
- Follow-up-person links into `follow_up_record_people`;
- Task Reminder and Recurrence rows into their canonical tables;
- occurrence/checklist migration path through the historical codecs (no occurrence rows existed in this fixture).

The real Git history also contains the sequential v7 → v8 → v9-A → v10 … v19 lineage. That lineage is not needed as a fabricated pre-step for this fixture: direct execution of the actual v19 Installer has now been demonstrated.

## Evidence and boundaries

- Run `44308608481`, final conclusion SUCCESS.
- Job `134816565546`, conclusion SUCCESS.
- Artifact `14429935379`, SHA-256 of ZIP: `09e2bd12e09955e4ea69ad3c2c02193dd5a534912fe4ed4942c7ae83df8b2af9`.
- Post `integrity_check=ok`; zero FK violations.
- No v20 installer was executed.
- No intermediate migration was fabricated.
- The source fixture was not modified.

This is a successful compatibility execution for the approved fixture. Retry, interruption and backup recovery remain separate COMMAND 47 acceptance work.
