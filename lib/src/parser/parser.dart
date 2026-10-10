import 'package:typr/src/model/expression.dart';
import 'package:typr/src/model/statement.dart';
import 'package:typr/src/model/token.dart';

class Parser(final List<Token> _tokens) {
  int _current = 0;

  List<Statement> parse() {
    final List<Statement> statements = [];
    while (!_isAtEnd()) {
      statements.add(_statement());
    }

    return statements;
  }

  Statement _statement() {
    if (_matchTokenType([.print])) {
      return _printStatement();
    }
    return _expressionStatement();
  }

  Statement _printStatement() {
    final value = _expression();
    _consume(.semicolon, "Expect ';' after value.");
    return PrintStatement(value);
  }

  Statement _expressionStatement() {
    final expression = _expression();
    _consume(.semicolon, "Expect ';' after expression.");
    return ExpressionStatement(expression);
  }

  Expression _expression() {
    return _equality();
  }

  Expression _equality() {
    var expr = _comparison();

    while (_matchTokenType([.equal, .notEqual])) {
      final operator = _previous();
      final right = _comparison();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expression _comparison() {
    var expr = _term();

    while (_matchTokenType([.greater, .greaterEqual, .less, .lessEqual])) {
      final operator = _previous();
      final right = _term();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expression _term() {
    var expr = _factor();

    while (_matchTokenType([.minus, .plus])) {
      final operator = _previous();
      final right = _factor();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expression _factor() {
    var expr = _unary();

    while (_matchTokenType([.slash, .star])) {
      final operator = _previous();
      final right = _unary();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expression _unary() {
    if (_matchTokenType([.bang, .minus])) {
      final operator = _previous();
      final right = _unary();
      return Unary(operator, right);
    }

    return _primary();
  }

  Expression _primary() {
    if (_matchTokenType([.falseKeyword])) return Literal(false);
    if (_matchTokenType([.trueKeyword])) return Literal(true);

    if (_matchTokenType([.integer, .double, .string])) {
      return Literal(_previous().literal!);
    }

    if (_matchTokenType([.leftParenthesis])) {
      final expr = _expression();
      _consume(.rightParenthesis, "Expect ')' after expression.");
      return Grouping(expr);
    }

    throw StateError("Expect expression.");
  }

  bool _matchTokenType(List<TokenType> types) {
    for (final type in types) {
      if (_checkTokenType(type)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  Token _consume(TokenType type, String message) {
    if (_checkTokenType(type)) {
      return _advance();
    }

    throw StateError(message);
  }

  bool _checkTokenType(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  bool _isAtEnd() {
    return _peek().type == .eof;
  }

  Token _peek() {
    return _tokens[_current];
  }

  Token _previous() {
    return _tokens[_current - 1];
  }
}
