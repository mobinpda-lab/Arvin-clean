# Vazirharf v34.003 — Font Standard

## Status
Vazirharf v34.003 is the canonical Persian/Arabic UI font standard for this project.

- Upstream: `nadalaba/vazirharf`
- Version: `v34.003`
- Pinned upstream commit: `3cbc943b9fb9107baa77008b3e96b3c3e40e9ed8`
- Integration path: `assets/fonts/vazirharf`
- Integration method: Git submodule

## Standardization policy
All active application typography, Persian/RTL UI typography, PDF/Print typography, tests, configuration, CI and project documentation must use Vazirharf v34.003 where a project font is required.

The previous Vazirmatn application-font standard is superseded by this specification.

## Compatibility requirements
1. CI/build must initialize and update Git submodules before any build step that requires the font.
2. Flutter font configuration must resolve to Vazirharf and its checked-in/submodule assets.
3. PDF/Print renderers must use the Vazirharf assets when Persian text is rendered.
4. Tests and contract checks must assert the canonical Vazirharf configuration.
5. Documentation and configuration must not describe the superseded font as the project standard.
6. Existing RTL behavior, layout, persistence, backup/restore and other product behavior must remain unchanged by the typography migration.

## Scope
This document records the project-wide font-standard decision and is part of the canonical project documentation. Historical Git commits are immutable; this policy applies to the active source tree and current development state.
