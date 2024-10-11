import 'dart:collection';
import 'dart:io';
import 'dart:async';
import 'package:calculator/enums.dart';
import 'package:calculator/number.dart';
import 'package:calculator/types.dart';
import 'package:calculator/math_function.dart';
import 'package:calculator/serializer.dart';
import 'package:calculator/equation_parser.dart';

FunctionManager? defaultFunctionManager;

class FunctionManager {
  final String fileName;
  final HashMap<String, MathFunction> functions;
  final Serializer serializer;

  final StreamController<MathFunction> _functionAddedController = StreamController<MathFunction>.broadcast();
  final StreamController<MathFunction> _functionEditedController = StreamController<MathFunction>.broadcast();
  final StreamController<MathFunction> _functionRemovedController = StreamController<MathFunction>.broadcast();

  static final _finalizerAddedController = Finalizer<StreamController>((controller) {
    print('Disposing _functionAddedController');
    controller.close();
  });

  static final _finalizerEditedController = Finalizer<StreamController>((controller) {
    print('Disposing _functionEditedController');
    controller.close();
  });

  static final _finalizerRemovedController = Finalizer<StreamController>((controller) {
    print('Disposing _functionRemovedController');
    controller.close();
  });

  Stream<MathFunction> get functionAdded => _functionAddedController.stream;
  Stream<MathFunction> get functionEdited => _functionEditedController.stream;
  Stream<MathFunction> get functionRemoved => _functionRemovedController.stream;

  FunctionManager()
      : fileName = '${Directory.systemTemp.path}/calculator/custom-functions',
        functions = HashMap<String, MathFunction>(),
        serializer = Serializer(DisplayFormat.scientific, 10, 50) {
    serializer.setRadix('.');
    reloadFunctions();

    _finalizerAddedController.attach(this, _functionAddedController, detach: this);
    _finalizerEditedController.attach(this, _functionEditedController, detach: this);
    _finalizerRemovedController.attach(this, _functionRemovedController, detach: this);
  }

  static FunctionManager getDefaultFunctionManager() {
    defaultFunctionManager ??= FunctionManager();
    return defaultFunctionManager!;
  }

  void reloadFunctions() {
    functions.clear();
    reloadCustomFunctions();
    reloadBuiltinFunctions();
  }

  void reloadBuiltinFunctions() {
    add(BuiltInMathFunction('log', 'Logarithm'));
    add(BuiltInMathFunction('ln', 'Natural logarithm'));
    add(BuiltInMathFunction('sqrt', 'Square root'));
    add(BuiltInMathFunction('abs', 'Absolute value'));
    add(BuiltInMathFunction('sgn', 'Signum'));
    add(BuiltInMathFunction('arg', 'Argument'));
    add(BuiltInMathFunction('conj', 'Conjugate'));
    add(BuiltInMathFunction('int', 'Integer'));
    add(BuiltInMathFunction('frac', 'Fraction'));
    add(BuiltInMathFunction('floor', 'Floor'));
    add(BuiltInMathFunction('ceil', 'Ceiling'));
    add(BuiltInMathFunction('round', 'Round'));
    add(BuiltInMathFunction('re', 'Real'));
    add(BuiltInMathFunction('im', 'Imaginary'));
    add(BuiltInMathFunction('sin', 'Sine'));
    add(BuiltInMathFunction('cos', 'Cosine'));
    add(BuiltInMathFunction('tan', 'Tangent'));
    add(BuiltInMathFunction('asin', 'Arc sine'));
    add(BuiltInMathFunction('acos', 'Arc cosine'));
    add(BuiltInMathFunction('atan', 'Arc tangent'));
    add(BuiltInMathFunction('sin⁻¹', 'Inverse sine'));
    add(BuiltInMathFunction('cos⁻¹', 'Inverse cosine'));
    add(BuiltInMathFunction('tan⁻¹', 'Inverse tangent'));
    add(BuiltInMathFunction('sinh', 'Hyperbolic sine'));
    add(BuiltInMathFunction('cosh', 'Hyperbolic cosine'));
    add(BuiltInMathFunction('tanh', 'Hyperbolic tangent'));
    add(BuiltInMathFunction('sinh⁻¹', 'Hyperbolic arcsine'));
    add(BuiltInMathFunction('cosh⁻¹', 'Hyperbolic arccosine'));
    add(BuiltInMathFunction('tanh⁻¹', 'Hyperbolic arctangent'));
    add(BuiltInMathFunction('asinh', 'Inverse hyperbolic sine'));
    add(BuiltInMathFunction('acosh', 'Inverse hyperbolic cosine'));
    add(BuiltInMathFunction('atanh', 'Inverse hyperbolic tangent'));
    add(BuiltInMathFunction('ones', 'One\'s complement'));
    add(BuiltInMathFunction('twos', 'Two\'s complement'));
  }

