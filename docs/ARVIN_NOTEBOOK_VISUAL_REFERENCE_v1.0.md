# ARVIN NOTEBOOK VISUAL REFERENCE v1.0

Status: ACTIVE PRODUCT CONTRACT

## Acceptance Gate

Notebook acceptance requires:

```
Visual Match
+
Functional Match
+
Persistence Proof
```

## Visual Match

The Notebook UI reference defines:

- Notebook list with title, subtitle, search, category filters, Note/Checklist modes, cards and create action.
- Simple Note editor as a full-screen, content-first editor.
- Checklist editor with real items, completion controls and calculated progress.
- RTL layout, soft cards, minimal UI and Arvin visual language.

Simple Note editor must not be overloaded with task controls:

- no due date by default
- no reminder
- no priority
- no follow-up timeline

Formatting tools are accepted only when they work and persist correctly.

## Functional Match

Required capabilities:

- Create Note
- Create Checklist
- Open content
- Edit content
- Change category
- Delete according to Arvin rules
- Search
- Category filtering
- Note/Checklist separation

Checklist progress must be data driven:

```
completed items / total items
```

Example:

```
2 / 5 = 40%
```

## Persistence Proof

Completion requires evidence that data survives restart.

Note verification:

- create
- edit
- save
- restart app
- reopen

Expected:

- content preserved
- category preserved
- same record identity

Checklist verification:

- create items
- change completion state
- save
- restart app
- reopen

Expected:

- items preserved
- completion state preserved
- progress recalculated

## Architecture Rules

Notebook continues using canonical Arvin persistence.

Forbidden:

- separate Note database
- parallel Checklist storage
- duplicate records for category changes

Category changes update the same canonical record.

## Definition of Done

A Notebook feature is accepted only with:

- Visual Match evidence
- Functional Match evidence
- Persistence Proof
- Build verification
- Test evidence

This document is subordinate to live GitHub reality and newer owner-approved decisions.
