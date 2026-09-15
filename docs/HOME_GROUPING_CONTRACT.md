# Arvin Home Four-View Grouping Contract

Status: BINDING PRODUCT CONTRACT

## Principle

Home is one page with four grouping modes. It is not four separate screens.

The product remains the source of truth; views only change the presentation of the same Task data.

## Fixed selector order

Right to left:

1. زمان (Time)
2. پروژه‌ها (Projects)
3. دسته‌ها (Categories)
4. برچسب‌ها (Tags)

Selected state must be visible with the approved color treatment.

## Removed from Home

The old four statistic cards:
- کل
- فعال
- انجام‌شده
- عقب‌افتاده

must not return.

Overdue remains a real group in Time view.

## View behavior

### Time

Group incomplete tasks by due date:
- عقب‌افتاده
- امروز
- آینده
- بدون موعد

Due date must not be replaced by reminder or follow-up dates.

### Projects

Tasks are grouped by real project relation.

Required:
- all projects filter
- single project filter
- create/edit project
- without project group
- plus action beside project creates a task assigned to that project

### Categories

Categories are independent from projects.

Required:
- category grouping
- create/edit category
- icon/color selection
- without category group
- project filter

### Tags

A task may contain multiple tags.

Required:
- tag grouping
- create/edit tag
- color selection
- without tag group
- project/category filtering

A task shown in multiple groups is not duplicated in storage or global counts.

## Task card contract

Every card contains:
- completion control
- strong title
- project/category metadata
- due date and real status
- one line latest follow-up, otherwise one line description
- shortened long text

Tap opens Task Detail, not edit form.

## Acceptance evidence

Implementation is accepted only with:
- real data rendering
- grouping tests
- no duplicate task counting
- Android validation screenshot
- passing CI
