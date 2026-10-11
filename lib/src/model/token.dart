enum TokenType {
  // single char tokens
  leftParenthesis,
  rightParenthesis,
  minus,
  plus,
  slash,
  star,
  less,
  greater,
  bang,
  semicolon,
  assign,

  // two char tokens
  equal,
  notEqual,
  lessEqual,
  greaterEqual,

  // literals
  string,
  integer,
  double,
  identifier,

  // keywords
  trueKeyword,
  falseKeyword,
  varKeyword,
  valKeyword,
  printKeyword,

  // end of file
  eof,
}

class TokenLocation(final int line, final int column);

class Token(
  final TokenType type,
  final String lexeme,
  final Object? literal,
  final TokenLocation location,
) {
  @override
  String toString() {
    return '${type.name}${lexeme.isNotEmpty ? ' "$lexeme"' : ''}';
  }
}
