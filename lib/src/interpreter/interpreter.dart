import 'package:typr/src/model/expression.dart';
import 'package:typr/src/model/statement.dart';

class Interpreter implements ExpressionVisitor<Object>, StatementVisitor<void> {
  void interpret(List<Statement> statements) {
    for (final statement in statements) {
      _execute(statement);
    }
  }

  void _execute(Statement statement) {
    statement.accept(this);
  }

  @override
  Object visitLiteral(Literal literal) {
    return literal.value;
  }

  @override
  Object visitUnary(Unary unary) {
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
  Object visitBinary(Binary binary) {
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
  Object visitGrouping(Grouping grouping) {
    return _evaluate(grouping.expression);
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
