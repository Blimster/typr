import 'package:typr/src/model/expression.dart';

abstract interface class StatementVisitor<R> {
  R visitPrintStatement(PrintStatement statement);
  R visitExpressionStatement(ExpressionStatement statement);
}

sealed class Statement {
  R accept<R>(StatementVisitor<R> visitor);
}

class PrintStatement(final Expression expression) extends Statement {
  @override
  R accept<R>(StatementVisitor<R> visitor) {
    return visitor.visitPrintStatement(this);
  }
}

class ExpressionStatement(final Expression expression) extends Statement {
  @override
  R accept<R>(StatementVisitor<R> visitor) {
    return visitor.visitExpressionStatement(this);
  }
}
