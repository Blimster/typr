import 'package:typr/src/model/expression.dart';

abstract interface class StatementVisitor<R> {
  R visitPrintStatement(PrintStatement statement);
  R visitExpressionStatement(ExpressionStatement statement);
  R visitVarDeclarationStatement(VarDeclarationStatement statement);
  R visitValDeclarationStatement(ValDeclarationStatement statement);
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

class VarDeclarationStatement(final String name, final Expression initializer) extends Statement {
  @override
  R accept<R>(StatementVisitor<R> visitor) {
    return visitor.visitVarDeclarationStatement(this);
  }
}

class ValDeclarationStatement(final String name, final Expression initializer) extends Statement {
  @override
  R accept<R>(StatementVisitor<R> visitor) {
    return visitor.visitValDeclarationStatement(this);
  }
}
