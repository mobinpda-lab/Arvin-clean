/// Session rules for the simple notebook UI.
///
/// A newly created note is editable. Once the user leaves the editor,
/// the note becomes read-only until the user explicitly requests edit mode.
class SimpleNoteSessionPolicy {
  SimpleNoteSessionPolicy({bool editing = true}) : _editing = editing;

  bool _editing;

  bool get isEditing => _editing;
  bool get isReadOnly => !_editing;

  void exitEditor() => _editing = false;

  void requestEdit() => _editing = true;
}
