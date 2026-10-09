import 'package:typr/src/model/expression.dart';

class AstPrinter implements ExpressionVisitor<String> {
  @override
  String visitBinary(Binary binary) {
    return '[${binary.operator.lexeme} ${binary.left.accept(this)} ${binary.right.accept(this)}]';
  }

  @override
  String visitGrouping(Grouping grouping) {
    return '[() ${grouping.expression.accept(this)}]';
  }

  @override
  String visitLiteral(Literal literal) {
    return literal.value.toString();
  }

  @override
  String visitUnary(Unary unary) {
    return '[${unary.operator.lexeme} ${unary.right.accept(this)}]';
  }
}
