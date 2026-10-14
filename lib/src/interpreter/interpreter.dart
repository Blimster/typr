import 'package:typr/src/error_handling/error_handling.dart';
import 'package:typr/src/interpreter/environment.dart';
import 'package:typr/src/model/expression.dart';
import 'package:typr/src/model/statement.dart';
import 'package:typr/src/model/token.dart';

class RuntimeError(final Token token, final String message) implements Exception;

class Interpreter(final ErrorHandler _errorHandler) implements ExpressionVisitor<Object>, StatementVisitor<void> {
  final Environment _environment = Environment();

  void interpret(List<Statement> statements) {
    try {
      for (final statement in statements) {
        _execute(statement);
      }
    } on RuntimeError catch (e) {
      _errorHandler.reportErrorWithToken(e.message, e.token);
    }
  }

  void _execute(Statement statement) {
    statement.accept(this);
  }

  @override
  Object visitLiteralExpression(LiteralExpression literal) {
    return literal.value;
  }

  @override
  Object visitUnaryExpression(UnaryExpression unary) {
    final right = _evaluate(unary.right);

    if (right is bool) {
      switch (unary.operator.type) {
        case .bang:
          return !right;
        default:
          throw RuntimeError(
            unary.operator,
            'Unsupported operator for type: type=Bool, operator=${unary.operator.lexeme}',
          );
      }
    } else if (right is num) {
      switch (unary.operator.type) {
        case .minus:
          return -right;
        default:
          throw RuntimeError(
            unary.operator,
            'Unsupported operator for type: type=${right is int ? 'Int' : 'Double'}, operator=${unary.operator.lexeme}',
          );
      }
    }

    return right;
  }

  @override
  Object visitBinaryExpression(BinaryExpression binary) {
    final left = _evaluate(binary.left);
    final right = _evaluate(binary.right);

    if (left is bool) {
      switch (binary.operator.type) {
        case .equal:
          return left == _expectBool(right, binary.operator);
        case .notEqual:
          return left != _expectBool(right, binary.operator);
        default:
          throw RuntimeError(
            binary.operator,
            'Unsupported operator for type: type=Bool, operator=${binary.operator.lexeme}',
          );
      }
    } else if (left is num) {
      switch (binary.operator.type) {
        case .equal:
          return left == _expectNum(right, binary.operator);
        case .notEqual:
          return left != _expectNum(right, binary.operator);
        case .greater:
          return left > _expectNum(right, binary.operator);
        case .greaterEqual:
          return left >= _expectNum(right, binary.operator);
        case .less:
          return left < _expectNum(right, binary.operator);
        case .lessEqual:
          return left <= _expectNum(right, binary.operator);
        case .plus:
          return left + _expectNum(right, binary.operator);
        case .minus:
          return left - _expectNum(right, binary.operator);
        case .star:
          return left * _expectNum(right, binary.operator);
        case .slash:
          return left / _expectNum(right, binary.operator);
        default:
          throw RuntimeError(
            binary.operator,
            'Unsupported operator for type: type=${left is int ? 'Int' : 'Double'}, operator=${binary.operator.lexeme}',
          );
      }
    }

    return right;
  }

  @override
  Object visitGroupingExpression(GroupingExpression grouping) {
    return _evaluate(grouping.expression);
  }

  @override
  Object visitVariableExpression(VariableExpression variable) {
    return _environment.get(variable.name.lexeme);
  }

  @override
  void visitExpressionStatement(ExpressionStatement statement) {
    _evaluate(statement.expression);
  }

  @override
  void visitPrintStatement(PrintStatement statement) {
    final value = _evaluate(statement.expression);
    print(value);
  }

  @override
  void visitValDeclarationStatement(ValDeclarationStatement statement) {
    final value = _evaluate(statement.initializer);
    _environment.define(statement.name, value);
  }

  @override
  void visitVarDeclarationStatement(VarDeclarationStatement statement) {
    final value = _evaluate(statement.initializer);
    _environment.define(statement.name, value);
  }

  @override
  void visitAssignmentStatement(AssignmentStatement statement) {
    final value = _evaluate(statement.value);
    _environment.assign(statement.name, value);
  }

  Object _evaluate(Expression expression) {
    return expression.accept(this);
  }

  bool _expectBool(Object value, Token token) {
    if (value is bool) {
      return value;
    }
    throw RuntimeError(token, 'Expected a Bool value, but got: $value');
  }

  num _expectNum(Object value, Token token) {
    if (value is num) {
      return value;
    }
    throw RuntimeError(token, 'Expected a Num value, but got: $value');
  }
}
