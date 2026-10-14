sealed class BaseType(final String name, final BaseType? superType) {
  bool isAssignableWith(BaseType other) {
    if (name == other.name) {
      return true;
    }
    if (other.superType case var type?) {
      return isAssignableWith(type);
    }
    return false;
  }

  bool isType(BaseType other) {
    return other.isAssignableWith(this);
  }
}

final rootType = RootType._();
final boolType = BoolType._();
final stringType = StringType._();
final numType = NumType._();
final intType = IntType._();
final doubleType = DoubleType._();

class RootType extends BaseType {
  RootType._() : super('Type', null);
}

class BoolType extends BaseType {
  BoolType._() : super('Bool', rootType);
}

class StringType extends BaseType {
  StringType._() : super('String', rootType);
}

class NumType extends BaseType {
  NumType._() : super('Num', rootType);
}

class IntType extends BaseType {
  IntType._() : super('Int', numType);
}

class DoubleType extends BaseType {
  DoubleType._() : super('Double', numType);
}

class UserType extends BaseType {
  new(super.name, super.superType);
}
