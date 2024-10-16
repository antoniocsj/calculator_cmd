enum DisplayFormat {
  automatic,
  fixed,
  scientific,
  engineering
}

enum AngleUnit {
  radians,
  degrees,
  gradians
}

enum ErrorCode {
  none,
  invalid,
  overflow,
  unknownVariable,
  unknownFunction,
  unknownConversion,
  mp
}

enum LexerTokenType {
  unknown, // Unknown

  // These are all Pre-Lexer tokens, returned by pre-lexer
  plDecimal, // Decimal separator
  plDigit, // Decimal digit
  plHex, // A-F of Hex digits
  plSuperDigit, // Super digits
  plSuperMinus, // Super minus
  plSubDigit, // Sub digits
  plFraction, // Fractions
  plDegree, // Degree
  plMinute, // Minutes
  plSecond, // Seconds
  plLetter, // Alphabets
  plEOS, // End of stream
  plSkip, // Skip this symbol (whitespace or newline)

  // These are all tokens, returned by Lexer
  add, // Plus
  subtract, // Minus
  multiply, // Multiply
  divide, // Divide
  mod, // Modulus
  lFloor, // Floor (Left)
  rFloor, // Floor (Right)
  lCeiling, // Ceiling (Left)
  rCeiling, // Ceiling (Right)
  root, // Square root
  root_3, // Cube root
  root_4, // Fourth root
  not, // Bitwise NOT
  and, // Bitwise AND
  or, // Bitwise OR
  xor, // Bitwise XOR
  in_, // IN (for converter e.g. 1 EUR in USD / 1 EUR to USD)
  number, // Number
  supNumber, // Super Number
  nSupNumber, // Negative Super Number
  subNumber, // Sub Number
  function, // Function
  unit, // Unit of conversion
  variable, // Variable name
  shiftLeft, // Shift left
  shiftRight, // Shift right
  assign, // =
  lRBracket, // (
  rRBracket, // )
  lSBracket, // [
  rSBracket, // ]
  lCBracket, // {
  rCBracket, // }
  abs, // |
  power, // ^
  factorial, // !
  percentage, // %
  argumentSeparator, // ; (Function argument separator)
  funcDescSeparator // @ (Function description separator)
}


enum Associativity {
  left,
  right
}

enum Precedence {
  unknown(0),
  convert(0), // Conversion node
  unit(1), // Unit for conversion
  top(2), // Highest precedence of any operator in current level. Only conversion should be above this node in same depth level.
  addSubtract(3),
  multiply(4), // MOD and DIVIDE must have same preedence.
  mod(5),
  divide(5),
  not(6),
  function(7),
  boolean(8),
  shift(8),
  percentage(9),
  unaryMinus(10), // UNARY_MINUS, ROOT and POWER must have same precedence.
  power(10),
  root(10),
  factorial(11),
  numberVariable(12),
  depth(13); // DEPTH should be always at the bottom. It stops node jumping off the current depth level.

  final int value;
  const Precedence(this.value);

  static Precedence fromValue(int value) {
    return Precedence.values.firstWhere(
          (e) => e.value == value,
      orElse: () => throw ArgumentError("Unknown value for Precedence: $value"),
    );
  }
}

enum NumberMode {
  normal,
  superscript,
  subscript
}


void main() {
  Precedence p = Precedence.unaryMinus;
  print('Precedence: $p, value: ${p.value} ${p.index}');

  p = Precedence.root;
  print('Precedence: $p, value: ${p.value} ${p.index}');
}






