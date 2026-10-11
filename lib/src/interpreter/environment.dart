class Environment {
  final Map<String, Object> _values = {};

  void define(String name, Object value) {
    if (_values.containsKey(name)) {
      throw Exception('Variable "$name" is already defined.');
    }
    _values[name] = value;
  }

  Object get(String name) {
    if (!_values.containsKey(name)) {
      throw Exception('Variable "$name" is not defined.');
    }
    return _values[name]!;
  }
}
