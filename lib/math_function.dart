import 'package:calculator/enums.dart';
import 'package:calculator/types.dart';
import 'package:calculator/number.dart';
import 'package:calculator/equation_parser.dart';

class MathFunction {
  final String _name;
  final List<String> _arguments;
  late final String? _expression;
  late final String? _description;

  String get name => _name;
  List<String> get arguments => _arguments;
  String? get expression => _expression;
  String? get description => _description;

  MathFunction(this._name, this._arguments, String? expression, String? description) {
    if (expression != null) {
      _expression = expression;
    }
    else {
      _expression = '';
    }
    if (description != null) {
      _description = description;
    }
    else {
      _description = '';
    }
  }

  static int nameCompareFunc(MathFunction function1, MathFunction function2) {
    return function1.name.compareTo(function2.name);
  }

  static bool nameEqualFunc(MathFunction function1, MathFunction function2) {
    return function1.name == function2.name;
  }

  Number? evaluate(List<Number> args, [Parser? rootParser]) {
    var parser = FunctionParser(this, rootParser, args);

    // variables to store the result of the parsing
    var representationBase = 10;
    var errorCode = ErrorCode.none;
    String? errorToken = '';
    var errorStart = 0;
    var errorEnd = 0;

    var parseResult = parser.parse();

    // update the variables from the parse result
    representationBase = parseResult.representationBase;
    errorCode = parseResult.errorCode;
    errorToken = parseResult.errorToken;
    errorStart = parseResult.errorStart;
    errorEnd = parseResult.errorEnd;

    var ans = parseResult.number;

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

    // variables to store the result of the parsing
    var representationBase = 10;
    var errorCode = ErrorCode.none;
    String? errorToken = '';
    var errorStart = 0;
    var errorEnd = 0;

    var createParseTreeResult = parser.createParseTree();

    // update the variables from the create parse tree result
    representationBase = createParseTreeResult.representationBase;
    errorCode = createParseTreeResult.errorCode;
    errorToken = createParseTreeResult.errorToken;
    errorStart = createParseTreeResult.errorStart;
    errorEnd = createParseTreeResult.errorEnd;

    if (errorCode == ErrorCode.none) {
      return true;
    }

    rootParser?.setError(errorCode, errorToken, errorStart, errorEnd);
    return false;
  }

  bool isNameValid(String x) {
    for (var i = 0; i < x.length; i++) {
      var currentChar = x[i];
      if (currentChar.isAlpha()) {
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

  ExpressionParser(String expression, [this._rootParser])
      : super(expression, _rootParser!.numberBase, _rootParser.wordlen, _rootParser.angleUnits);

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

  FunctionParser(this._function, [Parser? rootParser, this._parameters = const []])
      : super(_function.expression ?? '', rootParser);

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
  // FIXME: Re Im ?

  if (lowerName == 'log') {
    if (args.length <= 1) {
      return x.logarithm(10); // FIXME: Default to ln
    }
    else {
      var logBase = args[1].toInteger();
      if (logBase < 0) {
        return null;
      }
      else {
        return x.logarithm(logBase);
      }
    }
  } else if (lowerName == 'ln') {
    return x.ln();
  } else if (lowerName == 'sqrt') { // √x, square root
    return x.sqrt();
  } else if (lowerName == 'abs') { // |x|, absolute value
    return x.abs();
  } else if (lowerName == 'sgn') { // sgn(x), signum function
    return x.sgn();
  } else if (lowerName == 'arg') { // arg(x), argument
    return x.arg(rootParser!.angleUnits);
  } else if (lowerName == 'conj') { // conj(x), conjugate
    return x.conjugate();
  } else if (lowerName == 'int') { // int(x), integer part
    return x.integerComponent();
  } else if (lowerName == 'frac') { // frac(x), fractional part
    return x.fractionalComponent();
  } else if (lowerName == 'floor') { // floor(x), floor
    return x.floor();
  } else if (lowerName == 'ceil') { // ceil(x), ceiling
    return x.ceiling();
  } else if (lowerName == 'round') { // round(x), round
    return x.round();
  } else if (lowerName == 're') { // re(x), real part
    return x.realComponent();
  } else if (lowerName == 'im') { // im(x), imaginary part
    return x.imaginaryComponent();
  } else if (lowerName == 'sin') { // sin(x), sine
    return x.sin(rootParser!.angleUnits);
  } else if (lowerName == 'cos') { // cos(x), cosine
    return x.cos(rootParser!.angleUnits);
  } else if (lowerName == 'tan') { // tan(x), tangent
    return x.tan(rootParser!.angleUnits);
  } else if (lowerName == 'sin⁻¹' || lowerName == 'asin') { // sin⁻¹(x), arcsine
    return x.asin(rootParser!.angleUnits);
  } else if (lowerName == 'cos⁻¹' || lowerName == 'acos') { // cos⁻¹(x), arccosine
    return x.acos(rootParser!.angleUnits);
  } else if (lowerName == 'tan⁻¹' || lowerName == 'atan') { // tan⁻¹(x), arctangent
    return x.atan(rootParser!.angleUnits);
  } else if (lowerName == 'sinh') { // sinh(x), hyperbolic sine
    return x.sinh();
  } else if (lowerName == 'cosh') { // cosh(x), hyperbolic cosine
    return x.cosh();
  } else if (lowerName == 'tanh') { // tanh(x), hyperbolic tangent
    return x.tanh();
  } else if (lowerName == 'sinh⁻¹' || lowerName == 'asinh') { // sinh⁻¹(x), hyperbolic arcsine
    return x.asinh();
  } else if (lowerName == 'cosh⁻¹' || lowerName == 'acosh') { // cosh⁻¹(x), hyperbolic arccosine
    return x.acosh();
  } else if (lowerName == 'tanh⁻¹' || lowerName == 'atanh') { // tanh⁻¹(x), hyperbolic arctangent
    return x.atanh();
  } else if (lowerName == 'ones') { // ones(x), ones' complement
    return x.onesComplement(rootParser!.wordlen);
  } else if (lowerName == 'twos') { // twos(x), twos' complement
    return x.twosComplement(rootParser!.wordlen);
  }
  return null;
}
