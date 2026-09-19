# ARVIN PRODUCT FIRST GOVERNANCE

Status: Active extension of ARVIN_PROJECT_OPERATING_PACKAGE
Repository: mobinpda-lab/Arvin-clean

## Core Principle

Arvin is the product.

Arvin Factory and NIRA are tools. They exist to accelerate Arvin delivery, not to become separate products or priorities.

Factories must move behind Arvin.

## Priority

Optimize only for:

- Faster Arvin capability completion
- Higher product quality
- Faster release readiness
- Real user value

Do not optimize for:

- Number of workflows
- Number of workers
- Number of PRs
- Number of commits
- Factory complexity

## Source Of Truth

Only current verified GitHub reality changes status:

- Current main head
- Real code
- Real tests
- Real CI
- Real builds
- Real artifacts
- Real acceptance evidence

Old reports, memory and assumptions require revalidation.

## Product First Gate

Before work:

"Does this directly improve Arvin or reduce release time?"

If not, defer.

## Factory Boundary

Allowed:

- Build
- Test
- CI
- Release automation
- Validation
- Evidence collection
- Safe acceleration

Forbidden:

- Factory features without Arvin value
- Separate factory roadmap
- Factory complexity as a goal

## Arvin Internal Automation

Internal automation may exist inside Arvin, but it remains part of the product system and never outranks user value.

## Execution Model

Arvin Product

├── Arvin Internal Automation
├── Arvin Factory
└── NIRA Accelerator

## Parallel Development

Use parallel lanes only when:

- Scope is independent
- File boundaries are clear
- Acceptance criteria exist
- Merge conflict risk is controlled

Parallelism exists to reduce Arvin delivery time, not to increase activity.

## Completion Rule

Never claim done, tested, built, proven or release ready without current evidence.

## Operating Loop

Observe → Audit → Understand → Plan → Parallelize → Execute → Validate → Document → Report
