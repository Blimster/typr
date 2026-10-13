import 'package:typr/src/model/token.dart';

abstract interface class ErrorHandler {
  void reportErrorWithLocation(String message, TokenLocation location);
  void reportErrorWithToken(String message, Token token);
  bool get hadError;
}

class ConsoleErrorHandler implements ErrorHandler {
  bool _hadError = false;

  @override
  void reportErrorWithLocation(String message, TokenLocation location) {
    print('Error (${location.line}, ${location.column}): $message');
    _hadError = true;
  }

  @override
  void reportErrorWithToken(String message, Token token) {
    final lexeme = token.type == TokenType.eof ? 'at end of file ' : 'near "${token.lexeme}" ';
    print('Error $lexeme(${token.location.line}, ${token.location.column}): $message');
    _hadError = true;
  }

  @override
  bool get hadError => _hadError;
}
