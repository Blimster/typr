import 'package:typr/src/model/token_type.dart';

class Token(
  final TokenType type,
  final String lexeme,
  final Object? literal,
  final int line,
  final int column,
) {
  @override
  String toString() {
    return '$type${lexeme.isNotEmpty ? ' $lexeme' : ''}';
  }
}
