import 'package:calculator/enums.dart';
import 'package:calculator/number.dart';
import 'package:calculator/equation_parser.dart';

class MathFunction {
  final String _name;
  final List<String> _arguments;
  final String? _expression;
  final String? _description;

  String get name => _name;
  List<String> get arguments => _arguments;
  String? get expression => _expression;
  String? get description => _description;

  MathFunction(this._name, this._arguments, this._expression, this._description);

  static int nameCompareFunc(MathFunction function1, MathFunction function2) {
    return function1.name.compareTo(function2.name);
  }

  static bool nameEqualFunc(MathFunction function1, MathFunction function2) {
    return function1.name == function2.name;
  }

  Number? evaluate(List<Number> args, [Parser? rootParser]) {
    var parser = FunctionParser(this, rootParser, args);

    int representationBase;
    ErrorCode errorCode;
    String? errorToken;
    int errorStart;
    int errorEnd;

    var ans = parser.parse(out representationBase, out errorCode, out errorToken, out errorStart, out errorEnd);
    if (errorCode == ErrorCode.none) {
      return ans;
    }

    rootParser?.setError(errorCode, errorToken, errorStart, errorEnd);
    return null;
  }

  bool validate([Parser? rootParser]) {
    if (!isNameValid(name)) {
      rootParser?.setError(ErrorCode.invalid);
      return false;
    }
    for (var argument in arguments) {
      if (!isNameValid(argument)) {
        rootParser?.setError(ErrorCode.invalid);
        return false;
      }
    }

    var args = <Number>[];
    var parser = FunctionParser(this, rootParser, args);

    int representationBase;
    ErrorCode errorCode;
    String? errorToken;
    int errorStart;
    int errorEnd;

    parser.createParseTree(out representationBase, out errorCode, out errorToken, out errorStart, out errorEnd);
    if (errorCode == ErrorCode.none) {
      return true;
    }

    rootParser?.setError(errorCode, errorToken, errorStart, errorEnd);
    return false;
  }

  bool isNameValid(String x) {
    for (var i = 0; i < x.length; i++) {
      var currentChar = x[i];
      if (!RegExp(r'^[a-zA-Z]$').hasMatch(currentChar)) {
        return false;
      }
    }
    return true;
  }

  bool isCustomFunction() {
    return true;
  }
}

class ExpressionParser extends Parser {
  final Parser? _rootParser;

  ExpressionParser(String expression, [this._rootParser]) : super(expression, _rootParser?.numberBase, _rootParser?.wordlen, _rootParser?.angleUnits);

  @override
  bool variableIsDefined(String name) {
    if (super.variableIsDefined(name)) {
      return true;
    }
    return _rootParser?.variableIsDefined(name) ?? false;
  }

  @override
  Number? getVariable(String name) {
    var value = super.getVariable(name);
    if (value != null) {
      return value;
    }
    return _rootParser?.getVariable(name);
  }

  @override
  bool functionIsDefined(String name) {
    if (super.functionIsDefined(name)) {
      return true;
    }
    return _rootParser?.functionIsDefined(name) ?? false;
  }
}

class FunctionParser extends ExpressionParser {
  final List<Number> _parameters;
  final MathFunction _function;

  FunctionParser(this._function, [Parser? rootParser, this._parameters = const []]) : super(_function.expression ?? '', rootParser);

  @override
  bool variableIsDefined(String name) {
    var argumentNames = _function.arguments;
    for (var i = 0; i < argumentNames.length; i++) {
      if (argumentNames[i] == name) {
        return true;
      }
    }
    return super.variableIsDefined(name);
  }

  @override
  Number? getVariable(String name) {
    var argumentNames = _function.arguments;
    for (var i = 0; i < argumentNames.length; i++) {
      if (argumentNames[i] == name) {
        if (_parameters.length > i) {
          return _parameters[i];
        }
        return null;
      }
    }
    return super.getVariable(name);
  }
}

class BuiltInMathFunction extends MathFunction {
  BuiltInMathFunction(String functionName, String? description)
      : super(functionName, [], '', description);

  @override
  Number? evaluate(List<Number> args, [Parser? rootParser]) {
    return evaluateBuiltInFunction(name, args, rootParser);
  }

  @override
  bool isCustomFunction() {
    return false;
  }
}

Number? evaluateBuiltInFunction(String name, List<Number> args, [Parser? rootParser]) {
  var lowerName = name.toLowerCase();
  var x = args[0];

  if (lowerName == 'log') {
    if (args.length <= 1) {
      return x.logarithm(10); // FIXME: Default to ln
    } else {
      var logBase = args[1].toInteger();
      if (logBase < 0) {
        return null;
      } else {
        return x.logarithm(logBase);
      }
    }
  } else if (lowerName == 'ln') {
    return x.ln();
  } else if (lowerName == 'sqrt') {
    return x.sqrt();
  } else if (lowerName == 'abs') {
    return x.abs();
  } else if (lowerName == 'sgn') {
    return x.sgn();
  } else if (lowerName == 'arg') {
    return x.arg(rootParser?.angleUnits);
  } else if (lowerName == 'conj') {
    return x.conjugate();
  } else if (lowerName == 'int') {
    return x.integerComponent();
  } else if (lowerName == 'frac') {
    return x.fractionalComponent();
  } else if (lowerName == 'floor') {
    return x.floor();
  } else if (lowerName == 'ceil') {
    return x.ceiling();
  } else if (lowerName == 'round') {
    return x.round();
  } else if (lowerName == 're') {
    return x.realComponent();
  } else if (lowerName == 'im') {
    return x.imaginaryComponent();
  } else if (lowerName == 'sin') {
    return x.sin(rootParser?.angleUnits);
  } else if (lowerName == 'cos') {
    return x.cos(rootParser?.angleUnits);
  } else if (lowerName == 'tan') {
    return x.tan(rootParser?.angleUnits);
  } else if (lowerName == 'sin⁻¹' || lowerName == 'asin') {
    return x.asin(rootParser?.angleUnits);
  } else if (lowerName == 'cos⁻¹' || lowerName == 'acos') {
    return x.acos(rootParser?.angleUnits);
  } else if (lowerName == 'tan⁻¹' || lowerName == 'atan') {
    return x.atan(rootParser?.angleUnits);
  } else if (lowerName == 'sinh') {
    return x.sinh();
  } else if (lowerName == 'cosh') {
    return x.cosh();
  } else if (lowerName == 'tanh') {
    return x.tanh();
  } else if (lowerName == 'sinh⁻¹' || lowerName == 'asinh') {
    return x.asinh();
  } else if (lowerName == 'cosh⁻¹' || lowerName == 'acosh') {
    return x.acosh();
  } else if (lowerName == 'tanh⁻¹' || lowerName == 'atanh') {
    return x.atanh();
  } else if (lowerName == 'ones') {
    return x.onesComplement(rootParser?.wordlen);
  } else if (lowerName == 'twos') {
    return x.twosComplement(rootParser?.wordlen);
  }
  return null;
}
