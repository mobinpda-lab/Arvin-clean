# COMMAND 45-R — Controlled runtime trigger

This documentation-only commit exists solely to activate the branch-scoped
push trigger in `.github/workflows/arvin-historical-migration.yml`.

- Authorized branch: `recovery-02/main-based-integration`
- Pre-trigger reference: `acc2f46dd070e7ba7e19f7bac1c0749d359414be`
- Expected fixture SHA-256: `68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0`
- Scope: runtime bootstrap and read-only fixture inspection only.
- Forbidden: v19/v20 migration execution, schema writes, fixture mutation,
  Main changes, merge, release, deployment.

A commit is not evidence of a successful workflow run. Acceptance requires
the actual Actions run, job logs, and uploaded artifacts.
