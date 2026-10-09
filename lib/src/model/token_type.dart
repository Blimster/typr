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

  // end of file
  eof,
}
