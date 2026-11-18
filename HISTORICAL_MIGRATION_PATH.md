# Historical Migration Path Decision

## Decision: Path A — Direct v19 installation on a disposable v7 fixture copy

Source review establishes that v19 directly handles the v7 legacy structures:
- Task legacy scheduling columns are copied into the compatibility envelope before guarded retirement.
- Legacy Follow-up rows and person links are copied into canonical v19 tables.
- Task-person JSON is validated and converted using the original historical method.
- Legacy Task and Follow-up reminders are converted through the historical Task model.
- Occurrence and recurrence JSON are migrated by their original codecs.

The Git history also contains a real sequential lineage v7 → v8 → v9-A → v10 … v19. This historical lineage is documented, but it is not required to justify the direct installer experiment because the v19 source itself includes legacy compatibility logic. No intermediate version will be fabricated or run as a substitute.

**Important:** Path A remains a controlled compatibility experiment until the Actions runner succeeds on the actual verified fixture copy. A source-code inspection is not a substitute for runtime evidence.
