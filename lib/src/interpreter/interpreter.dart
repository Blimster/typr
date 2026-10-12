import 'package:typr/src/interpreter/environment.dart';
import 'package:typr/src/model/expression.dart';
import 'package:typr/src/model/statement.dart';

class Interpreter implements ExpressionVisitor<Object>, StatementVisitor<void> {
  final Environment _environment = Environment();

  void interpret(List<Statement> statements) {
    for (final statement in statements) {
      _execute(statement);
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
          throw Exception(
            'Unsupported operator for type: type=Bool, operator=${unary.operator.lexeme}',
          );
      }
    } else if (right is num) {
      switch (unary.operator.type) {
        case .minus:
          return -right;
        default:
          throw Exception(
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
          return left == _expectBool(right);
        case .notEqual:
          return left != _expectBool(right);
        default:
          throw Exception(
            'Unsupported operator for type: type=Bool, operator=${binary.operator.lexeme}',
          );
      }
    } else if (left is num) {
      switch (binary.operator.type) {
        case .equal:
          return left == _expectNum(right);
        case .notEqual:
          return left != _expectNum(right);
        case .greater:
          return left > _expectNum(right);
        case .greaterEqual:
          return left >= _expectNum(right);
        case .less:
          return left < _expectNum(right);
        case .lessEqual:
          return left <= _expectNum(right);
        case .plus:
          return left + _expectNum(right);
        case .minus:
          return left - _expectNum(right);
        case .star:
          return left * _expectNum(right);
        case .slash:
          return left / _expectNum(right);
        default:
          throw Exception(
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

  bool _expectBool(Object value) {
    if (value is bool) {
      return value;
    }
    throw Exception('Expected a Bool value, but got: $value');
  }

  num _expectNum(Object value) {
    if (value is num) {
      return value;
    }
    throw Exception('Expected a Num value, but got: $value');
  }
}