  void reloadCustomFunctions() {
    try {
      final data = File(fileName).readAsStringSync();
      final lines = data.split('\n');
      for (var line in lines) {
        final function = parseFunctionFromString(line);
        if (function != null) {
          functions[function.name] = function;
        }
      }
    } catch (e) {
      return;
    }
  }

  MathFunction? parseFunctionFromString(String? data) {
    // pattern: <name> (<a1>;<a2>;<a3>;...) = <expression> @ <description>

    if (data == null) return null;

    final i = data.indexOf('=');
    if (i < 0) return null;
    final left = data.substring2(0, i).trim();
    final right = data.substring2(i + 1).trim();
    if (left.isEmpty || right.isEmpty) return null;

    var expression = '';
    var description = '';
    final j = right.indexOf('@');
    if (j < 0) {
      expression = right;
    }
    else {
      expression = right.substring2(0, j).trim();
      description = right.substring2(j + 1).trim();
    }
    if (expression.isEmpty) return null;

    final k = left.indexOf('(');
    if (k < 0) return null;
    final name = left.substring2(0, k).trim();
    var argumentList = left.substring2(k + 1).trim();
    if (name.isEmpty || argumentList.isEmpty) return null;

    argumentList = argumentList.replaceAll(')', '');
    final arguments = argumentList.split(';');

    return MathFunction(name, arguments, expression, description);
  }

  void save() {
    final data = StringBuffer();
    functions.forEach((name, mathFunction) {
      if (!mathFunction.isCustomFunction()) return;
      data.write('${mathFunction.name}(${mathFunction.arguments.join(';')})=${mathFunction.expression}@${mathFunction.description}\n');
    });

    final dir = Directory(fileName).parent;
    dir.createSync(recursive: true);
    File(fileName).writeAsStringSync(data.toString());
  }

  List<String> arraySortString(List<String> array) {
    array.sort((a, b) => b.compareTo(a));
    return array;
  }

  List<String> getNames() {
    final names = functions.keys.toList();
    return arraySortString(names);
  }

  bool add(MathFunction newFunction) {
    final existingFunction = get(newFunction.name);
    if (existingFunction != null && !existingFunction.isCustomFunction()) return false;

    functions[newFunction.name] = newFunction;
    if (existingFunction != null) {
      // Emit function_edited signal
      _functionEditedController.add(newFunction);
    } else {
      // Emit function_added signal
      _functionAddedController.add(newFunction);
    }

    return true;
  }

  bool addFunctionWithProperties(String name, String arguments, String description, [Parser? rootParser]) {
    final functionString = '$name($arguments)=$description';
    final newFunction = parseFunctionFromString(functionString);

    if (newFunction == null || !newFunction.validate(rootParser)) {
      rootParser?.setError(ErrorCode.invalid);
      return false;
    }

    final isFunctionAdded = add(newFunction);
    if (isFunctionAdded) save();

    return isFunctionAdded;
  }

  MathFunction? get(String name) {
    return functions[name] ?? functions[name.toLowerCase()];
  }

  void delete(String name) {
    final function = get(name);
    if (function != null && function.isCustomFunction()) {
      functions.remove(name);
      save();
      // Emit function_deleted signal
      _functionRemovedController.add(function);
    }
  }

  bool isFunctionDefined(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.startsWith('log') && int.tryParse(lowerName.substring2(3)) != null) return true;
    return functions.containsKey(name) || functions.containsKey(lowerName);
  }

  Number? evaluateFunction(String name, List<Number> arguments, Parser parser) {
    var lowerName = name.toLowerCase();
    var args = arguments;
    if (lowerName.startsWith('log') && int.tryParse(lowerName.substring2(3)) != null) {
      final logBase = Number.fromInt(int.parse(lowerName.substring2(3)));
      args = [...args, logBase];
      name = 'log';
    }

    final function = get(name);
    if (function == null) {
      parser.setError(ErrorCode.unknownFunction);
      return null;
    }

    return function.evaluate(args, parser);
  }

  List<MathFunction> arraySortMathFunction(List<MathFunction> array) {
    array.sort((a, b) => a.name.compareTo(b.name));
    return array;
  }

  List<MathFunction> functionsEligibleForAutocompletionForText(String displayText) {
    final eligibleFunctions = <MathFunction>[];
    final displayTextCaseInsensitive = displayText.toLowerCase();
    functions.forEach((functionName, function) {
      if (functionName.toLowerCase().startsWith(displayTextCaseInsensitive)) {
        eligibleFunctions.add(function);
      }
    });
    return arraySortMathFunction(eligibleFunctions);
  }

  void dispose() {
    _finalizerAddedController.detach(this);
    _finalizerEditedController.detach(this);
    _finalizerRemovedController.detach(this);
    _functionAddedController.close();
    _functionEditedController.close();
    _functionRemovedController.close();
  }
}
