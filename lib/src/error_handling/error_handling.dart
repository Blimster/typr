import 'package:typr/src/model/token.dart';

abstract interface class ErrorHandler {
  void reportError(String message, TokenLocation location);
  bool get hadError;
}

class ConsoleErrorHandler implements ErrorHandler {
  bool _hadError = false;

  @override
  void reportError(String message, TokenLocation location) {
    print('Error (${location.line}, ${location.column}): $message');
    _hadError = true;
  }

  @override
  bool get hadError => _hadError;
}
