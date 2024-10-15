import 'package:calculator/enums.dart';
import 'package:calculator/number.dart';
import 'package:calculator/types.dart';
import 'package:calculator/equation_parser.dart';
import 'package:calculator/function_manager.dart';
import 'package:calculator/unit.dart';

int subAtoi(String data) {
  const List<String> digits = ['₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];
  int value = 0;

  int index = 0;
  String c;
  RefInt refIndex = RefInt(index);
  RefString refChar = RefString('');

  while (data.getNextChar(refIndex, refChar)) {
    index = refIndex.value;
    c = refChar.value;

    bool isSubdigit = false;
    for (int i = 0; i < digits.length; i++) {
      if (c == digits[i]) {
        value = value * 10 + i;
        isSubdigit = true;
        break;
      }
    }
    if (!isSubdigit) return -1;
  }
  index = refIndex.value;
  c = refChar.value;

  return value;
}

int superAtoi(String data) {
  const List<String> digits = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];

  int index = 0;
  String c;
  RefInt refIndex = RefInt(index);
  RefString refChar = RefString('');

  data.getNextChar(refIndex, refChar);
  index = refIndex.value;
  c = refChar.value;

  int sign = 1;

  if (c == '⁻') {
    sign = -1;
  } else {
    index = 0;
    refIndex.value = index;
  }

  int value = 0;
  while (data.getNextChar(refIndex, refChar)) {
    index = refIndex.value;
    c = refChar.value;

    bool isSuperdigit = false;
    for (int i = 0; i < digits.length; i++) {
      if (c == digits[i]) {
        value = value * 10 + i;
        isSuperdigit = true;
        break;
      }
    }
    if (!isSuperdigit) return 0;
  }
  index = refIndex.value;
  c = refChar.value;

  return sign * value;
}

String mpErrorCodeToString(ErrorCode errorCode) {
  return errorCode.toString().replaceAll('ErrorCode.', '');
}

class Equation {
  int base;
  int wordlen;
  AngleUnit angleUnits;
  String expression;

  Equation(this.expression, {this.base = 10, this.wordlen = 32, this.angleUnits = AngleUnit.degrees});

  Number? parse({
    RefInt? representationBase,
    RefErrorCode? errorCode,
    RefString? errorToken,
    RefInt? errorStart,
    RefInt? errorEnd,
  }) {
    var parser = EquationParser(this, expression);
    Number.error = null;

    var result = parser.parse();

    representationBase?.value = result.representationBase;
    errorCode?.value = result.errorCode;
    errorToken?.value = result.errorToken??'';
    errorStart?.value = result.errorStart;
    errorEnd?.value = result.errorEnd;

    var z = result.number;

    /* Error during parsing */
    if (result.errorCode != ErrorCode.none) {
      return null;
    }

    if (Number.error != null) {
      errorCode?.value = ErrorCode.mp;
      return null;
    }

    return z;
  }

  bool variableIsDefined(String name) {
    return false;
  }

  Number? getVariable(String name) {
    return null;
  }

  bool unitIsDefined(String name) {
    return false;
  }

  bool literalBaseIsDefined(String name) {
    return false;
  }

  void setVariable(String name, Number x) {}

  bool functionIsDefined(String name) {
    return false;
  }

  Number? convert(Number x, String xUnits, String zUnits) {
    return null;
  }
}

class ConvertEquation extends Equation {
  ConvertEquation(super.text);

  @override
  Number? convert(Number x, String xUnits, String zUnits) {
    return UnitManager.getDefault().convertBySymbol(x, xUnits, zUnits);
  }
}

class EquationParser extends Parser {
  Equation equation;

  EquationParser(this.equation, String expression) :
        super(expression, equation.base, equation.wordlen, equation.angleUnits) {
    equation = equation;
  }

  @override
  bool variableIsDefined(String name) {
    if (Parser.constants.containsKey(name)) return true;
    return equation.variableIsDefined(name);
  }

  @override
  Number? getVariable(String name) {
    if (Parser.constants.containsKey(name)) {
      return Parser.constants[name];
    } else {
      return equation.getVariable(name);
    }
  }

  @override
  void setVariable(String name, Number x) {
    // Reserved words, e, π, mod, and, or, xor, not, abs, log, ln, sqrt, int, frac, sin, cos, ...
    if (Parser.constants.containsKey(name)) {
      return; // False
    }

    equation.setVariable(name, x);
  }

  // FIXME: Accept "2sin" not "2 sin", i.e. let the tokenizer collect the multiple
  // Parser then distinguishes between "sin"="s*i*n" or "sin5" = "sin 5" = "sin (5)"
  // i.e. numbers+letters = variable or function depending on following arg
  // letters+numbers = numbers+letters+numbers = function

  @override
  bool functionIsDefined(String name) {
    var functionManager = FunctionManager.getDefaultFunctionManager();
    if (functionManager.isFunctionDefined(name)) return true;
    return equation.functionIsDefined(name);
  }

  @override
  bool unitIsDefined(String name) {
    if (name == 'hex' || name == 'hexadecimal' || name == 'dec' || name == 'decimal' || name == 'oct' || name == 'octal' || name == 'bin' || name == 'binary') {
      return true;
    }

    var unitManager = UnitManager.getDefault();
    if (unitManager.unitIsDefined(name)) return true;
    return equation.unitIsDefined(name);
  }

  @override
  Number? convert(Number x, String xUnits, String zUnits) {
    return equation.convert(x, xUnits, zUnits);
  }

  @override
  bool literalBaseIsDefined(String name) {
    if (name == '0x' || name == '0b' || name == '0o') return true;
    return equation.literalBaseIsDefined(name);
  }
}
