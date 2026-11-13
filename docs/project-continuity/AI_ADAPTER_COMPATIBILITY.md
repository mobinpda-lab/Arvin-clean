# AI Agent Adapter Compatibility Assessment

**Assessment date:** 2026-11-10  
**Repository:** mobinpda-lab/Arvin-clean  
**Canonical policy:** [AI_GOVERNANCE_POLICY.md](AI_GOVERNANCE_POLICY.md)  
**Canonical entrypoint:** root `AGENTS.md`

## Adapter matrix

| Agent | Repository instruction path | Assessment | Runtime verification |
|---|---|---|---|
| Claude Code | `CLAUDE.md` | Adapter installed; points to AGENTS.md and canonical policy. | File presence verified through GitHub; actual Claude Code session pickup not tested. |
| Gemini | `GEMINI.md` | Adapter installed; points to AGENTS.md and canonical policy. | File presence verified through GitHub; actual Gemini runtime pickup not tested. |
| GitHub Copilot | `.github/copilot-instructions.md` | Repository-wide instruction adapter installed. | File presence verified through GitHub; Copilot client pickup not tested. |
| Cursor | `.cursor/rules/arvin-governance.mdc` | Rule file installed with `alwaysApply: true`. | File presence and frontmatter verified; actual Cursor session pickup not tested. |
| Windsurf Cascade | `.windsurf/rules/arvin-governance.md` | Workspace rule adapter installed with `trigger: always_on`. Current official documentation identifies `.windsurf/rules/*.md` as a legacy rule location imported by default; `.devin/rules/*.md` is preferred for Devin Local. Root `AGENTS.md` is also documented as an always-on rule. | File presence and frontmatter verified; actual Windsurf/Cascade session pickup not tested. |

## Windsurf compatibility decision

The repository includes the supported compatibility path `.windsurf/rules/arvin-governance.md` for Windsurf Cascade. It does **not** add a separate root `.windsurfrules` file because the directory-based workspace rule is the selected adapter and avoids duplicating the same policy in multiple locations. If the team later standardizes on Devin Local rather than Windsurf Cascade, evaluate a separate `.devin/rules/*.md` adapter; do not silently rename or remove this one.

Official documentation consulted on 2026-11-10:
- [Devin Desktop / Cascade customizations — Rules, AGENTS.md and legacy Windsurf rule imports](https://docs.devin.ai/desktop/cascade/memories) (the former Windsurf documentation URL redirects to the current documentation).
- [Windsurf documentation index](https://docs.windsurf.com/llms.txt).

## Single-source rule

All agent-specific files are thin pointers. They must not contain independent copies of product rules. The only canonical AI policy is `AI_GOVERNANCE_POLICY.md`; the active product charter is `MASTER_GOVERNANCE.md`. Changes to the policy belong in those canonical files, followed by a check that every adapter still points to them.


## Adapter duplication and preservation rule — 2026-11-10

The following three entry-point files currently have identical blob content by design:
- `CLAUDE.md`
- `GEMINI.md`
- `.github/copilot-instructions.md`

They are separate tool-discovery entry points that intentionally share the same thin-pointer text. This is not duplicate product documentation and is not a cleanup deletion target. Keep the one-policy architecture; update the canonical AI policy first and only change adapter text when a tool-specific bootstrap requirement is proven.

The two UI documents named `ARVIN_UI_CANONICAL.md` are not exact duplicates: `docs/ARVIN_UI_CANONICAL.md` and `docs/UI/ARVIN_UI_CANONICAL.md` differ in content, length and purpose. Do not merge or rename them until inbound links and authority are audited in WAVE 3.

Runtime pickup of Claude, Gemini, Copilot, Cursor and Windsurf rules remains NOT VERIFIED. File presence and matching adapter text do not prove runtime activation.
