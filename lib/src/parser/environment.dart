import 'package:typr/src/model/type.dart';
import 'package:typr/src/parser/parser.dart';

class VariableDeclaration(final BaseType type, final bool mutable);

class ParserEnvironment {
  final Map<String, VariableDeclaration> _variables = {};

  void declare(String name, BaseType type, bool mutable) {
    if (_variables.containsKey(name)) {
      throw ParserError('Variable with name "$name" is already declared.');
    }
    _variables[name] = VariableDeclaration(type, mutable);
  }

  BaseType? getType(String name) {
    final type = _variables[name]?.type;
    if (type != null) {
      return type;
    }
    return null;
  }

  bool? isMutable(String name) {
    final mutable = _variables[name]?.mutable;
    if (mutable != null) {
      return mutable;
    }
    return null;
  }
}
