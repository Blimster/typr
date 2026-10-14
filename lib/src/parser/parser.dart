import 'package:typr/src/error_handling/error_handling.dart';
import 'package:typr/src/model/expression.dart';
import 'package:typr/src/model/statement.dart';
import 'package:typr/src/model/token.dart';
import 'package:typr/src/model/type.dart';
import 'package:typr/src/parser/environment.dart';

class ParserError(final String message) implements Exception;

class Parser(final List<Token> _tokens, final ErrorHandler _errorHandler) {
  final ParserEnvironment _environment = ParserEnvironment();
  int _current = 0;

  List<Statement> parse() {
    final List<Statement> statements = [];
    while (!_isAtEnd()) {
      final declaration = _declaration();
      if (declaration != null) {
        statements.add(declaration);
      }
    }

    return statements;
  }

  Statement? _declaration() {
    try {
      if (_matchTokenType([.varKeyword])) {
        return _varDeclaration();
      }
      if (_matchTokenType([.valKeyword])) {
        return _valDeclaration();
      }

      return _statement();
    } on ParserError {
      _synchronize();
      return null;
    }
  }

  Statement _varDeclaration() {
    final name = _consume(.identifier, "Expect variable name.");
    _consume(.assign, "Expect '=' after variable name.");
    final initializer = _expression();
    _consume(.semicolon, "Expect ';' after variable declaration.");
    _environment.declare(name.lexeme, initializer.type, true);
    return VarDeclarationStatement(name.lexeme, initializer);
  }

  Statement _valDeclaration() {
    final name = _consume(.identifier, "Expect variable name.");
    _consume(.assign, "Expect '=' after variable name.");
    final initializer = _expression();
    _consume(.semicolon, "Expect ';' after variable declaration.");
    _environment.declare(name.lexeme, initializer.type, false);
    return ValDeclarationStatement(name.lexeme, initializer);
  }

  Statement _statement() {
    if (_matchTokenType([.printKeyword])) {
      return _printStatement();
    }
    if (_matchTokenType([.identifier])) {
      return _assignmentStatement();
    }

    return _expressionStatement();
  }

  Statement _printStatement() {
    final value = _expression();
    _consume(.semicolon, "Expect ';' after value.");
    return PrintStatement(value);
  }

  Statement _assignmentStatement() {
    final name = _previous();
    _consume(.assign, "Expect '=' after variable name.");
    final value = _expression();
    _consume(.semicolon, "Expect ';' after assignment.");

    if (_environment.isMutable(name.lexeme) == false) {
      throw _error('Assignment to inmutable variable is not allowed.', name);
    }

    final type = _environment.getType(name.lexeme);
    if (type == null) {
      throw _error('Variable "${name.lexeme}" is not declared.', name);
    }
    if (!type.isAssignableWith(value.type)) {
      throw _error(
        'Expression of type "${value.type.name}" is not assignable to variable of type "${type.name}".',
        name,
      );
    }

    return AssignmentStatement(name.lexeme, value);
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
      final type = _typeOfBinary(expr, operator, right);
      expr = BinaryExpression(type, expr, operator, right);
    }

    return expr;
  }

  Expression _comparison() {
    var expr = _term();

    while (_matchTokenType([.greater, .greaterEqual, .less, .lessEqual])) {
      final operator = _previous();
      final right = _term();
      final type = _typeOfBinary(expr, operator, right);
      expr = BinaryExpression(type, expr, operator, right);
    }

    return expr;
  }

  Expression _term() {
    var expr = _factor();

    while (_matchTokenType([.minus, .plus])) {
      final operator = _previous();
      final right = _factor();
      final type = _typeOfBinary(expr, operator, right);
      expr = BinaryExpression(type, expr, operator, right);
    }

    return expr;
  }

  Expression _factor() {
    var expr = _unary();

    while (_matchTokenType([.slash, .star])) {
      final operator = _previous();
      final right = _unary();
      final type = _typeOfBinary(expr, operator, right);
      expr = BinaryExpression(type, expr, operator, right);
    }

    return expr;
  }

  Expression _unary() {
    if (_matchTokenType([.bang, .minus])) {
      final operator = _previous();
      final right = _unary();
      return UnaryExpression(operator, right);
    }

    return _primary();
  }

  Expression _primary() {
    if (_matchTokenType([.falseKeyword])) return LiteralExpression(boolType, false);
    if (_matchTokenType([.trueKeyword])) return LiteralExpression(boolType, true);

    if (_matchTokenType([.integer])) return LiteralExpression(intType, _previous().literal!);
    if (_matchTokenType([.double])) return LiteralExpression(doubleType, _previous().literal!);
    if (_matchTokenType([.string])) return LiteralExpression(stringType, _previous().literal!);

    if (_matchTokenType([.identifier])) {
      final nameToken = _previous();
      final type = _environment.getType(nameToken.lexeme);
      if (type == null) {
        throw _error('Variable with name "${nameToken.lexeme}" is not declared.', nameToken);
      }
      return VariableExpression(type, nameToken);
    }

    if (_matchTokenType([.leftParenthesis])) {
      final expr = _expression();
      _consume(.rightParenthesis, "Expect ')' after expression.");
      return GroupingExpression(expr);
    }

    throw _error("Expect expression.", _peek());
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

    throw _error(message, _peek());
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

  BaseType _typeOfBinary(Expression left, Token operator, Expression right) {
    if ([
      TokenType.equal,
      TokenType.notEqual,
      TokenType.less,
      TokenType.lessEqual,
      TokenType.greater,
      TokenType.greaterEqual,
    ].contains(operator.type)) {
      return boolType;
    }

    if ([
          TokenType.plus,
          TokenType.minus,
          TokenType.star,
          TokenType.slash,
        ].contains(operator.type) &&
        left.type.isType(numType) &&
        right.type.isType(numType)) {
      if (left.type == doubleType || right.type == doubleType) {
        return doubleType;
      } else {
        return intType;
      }
    }

    throw _error('Cannot determine type of binary operator.', operator);
  }

  ParserError _error(String message, Token token) {
    _errorHandler.reportErrorWithToken(message, token);
    return ParserError(message);
  }

  void _synchronize() {
    _advance();

    while (!_isAtEnd()) {
      if (_previous().type == .semicolon) {
        return;
      }

      switch (_peek().type) {
        case .varKeyword:
        case .valKeyword:
        case .printKeyword:
          return;
        case _:
          _advance();
      }
    }
  }
}
