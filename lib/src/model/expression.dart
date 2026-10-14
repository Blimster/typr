import 'package:typr/src/model/token.dart';
import 'package:typr/src/model/type.dart';

abstract interface class ExpressionVisitor<R> {
  R visitUnaryExpression(UnaryExpression unary);
  R visitBinaryExpression(BinaryExpression binary);
  R visitGroupingExpression(GroupingExpression grouping);
  R visitLiteralExpression(LiteralExpression literal);
  R visitVariableExpression(VariableExpression variable);
}

sealed class Expression(final BaseType type) {
  R accept<R>(ExpressionVisitor<R> visitor);
}

class UnaryExpression(final Token operator, final Expression right) implements Expression {
  @override
  R accept<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitUnaryExpression(this);
  }

  @override
  BaseType get type => right.type;
}

class BinaryExpression(super.type, final Expression left, final Token operator, final Expression right)
    extends Expression {
  @override
  R accept<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitBinaryExpression(this);
  }
}

class GroupingExpression(final Expression expression) implements Expression {
  @override
  R accept<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitGroupingExpression(this);
  }

  @override
  BaseType get type => expression.type;
}

class LiteralExpression(super.type, final Object value) extends Expression {
  @override
  R accept<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitLiteralExpression(this);
  }
}

class VariableExpression(super.type, final Token name) extends Expression {
  @override
  R accept<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitVariableExpression(this);
  }
}
