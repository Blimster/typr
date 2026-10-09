import 'package:typr/src/model/token.dart';

abstract interface class ExpressionVisitor<R> {
  R visitUnary(Unary unary);
  R visitBinary(Binary binary);
  R visitGrouping(Grouping grouping);
  R visitLiteral(Literal literal);
}

sealed class Expression {
  R accept<R>(ExpressionVisitor<R> visitor);
}

class Unary(final Token operator, final Expression right) implements Expression {
  @override
  R accept<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitUnary(this);
  }
}

class Binary(final Expression left, final Token operator, final Expression right) implements Expression {
  @override
  R accept<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitBinary(this);
  }
}

class Grouping(final Expression expression) implements Expression {
  @override
  R accept<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitGrouping(this);
  }
}

class Literal(final Object value) implements Expression {
  @override
  R accept<R>(ExpressionVisitor<R> visitor) {
    return visitor.visitLiteral(this);
  }
}
