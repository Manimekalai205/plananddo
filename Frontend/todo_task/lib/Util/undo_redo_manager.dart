class UndoRedoManager {
  final List<String> _history = [];
  int _index = -1;
  bool _isProgrammaticChange = false;

  void onChange(String value) {
    if (_isProgrammaticChange) return;

    if (_index < _history.length - 1) {
      _history.removeRange(_index + 1, _history.length);
    }

    if (_index == -1 || _history[_index] != value) {
      _history.add(value);
      _index = _history.length - 1;
    }
  }

  String? undo() {
    if (canUndo) {
      _index--;
      return _history[_index];
    }
    return null;
  }

  String? redo() {
    if (canRedo) {
      _index++;
      return _history[_index];
    }
    return null;
  }

  String applyProgrammaticChange(String value) {
    _isProgrammaticChange = true;
    return value;
  }

  void endProgrammaticChange() {
    _isProgrammaticChange = false;
  }

  bool get canUndo => _index > 0;
  bool get canRedo => _index >= 0 && _index < _history.length - 1;
}
