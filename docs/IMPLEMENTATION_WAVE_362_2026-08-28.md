# Notebook / Category UX wave #362

Status: active, independent product lane.

Delivered in this slice:
- Simple Note editor is text-focused and no longer shows checklist controls by default;
- Checklist/To-do keeps checklist editing in its own creation/editor mode;
- explicit visible edit action;
- category picker on the note/checklist page;
- choosing an existing category immediately reassigns the same canonical Task;
- creating a new category immediately assigns it without an extra save step;
- category membership is stored only in existing `Task.category` through `TaskStore/arvin.tasks`;
- notebook list reflects category membership;
- focused tests cover separation, edit behavior, immediate move, same-id/no-copy and persistence.

No `arvin.simple_notes`, second category database, duplicate Task or Joplin architecture is introduced. Joplin remains a behavioral UX reference only.

Known follow-up: a newly-created empty checklist has no persistent dedicated kind bit in the current canonical Task schema; during creation it remains in checklist mode, and once it has items the mode is naturally recoverable. A later product-safe refinement may address persistent empty-checklist identity without creating a duplicate model/storage path.
