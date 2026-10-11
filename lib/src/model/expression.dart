import 'package:typr/src/model/token.dart';

abstract interface class ExpressionVisitor<R> {
  R visitUnaryExpression(UnaryExpression unary);
  R visitBinaryExpression(BinaryExpression binary);
  R visitGroupingExpression(GroupingExpression grouping);
  R visitLiteralExpression(LiteralExpression literal);
  R visitVariableExpression(VariableExpression variable);
}

sealed class Expression {
  R accept<R>(ExpressionVisitor<R> visitor);
}

class UnaryExpression(final Token operator, final Expression right) implements Expression {
  @override
  R accept<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitUnaryExpression(this);
  }
}

class BinaryExpression(final Expression left, final Token operator, final Expression right) implements Expression {
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
}

class LiteralExpression(final Object value) implements Expression {
  @override
  R accept<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitLiteralExpression(this);
  }
}

class VariableExpression(final Token name) implements Expression {
  @override
  R accept<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitVariableExpression(this);
  }
}
