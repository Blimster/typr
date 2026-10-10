import 'package:typr/src/model/token.dart';

final _alphaChars = {
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
};

final _keywords = {
  'print': TokenType.print,
  'true': TokenType.trueKeyword,
  'false': TokenType.falseKeyword,
};

class Scanner(final String _source) {
  final List<Token> _tokens = [];
  int _start = 0;
  int _current = 0;
  int _line = 1;
  int _column = 1;

  List<Token> scanTokens() {
    while (!_isAtEnd()) {
      _start = _current;
      _scanToken();
    }

    _tokens.add(Token(.eof, "", null, TokenLocation(_line, _column)));

    return _tokens;
  }

  void _scanToken() {
    final currentLocation = _currentLocation();

    final char = _advance();
    switch (char) {
      case '(':
        _tokens.add(Token(.leftParenthesis, '(', null, currentLocation));
      case ')':
        _tokens.add(Token(.rightParenthesis, ')', null, currentLocation));
      case '+':
        _tokens.add(Token(.plus, '+', null, currentLocation));
      case '-':
        _tokens.add(Token(.minus, '-', null, currentLocation));
      case '*':
        _tokens.add(Token(.star, '*', null, currentLocation));
      case '/':
        _tokens.add(Token(.slash, '/', null, currentLocation));
      case ';':
        _tokens.add(Token(.semicolon, ';', null, currentLocation));
      case '=':
        if (_match('=')) {
          _tokens.add(Token(.equal, '==', null, currentLocation));
        } else {
          throw StateError(
            'Unexpected character: $char at line ${currentLocation.line}, column ${currentLocation.column}',
          );
        }
      case '!':
        if (_match('=')) {
          _tokens.add(Token(.notEqual, '!=', null, currentLocation));
        } else {
          _tokens.add(Token(.bang, '!', null, currentLocation));
        }
      case '<':
        if (_match('=')) {
          _tokens.add(Token(.lessEqual, '<=', null, currentLocation));
        } else {
          _tokens.add(Token(.less, '<', null, currentLocation));
        }
        break;
      case '>':
        if (_match('=')) {
          _tokens.add(Token(.greaterEqual, '>=', null, currentLocation));
        } else {
          _tokens.add(Token(.greater, '>', null, currentLocation));
        }
        break;
      case '\n':
        _line++;
        _column = 1;
      case ' ':
      case '\t':
      case '\r':
        break;
      case '"':
      case "'":
        _string(char);
      default:
        if (_isDigit(char)) {
          _number();
        } else if (_isAlpha(char)) {
          _identifierOrKeyword();
        } else {
          throw StateError('Unexpected character: $char at line $_line, column ${_column - 1}');
        }
    }
  }

  bool _isAtEnd() {
    return _current >= _source.length;
  }

  String _advance() {
    final char = _source[_current];

    _current++;
    _column++;

    if (char == '\n') {
      _line++;
      _column = 1;
    }

    return char;
  }

  bool _match(String expected) {
    if (_isAtEnd()) {
      return false;
    }
    if (_source[_current] != expected) {
      return false;
    }

    _current++;

    return true;
  }

  String _peek() {
    if (_isAtEnd()) {
      return '';
    }
    return _source[_current];
  }

  String _peekNext() {
    if (_current + 1 >= _source.length) {
      return '';
    }
    return _source[_current + 1];
  }

  TokenLocation _currentLocation() {
    return TokenLocation(_line, _column);
  }

  bool _isDigit(String char) {
    return int.tryParse(char) != null;
  }

  bool _isAlpha(String char) {
    return _alphaChars.contains(char);
  }

  bool _isAlphaNumeric(String char) {
    return _isAlpha(char) || _isDigit(char);
  }

  void _string(String quoteType) {
    final currentLocation = _currentLocation();

    while (_peek() != quoteType && !_isAtEnd()) {
      if (_peek() == '\n') {
        _line++;
        _column = 1;
      }
      _advance();
    }

    if (_isAtEnd()) {
      throw StateError('Unterminated string at line $_line, column $_column');
    }

    _advance();

    String value = _source.substring(_start + 1, _current - 1);
    _tokens.add(Token(.string, value, value, currentLocation));
  }

  void _number() {
    final currentLocation = _currentLocation();

    while (_isDigit(_peek())) {
      _advance();
    }

    if (_peek() == '.' && _isDigit(_peekNext())) {
      _advance();

      while (_isDigit(_peek())) {
        _advance();
      }
    }

    final literal = _source.substring(_start, _current);
    if (literal.contains('.')) {
      _tokens.add(Token(.double, literal, double.parse(literal), currentLocation));
    } else {
      _tokens.add(Token(.integer, literal, int.parse(literal), currentLocation));
    }
  }

  void _identifierOrKeyword() {
    final currentLocation = _currentLocation();

    while (_isAlphaNumeric(_peek())) {
      _advance();
    }

    final text = _source.substring(_start, _current);
    final tokenType = _keywords[text] ?? .identifier;
    _tokens.add(Token(tokenType, text, null, currentLocation));
  }
}
