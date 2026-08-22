# Arvin-clean User Communication Protocol

## Purpose

This document defines the communication format for continuing Arvin development when the project owner is not a programmer.

## Rule: Commands for GAP

Whenever an instruction must be sent to GAP:

- The instruction must be separated from normal explanations.
- The instruction must be provided inside a copyable code block.
- The user should be able to copy the block directly and send it to GAP.

## Rule: Reports for Project Owner

Reports intended for the project owner must be:

- Simple and understandable.
- Focused on what happened, why it matters, and the next step.
- Free from unnecessary technical language.

Technical details such as SHA, Diff, Logs, Tests, CI and Commands should be included only when they are needed for GAP, GitHub evidence, or project tracking.

## Execution Flow

GAP analysis

→ GAP instruction / patch

→ Repository review

→ Controlled execution

→ Test and validation

→ Result report

→ GAP review

→ Next improvement cycle

## Important Constraint

No change should be considered complete without real evidence from the repository, validation results, and recorded project history.
