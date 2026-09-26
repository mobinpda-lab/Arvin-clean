# ARVIN FINAL UI REFERENCE

## Status
Canonical visual and interaction reference for Arvin.

## Authority
This document defines the target product appearance and behavior based on approved real installed Arvin application screens.

Priority order:
1. Real installed Arvin behavior and approved screenshots.
2. Current canonical project documents when compatible.
3. Old documents only as historical records.

Conflicting old UI decisions must not influence implementation.

## Goal
Prevent UI drift and ensure the final production application converges to the real installed Arvin experience.

This reference covers both appearance and behavior:

- screen structure
- colors
- placement
- buttons
- icons
- navigation
- workflows
- information hierarchy

---

# Covered Product Areas

- Home dashboard
- Bottom navigation
- Quick entry
- Task details
- Follow-up system
- Calendar
- Notebook
- Checklists
- Categories
- Projects
- Labels
- Icons
- Colors
- Layout rules
- Persian RTL behavior

---

# Home Screen

Must preserve:

- Header identity area
- Search
- Statistics cards
- Time/projects/categories/labels navigation cards
- Task cards
- Quick actions
- Bottom navigation

Home is the operational dashboard and must provide immediate visibility of work status.

---

# Quick Entry

Required capabilities:

- Fast task capture
- Title input
- Project selection
- Category selection
- Labels
- Date/time
- Conversion to full task

Quick creation must remain fast and simple.

---

# Task Detail

Required:

- Task context
- Status
- Reminder
- Labels
- Follow-up history
- Timeline
- Add follow-up
- Complete action

---

# Follow-up

Follow-up is a core Arvin workflow:

- Create follow-up
- Track responses
- Show history
- Manage reminders
- Display next required action

---

# Notebook

Supports:

- Notes
- Checklists
- Organization
- Search
- Editing
- Categories

---

# Visual System

Preserve:

- Approved color palette
- Card hierarchy
- Typography hierarchy
- Icon language
- Spacing
- Rounded surfaces
- RTL alignment

Semantic colors must communicate state:

- completed
- active
- waiting
- warning
- important

---

# Organization Model

Core entities:

- Projects
- Categories
- Labels
- Personal items
- Work items
- Unassigned items

The UI must keep relationships clear.

---

# Conflict Resolution

If older material conflicts with this document:

- This reference has priority.
- Conflicting old documents must be archived or marked superseded.
- New implementation must not revive obsolete designs.

---

# Production Objective

Deliver the final Arvin product matching the approved installed experience with stable architecture, maintainability and production readiness.
