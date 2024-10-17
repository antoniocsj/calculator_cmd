import 'package:calculator/enums.dart';
import 'package:calculator/equation.dart';
import 'package:calculator/equation_lexer.dart';
import 'package:calculator/number.dart';
import 'package:calculator/types.dart';
import 'package:calculator/function_manager.dart';
import 'package:calculator/math_function.dart';

class ParseNode {
  Parser parser;
  ParseNode? parent;
  ParseNode? left;
  ParseNode? right;
  List<LexerToken> tokenList;
  int precedence;
  Associativity associativity;
  String? value;

  ParseNode.withList(this.parser, this.tokenList, this.precedence, this.associativity, [this.value]);

  ParseNode(this.parser, LexerToken? token, this.precedence, this.associativity, [this.value])
      : tokenList = [if (token != null) token];

  LexerToken get token {
    assert(tokenList.length == 1);
    return tokenList.first;
  }

  LexerToken get firstToken => tokenList.first;

  LexerToken get lastToken => tokenList.last;

  Number? solve() {
    return null;
  }
}

abstract class RNode extends ParseNode {
  RNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solve() {
    var r = right?.solve();
    if (r == null) return null;
    var z = solveR(r);

    // check for errors
    Number.checkFlags();
    if (Number.error != null) {
      var tmpleft = right;
      var tmpright = right;
      while (tmpleft?.left != null) {
        tmpleft = tmpleft?.left;
      }
      while (tmpright?.right != null) {
        tmpright = tmpright?.right;
      }
      parser.setError(ErrorCode.mp, Number.error, tmpleft!.firstToken.startIndex, tmpright!.lastToken.endIndex);
      Number.error = null;
    }
    return z;
  }

  Number? solveR(Number r);
}

abstract class LRNode extends ParseNode {
  LRNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solve() {
    var l = left?.solve();
    var r = right?.solve();
    if (l == null || r == null) return null;
    var z = solveLR(l, r);

    // check for errors
    Number.checkFlags();
    if (Number.error != null) {
      var tmpleft = left;
      var tmpright = right;
      while (tmpleft?.left != null) {
        tmpleft = tmpleft?.left;
      }
      while (tmpright?.right != null) {
        tmpright = tmpright?.right;
      }
      parser.setError(ErrorCode.mp, Number.error, tmpleft!.firstToken.startIndex, tmpright!.lastToken.endIndex);
      Number.error = null;
    }
    return z;
  }

  Number solveLR(Number left, Number r);
}

class ConstantNode extends ParseNode {
  ConstantNode(super.parser, super.token, super.precedence, super.associativity) {
    // print('ConstantNode: ${token.text}, ${token.type}, $precedence, $associativity');
  }

  @override
  Number? solve() {
    // print('ConstantNode.solve');
    return mpSetFromString(token.text, parser.numberBase);
  }
}

class AssignNode extends RNode {
  AssignNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solveR(Number r) {
    parser.setVariable(left!.token.text, r);
    return r;
  }
}

class AssignFunctionNode extends ParseNode {
  AssignFunctionNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solve() {
    if (left == null || right == null || left?.left == null || left?.right == null) return null;

    var functionName = left!.left!.value;
    var arguments = left!.right!.value;
    var description = right!.value;

    var functionManager = FunctionManager.getDefaultFunctionManager();
    if (functionManager.addFunctionWithProperties(functionName!, arguments!, description!, parser)) {
      return Number.fromInt(0);
    }

    return null;
  }
}

class NameNode extends ParseNode {
  NameNode(super.parser, super.token, super.precedence, super.associativity, [super.text]);
  NameNode.withList(super.parser, super.tokenList, super.precedence, super.associativity, String super.text)
      : super.withList();
}

class VariableNode extends ParseNode {
  VariableNode(super.parser, super.token, super.precedence,
      super.associativity);

  @override
  Number? solve() {
    /* If defined, then get the variable */
    var ans = parser.getVariable(token.text);
    if (ans != null) return ans;

    /* If has more than one character then assume a multiplication of variables */
    // FIXME: Do this in the lexer
    var value = Number.fromInt(1);

    var index = 0;
    String c = '';
    RefInt rIndex = RefInt(index);
    RefString rC = RefString('');

    while (token.text.getNextChar(rIndex, rC)) {
      index = rIndex.value;
      c = rC.value;

      var t = parser.getVariable(c);
      if (t == null) {
        parser.setError(
            ErrorCode.unknownVariable, token.text, firstToken.startIndex,
            lastToken.endIndex);
        return null;
      }
      value = value.multiply(t);
    }
    index = rIndex.value;
    c = rC.value;

    return value;
  }
}

class VariableWithPowerNode extends ParseNode {
  VariableWithPowerNode(super.parser, super.token, super.precedence, super.associativity, String super.text);

  @override
  Number? solve() {
    var pow = superAtoi(this.value!);

    this.value = null;

    /* If defined, then get the variable */
    var ans = parser.getVariable(token.text);
    if (ans != null) return ans.xpowyInteger(pow);

    /* If has more than one character then assume a multiplication of variables */
    // FIXME: Do in lexer
    var value = Number.fromInt(1);

    var index = 0;
    String c;
    RefInt rIndex = RefInt(index);
    RefString rC = RefString('');

    while (token.text.getNextChar(rIndex, rC)) {
      index = rIndex.value;
      c = rC.value;

      var t = parser.getVariable(c);
      if (t == null) {
        parser.setError(ErrorCode.unknownVariable, token.text, firstToken.startIndex, lastToken.endIndex);
        return null;
      }

      /* If last term do power */
      var i = index;
      String next;

      var rI = RefInt(i);
      var rNext = RefString('');

      if (!token.text.getNextChar(rI, rNext)) {
        i = rI.value;
        next = rNext.value;
        t = t.xpowyInteger(pow);
      }
      i = rI.value;
      next = rNext.value;

      value = value.multiply(t);
    }
    index = rIndex.value;
    c = rC.value;

    /* check for errors */
    Number.checkFlags();
    if (Number.error != null) {
      var tmpleft = left;
      var tmpright = right;
      while (tmpleft?.left != null) {
        tmpleft = tmpleft?.left;
      }
      while (tmpright?.right != null) {
        tmpright = tmpright?.right;
      }
      parser.setError(ErrorCode.mp, Number.error, tmpleft!.firstToken.startIndex, tmpright!.lastToken.endIndex);
      Number.error = null;
    }

    return value;
  }
}

class FunctionNameNode extends NameNode {
  FunctionNameNode(super.parser, super.token, super.precedence, super.associativity, String super.name);
}

class FunctionArgumentsNode extends NameNode {
  FunctionArgumentsNode(super.parser, super.tokenList, super.precedence, super.associativity, super.arguments)
      : super.withList();
}

class FunctionDescriptionNode extends NameNode {
  FunctionDescriptionNode(super.parser, super.token, super.precedence, super.associativity, String super.description);
}

class FunctionNode extends ParseNode {
  FunctionNode(super.parser, super.token, super.precedence, super.associativity, [super.text]);

  @override
  Number? solve() {
    if (right == null || left == null) {
      parser.setError(ErrorCode.unknownFunction);
      return null;
    }

    var name = left!.value;
    if (name == null) {
      parser.setError(ErrorCode.unknownFunction);
      return null;
    }

    var pow = 1;
    if (value != null) pow = superAtoi(value!);

    if (pow < 0) {
      name = '$name⁻¹';
      pow = -pow;
    }

    var args = <Number>[];
    if (right is FunctionArgumentsNode) {
      var argumentList = right!.value;
      var temp = '';
      var depth = 0;
      for (var i = 0; i < argumentList!.length; i++) {
        var ss = argumentList.substring2(i, 1);
        if (ss == '(') {
          depth++;
        }
        else if (ss == ')') {
          depth--;
        }
        else if (ss == ';' && depth != 0) {
          ss = '\$';
        }
        temp += ss;
      }
      var arguments = temp.split(';');

      for (var argument in arguments) {
        argument = argument.replaceAll('\$', ';').trim();
        var argumentParser = ExpressionParser(argument, parser);

        var representationBase = 0;
        var errorCode = ErrorCode.none;
        String? errorToken = '';
        var errorStart = 0;
        var errorEnd = 0;

        ParseResult result = argumentParser.parse();
        var ans = result.number;
        representationBase = result.representationBase;
        errorCode = result.errorCode;
        errorToken = result.errorToken;
        errorStart = result.errorStart;

        if (errorCode == ErrorCode.none && ans != null) {
          args.add(ans);
        }
        else {
          parser.setError(ErrorCode.unknownVariable, errorToken!, errorStart, errorEnd);
          return null;
        }
      }
    }
    else {
      var ans = right!.solve();
      if (ans != null) {
        args.add(ans);
      }
      else {
        parser.setError(ErrorCode.unknownFunction);
        return null;
      }
    }

    var functionManager = FunctionManager.getDefaultFunctionManager();
    var tmp = functionManager.evaluateFunction(name, args, parser);

    if (tmp != null) {
      tmp = tmp.xpowyInteger(pow);
    }

    /* check for errors */
    Number.checkFlags();
    if (Number.error != null) {
      parser.setError(ErrorCode.mp, Number.error, right!.firstToken.startIndex, right!.lastToken.endIndex);
      Number.error = null;
    }

    return tmp;
  }
}

class UnaryMinusNode extends RNode {
  UnaryMinusNode(super.parser, super.token, super.precedence, super.associativity) {
    // print('UnaryMinusNode: ${token.text}, ${token.type}, $precedence, $associativity');
  }

  @override
  Number? solveR(Number r) {
    // print('UnaryMinusNode.solveR');
    return r.invertSign();
  }
}

class AbsoluteValueNode extends RNode {
  AbsoluteValueNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solveR(Number r) {
    return r.abs();
  }
}

class FloorNode extends RNode {
  FloorNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solveR(Number r) {
    return r.floor();
  }
}

class CeilingNode extends RNode {
  CeilingNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solveR(Number r) {
    return r.ceiling();
  }
}

class FractionalComponentNode extends RNode {
  FractionalComponentNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solveR(Number r) {
    return r.fractionalPart();
  }
}

class RoundNode extends RNode {
  RoundNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solveR(Number r) {
    return r.round();
  }
}

class PercentNode extends RNode {
  PercentNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solveR(Number r) {
    return r.divideInteger(100);
  }
}

class FactorialNode extends RNode {
  FactorialNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solveR(Number r) {
    return r.factorial();
  }
}

class AddNode extends LRNode {
  bool doPercentage = false;

  AddNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number solveLR(Number left, Number r) {
    if (doPercentage) {
      var per = r.add(Number.fromInt(100));
      per = per.divideInteger(100);
      return left.multiply(per);
    }
    else {
      return left.add(r);
    }
  }
}

class SubtractNode extends LRNode {
  bool doPercentage = false;

  SubtractNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number solveLR(Number left, Number r) {
    if (doPercentage) {
      var per = r.add(Number.fromInt(-100));
      per = per.divideInteger(-100);
      return left.multiply(per);
    }
    else {
      return left.subtract(r);
    }
  }
}

class MultiplyNode extends LRNode {
  MultiplyNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number solveLR(Number left, Number r) {
    return left.multiply(r);
  }
}

class ShiftNode extends LRNode {
  ShiftNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number solveLR(Number left, Number r) {
    if (firstToken.type == LexerTokenType.shiftLeft) {
      return left.shift(r.toInteger());
    }
    else {
      return left.shift(r.multiplyInteger(-1).toInteger());
    }
  }
}

class DivideNode extends LRNode {
  DivideNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number solveLR(Number l, Number r) {
    var z = l.divide(r);
    if (Number.error != null) {
      var tokenStart = 0;
      var tokenEnd = 0;
      var tmpleft = right;
      var tmpright = right;
      while (tmpleft!.left != null) {
        tmpleft = tmpleft.left;
      }
      while (tmpright!.right != null) {
        tmpright = tmpright.right;
      }
      if (tmpleft.firstToken != null) tokenStart = tmpleft.firstToken.startIndex;
      if (tmpright.lastToken != null) tokenEnd = tmpright.lastToken.endIndex;
      parser.setError(ErrorCode.mp, Number.error, tokenStart, tokenEnd);
      Number.error = null;
    }
    return z;
  }
}

class ModulusDivideNode extends LRNode {
  ModulusDivideNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solve() {
    if (left is XPowYNode) {
      var baseValue = left!.left!.solve();
      var exponent = left!.right!.solve();
      var mod = right!.solve();
      if (baseValue == null || exponent == null || mod == null) return null;
      var z = baseValue.modularExponentiation(exponent, mod);

      /* check for errors */
      Number.checkFlags();
      if (Number.error != null) {
        var tmpleft = left;
        var tmpright = right;
        while (tmpleft!.left != null) {
          tmpleft = tmpleft.left;
        }
        while (tmpright!.right != null) {
          tmpright = tmpright.right;
        }
        parser.setError(ErrorCode.mp, Number.error, tmpleft.firstToken.startIndex, tmpright.lastToken.endIndex);
        Number.error = null;
      }

      return z;
    }
    else {
      var l = left!.solve();
      var r = right!.solve();
      if (l == null || r == null) return null;
      var z = solveLR(l, r);

      /* check for errors */
      Number.checkFlags();
      if (Number.error != null) {
        var tmpleft = left;
        var tmpright = right;
        while (tmpleft!.left != null) {
          tmpleft = tmpleft.left;
        }
        while (tmpright!.right != null) {
          tmpright = tmpright.right;
        }
        parser.setError(ErrorCode.mp, Number.error, tmpleft.firstToken.startIndex, tmpright.lastToken.endIndex);
        Number.error = null;
      }

      return z;
    }
  }

  @override
  Number solveLR(Number left, Number r) {
    return left.modulusDivide(r);
  }
}

class RootNode extends RNode {
  late int n;
  LexerToken? tokenN;

  RootNode(super.parser, super.token, super.precedence, super.associativity, this.n) {
    // print('RootNode: ${token.text}, ${token.type}, $precedence, $associativity');
    tokenN = null;
  }

  RootNode.withToken(super.parser, super.token, super.precedence, super.associativity, LexerToken this.tokenN) {
    // print('RootNode.withToken: ${token.text}, ${token.type}, $precedence, $associativity');
    n = 0;
  }

  @override
  Number? solveR(Number r) {
    if (n == 0 && tokenN != null) {
      n = subAtoi(tokenN!.text);
    }
    if (n == 0) {
      var error = 'The zeroth root of a number is undefined';
      parser.setError(ErrorCode.mp, error, tokenN!.startIndex, tokenN!.endIndex);
      return null;
    }
    return r.root(n);
  }
}

class XPowYNode extends LRNode {
  XPowYNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number solveLR(Number left, Number r) {
    return left.xpowy(r);
  }
}

class XPowYIntegerNode extends ParseNode {
  XPowYIntegerNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solve() {
    var val = left!.solve();

    // Are we inside a nested pow?
    val ??= Number.fromInt(superAtoi(left!.token.text));

    int pow;
    pow = superAtoi(right!.token.text);

    var z = val.xpowyInteger(pow);

    /* check for errors */
    Number.checkFlags();
    if (Number.error != null) {
      var tmpleft = left;
      var tmpright = right;
      while (tmpleft!.left != null) {
        tmpleft = tmpleft.left;
      }
      while (tmpright!.right != null) {
        tmpright = tmpright.right;
      }
      parser.setError(ErrorCode.mp, Number.error, tmpleft.firstToken.startIndex, tmpright.lastToken.endIndex);
      Number.error = null;
    }

    return z;
  }
}

class NotNode extends RNode {
  NotNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solveR(Number r) {
    if (!mpIsOverflow(r, parser.wordlen)) {
      parser.setError(ErrorCode.overflow);
      return Number.fromInt(0);
    }

    return r.not(parser.wordlen);
  }
}

class AndNode extends LRNode {
  AndNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number solveLR(Number left, Number r) {
    return left.and(r);
  }
}

class OrNode extends LRNode {
  OrNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number solveLR(Number left, Number r) {
    return left.or(r);
  }
}

class XorNode extends LRNode {
  XorNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number solveLR(Number left, Number r) {
    return left.xor(r);
  }
}

class ConvertNode extends LRNode {
  ConvertNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number solveLR(Number l, Number r) {
    var from = left!.value;
    if (left!.value != null) {
      from = left!.value;
      left!.value = null;
    }
    else {
      from = left!.token.text;
    }

    var to = right!.value;
    if (right!.value != null) {
      to = right!.value;
      right!.value = null;
    }
    else {
      to = right!.token.text;
    }

    var tmp = Number.fromInt(1);

    var ans = parser.convert(tmp, from!, to!);
    if (ans == null) {
      parser.setError(ErrorCode.unknownConversion);
      return Number.fromInt(0);
    }

    return ans;
  }
}

class ConvertBaseNode extends ParseNode {
  ConvertBaseNode(super.parser, super.token, super.precedence, super.associativity, [super.value]);

  @override
  Number? solve() {
    var name = value;

    if (name == null && right != null) name = right!.token.text;

    if (name == 'hex' || name == 'hexadecimal') {
      parser.setRepresentationBase(16);
    } else if (name == 'dec' || name == 'decimal') {
      parser.setRepresentationBase(10);
    } else if (name == 'oct' || name == 'octal') {
      parser.setRepresentationBase(8);
    } else if (name == 'bin' || name == 'binary') {
      parser.setRepresentationBase(2);
    } else {
      parser.setError(ErrorCode.unknownConversion, token.text, firstToken.startIndex, lastToken.endIndex);
      return null;
    }
    return left!.solve();
  }
}

class ConvertNumberNode extends ParseNode {
  ConvertNumberNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solve() {
    var from = left!.value;
    if (left!.value != null) {
      from = left!.value;
      left!.value = null;
    }
    else {
      from = left!.token.text;
    }

    var to = right!.value;
    if (right!.value != null) {
      to = right!.value;
      right!.value = null;
    }
    else {
      to = right!.token.text;
    }

    var tmp = left!.left!.solve();
    if (tmp == null) return null;

    var ans = parser.convert(tmp, from!, to!);
    if (ans == null) parser.setError(ErrorCode.unknownConversion);

    return ans;
  }
}

class Parser {
  String input;
  ParseNode? root;
  ParseNode? rightMost;
  late Lexer lexer;
  int numberBase;
  int wordLen;
  AngleUnit angleUnits;
  late int depthLevel;
  late ErrorCode error;
  String? errorToken;
  late int errorTokenStart;
  late int errorTokenEnd;
  late int representationBase;

  static Map<String, Number> constants = {
    "e": Number.e(), // Euler's number
    "em": Number.em(), // Euler-Mascheroni constant
    "𝛾": Number.em(),
    "pi": Number.pi(),
    "tau": Number.tau(),
    "π": Number.pi(),
    "τ": Number.tau(),
    "i": Number.i()
  };

  // Getter for wordLen
  int get wordlen => wordLen;

  Parser(this.input, this.numberBase, this.wordLen, this.angleUnits) {
    lexer = Lexer(input, this, numberBase);
    root = null;
    depthLevel = 0;
    rightMost = null;
    representationBase = numberBase;
    error = ErrorCode.none;
    errorToken = null;
    errorTokenStart = 0;
    errorTokenEnd = 0;
  }

  CreateParseTreeResult createParseTree() {
    // Scan string and split into tokens
    lexer.scan();

    // Parse tokens
    var ret = statement();

    var token = lexer.getNextToken();
    if (token.type == LexerTokenType.assign) {
      token = lexer.getNextToken();
      if (token.type != LexerTokenType.plEOS) {
        // Full string is not parsed.
        if (error == ErrorCode.none) {
          setError(
              ErrorCode.invalid, token.text, token.startIndex, token.endIndex);
        }

        return CreateParseTreeResult(
            representationBase: numberBase,
            errorCode: error,
            errorToken: errorToken,
            errorStart: errorTokenStart,
            errorEnd: errorTokenEnd,
            result: false);
      }
    }

    if (token.type != LexerTokenType.plEOS) {
      // Full string is not parsed.
      if (error == ErrorCode.none) {
        setError(
            ErrorCode.invalid, token.text, token.startIndex, token.endIndex);
      }

      return CreateParseTreeResult(
          representationBase: numberBase,
          errorCode: error,
          errorToken: errorToken,
          errorStart: errorTokenStart,
          errorEnd: errorTokenEnd,
          result: false);
    }

    // Input can't be parsed with grammar.
    if (!ret) {
      if (error == ErrorCode.none) {
        setError(ErrorCode.invalid);
      }

      return CreateParseTreeResult(
          representationBase: numberBase,
          errorCode: error,
          errorToken: errorToken,
          errorStart: errorTokenStart,
          errorEnd: errorTokenEnd,
          result: false);
    }

    return CreateParseTreeResult(
        representationBase: numberBase,
        errorCode: ErrorCode.none,
        errorToken: null,
        errorStart: 0,
        errorEnd: 0,
        result: true);
  }

  void setError(ErrorCode errorno,
      [String? token, int tokenStart = 0, int tokenEnd = 0]) {
    error = errorno;
    errorToken = token;
    errorTokenStart = input.charCount(tokenStart);
    errorTokenEnd = input.charCount(tokenEnd);
  }

  void setRepresentationBase(int newBase) {
    representationBase = newBase;
  }

  bool variableIsDefined(String name) {
    return false;
  }

  Number? getVariable(String name) {
    return null;
  }

  void setVariable(String name, Number x) {}

  bool functionIsDefined(String name) {
    return false;
  }

  bool unitIsDefined(String name) {
    return false;
  }

  bool literalBaseIsDefined(String name) {
    return false;
  }

  Number? convert(Number x, String xUnits, String zUnits) {
    return null;
  }

  /* Start parsing input string. And call evaluate on success. */
  ParseResult parse() {
    var result = createParseTree();
    // printTokens();
    // printTree();

    if (!result.result) {
      return ParseResult(
          representationBase: numberBase,
          errorCode: result.errorCode,
          errorToken: result.errorToken,
          errorStart: result.errorStart,
          errorEnd: result.errorEnd,
          number: null);
    }

    var ans = root?.solve();
    if (ans == null && error == ErrorCode.none) {
      setError(ErrorCode.invalid);
      return ParseResult(
          representationBase: representationBase,
          errorCode: ErrorCode.invalid,
          errorToken: errorToken,
          errorStart: errorTokenStart,
          errorEnd: errorTokenEnd,
          number: null);
    }

    return ParseResult(
        representationBase: representationBase,
        errorCode: error,
        errorToken: errorToken,
        errorStart: errorTokenStart,
        errorEnd: errorTokenEnd,
        number: ans);
  }

  // Print the parse tree to the console.
  // This is a recursive function that prints the tree in a depth-first manner.
  printTree() {
    print('Parse Tree:');
    printTreeRecursive(root, 0);
  }

  // Recursive function to print the parse tree.
  printTreeRecursive(ParseNode? node, int depth) {
    if (node == null) {
      return;
    }

    print('  token: ${node.token.text} parent: ${node.parent?.token.text}, precedence: ${node.precedence}, '
        'left: ${node.left?.token.text}, right: ${node.right?.token.text}');
    printTreeRecursive(node.left, depth + 1);
    printTreeRecursive(node.right, depth + 1);
  }

  // print the token list
  void printTokens() {
    print('Tokens:');
    // iterate through the tokens and print them
    for (var token in lexer.tokens) {
      print('Token: ${token.text}, Type: ${token.type}');
    }
  }

  Precedence getPrecedence(LexerTokenType type) {
    /* WARNING: This function doesn't work for Unary Plus and Unary Minus. Use their precedence directly while inserting them in tree. */
    if (type == LexerTokenType.add || type == LexerTokenType.subtract) {
      return Precedence.addSubtract;
    }
    if (type == LexerTokenType.multiply) {
      return Precedence.multiply;
    }
    if (type == LexerTokenType.mod) {
      return Precedence.mod;
    }
    if (type == LexerTokenType.divide) {
      return Precedence.divide;
    }
    if (type == LexerTokenType.not) {
      return Precedence.not;
    }
    if (type == LexerTokenType.root ||
        type == LexerTokenType.root_3 ||
        type == LexerTokenType.root_4) {
      return Precedence.root;
    }
    if (type == LexerTokenType.function) {
      return Precedence.function;
    }
    if (type == LexerTokenType.and ||
        type == LexerTokenType.or ||
        type == LexerTokenType.xor) {
      return Precedence.boolean;
    }
    if (type == LexerTokenType.percentage) {
      return Precedence.percentage;
    }
    if (type == LexerTokenType.power) {
      return Precedence.power;
    }
    if (type == LexerTokenType.factorial) {
      return Precedence.factorial;
    }
    if (type == LexerTokenType.number || type == LexerTokenType.variable) {
      return Precedence.numberVariable;
    }
    if (type == LexerTokenType.unit) {
      return Precedence.unit;
    }
    if (type == LexerTokenType.in_) {
      return Precedence.convert;
    }
    if (type == LexerTokenType.shiftLeft || type == LexerTokenType.shiftRight) {
      return Precedence.shift;
    }
    if (type == LexerTokenType.lRBracket || type == LexerTokenType.rRBracket) {
      return Precedence.depth;
    }
    return Precedence.top;
  }

  /* Return associativity of specific token type from precedence. */
  Associativity getAssociativityP(Precedence type) {
    if (type.value == Precedence.boolean.value ||
        type.value == Precedence.divide.value ||
        type.value == Precedence.mod.value ||
        type.value == Precedence.multiply.value ||
        type.value == Precedence.addSubtract.value) {
      return Associativity.left;
    }
    if (type.value == Precedence.power.value) {
      return Associativity.right;
    }
    /* For all remaining / non-associative operators, return Left Associativity. */
    return Associativity.left;
  }

  /* Return associativity of specific token by converting it to precedence first. */
  Associativity getAssociativity(LexerToken token) {
    return getAssociativityP(getPrecedence(token.type));
  }

  /* Generate precedence for a node from precedence value. Includes depthLevel. */
  int makePrecedenceP(Precedence p) {
    int precedence = p.value + (depthLevel * Precedence.depth.value);
    // print('makePrecedenceP: p.value: ${p.value}, depthLevel: $depthLevel, precedence: $precedence');
    return precedence;
  }

  /* Generate precedence for a node from lexer token type. Includes depthLevel. */
  int makePrecedenceT(LexerTokenType type) {
    int precedence = getPrecedence(type).value + (depthLevel * Precedence.depth.value);
    // print('makePrecedenceT: type: $type (${getPrecedence(type).value}), depthLevel: $depthLevel, precedence: $precedence');
    return precedence;
  }

  /* Compares two nodes to decide, which will be parent and which will be child. */
  bool cmpNodes(ParseNode? left, ParseNode? right) {
    /* Return values:
     * true = right goes up (near root) in parse tree.
     * false = left  goes up (near root) in parse tree.
     */
    if (left == null) {
      return false;
    }
    if (left.precedence > right!.precedence) {
      return true;
    }
    else if (left.precedence < right.precedence) {
      return false;
    }
    else {
      return right.associativity != Associativity.right;
    }
  }

  /* Unified interface (unary and binary nodes) to insert node into parse tree. */
  void insertIntoTreeAll(ParseNode node, bool unaryFunction) {
    if (root == null) {
      root = node;
      rightMost = root;
      return;
    }
    ParseNode? tmp = rightMost;
    while (cmpNodes(tmp, node)) {
      tmp = tmp?.parent;
    }

    if (unaryFunction) {
      /* If tmp is null, that means, we have to insert new node at root. */
      if (tmp == null) {
        node.right = root;
        node.right!.parent = node;

        root = node;
      }
      else {
        node.right = tmp.right;
        if (node.right != null) {
          node.right!.parent = node;
        }

        tmp.right = node;
        if (tmp.right != null) {
          tmp.right!.parent = tmp;
        }
      }
      rightMost = node;
      while (rightMost!.right != null) {
        rightMost = rightMost!.right;
      }
    }
    else {
      /* If tmp is null, that means, we have to insert new node at root. */
      if (tmp == null) {
        node.left = root;
        node.left!.parent = node;

        root = node;
      }
      else {
        node.left = tmp.right;
        if (node.left != null) {
          node.left!.parent = node;
        }

        tmp.right = node;
        if (tmp.right != null) {
          tmp.right!.parent = tmp;
        }
      }
      rightMost = node;
    }
  }

  /* Insert binary node into the parse tree. */
  void insertIntoTree(ParseNode node) {
    insertIntoTreeAll(node, false);
  }

  /* Insert unary node into the parse tree. */
  void insertIntoTreeUnary(ParseNode node) {
    insertIntoTreeAll(node, true);
  }

  /* Recursive call to free every node of parse-tree. */
  void destroyAllNodes(ParseNode? node) {
    if (node == null) {
      return;
    }

    destroyAllNodes(node.left);
    destroyAllNodes(node.right);
    /* Don't call free for tokens, as they are allocated and freed in lexer. */
    /* WARNING: If node.value is freed elsewhere, please assign it null before calling destroyAllNodes (). */
  }

  bool checkVariable(String name) {
    /* If defined, then get the variable */
    if (variableIsDefined(name)) {
      return true;
    }

    /* If has more than one character then assume a multiplication of variables */
    var index = 0;
    String c;
    RefInt rIndex = RefInt(index);
    RefString rC = RefString('');
    while (name.getNextChar(rIndex, rC)) {
      index = rIndex.value;
      c = rC.value;
      if (!variableIsDefined(c)) {
        return false;
      }
    }
    index = rIndex.value;
    c = rC.value;

    return true;
  }

  bool statement() {
    // print('statement');

    var token = lexer.getNextToken();
    if (token.type == LexerTokenType.variable || token.type == LexerTokenType.function) {
      var tokenOld = token;
      token = lexer.getNextToken();
      if (token.type == LexerTokenType.assign) {
        insertIntoTree(NameNode(this, tokenOld, makePrecedenceP(Precedence.numberVariable), getAssociativity(tokenOld)));
        insertIntoTree(AssignNode(this, token, 0, getAssociativity(token)));

        if (!expression()) {
          return false;
        }

        return true;
      }
      else {
        lexer.rollBack();
        lexer.rollBack();

        if (token.type == LexerTokenType.lRBracket) {
          if (functionDefinition()) {
            return true;
          }
        }

        if (!expression()) {
          return false;
        }

        return true;
      }
    }
    else {
      lexer.rollBack();
      if (!expression()) {
        return false;
      }
      return true;
    }
  }

  bool functionDefinition() {
    int numTokenParsed = 0;
    var token = lexer.getNextToken();
    numTokenParsed++;

    String functionName = token.text;
    lexer.getNextToken();
    numTokenParsed++;

    token = lexer.getNextToken();
    numTokenParsed++;
    String argumentList = "";
    List<LexerToken> tokenList = [];
    while (token.type != LexerTokenType.rRBracket && token.type != LexerTokenType.plEOS) {
      tokenList.add(token);
      argumentList += token.text;
      token = lexer.getNextToken();
      numTokenParsed++;
    }

    if (token.type == LexerTokenType.plEOS) {
      while (numTokenParsed-- > 0) {
        lexer.rollBack();
      }
      return false;
    }

    var assignToken = lexer.getNextToken();
    numTokenParsed++;
    if (assignToken.type != LexerTokenType.assign) {
      while (numTokenParsed-- > 0) {
        lexer.rollBack();
      }
      return false;
    }

    String expression = "";
    token = lexer.getNextToken();
    while (token.type != LexerTokenType.plEOS) {
      expression += token.text;
      token = lexer.getNextToken();
    }

    insertIntoTree(FunctionNameNode(this, null, makePrecedenceP(Precedence.numberVariable), getAssociativityP(Precedence.numberVariable), functionName));
    insertIntoTree(FunctionNode(this, null, makePrecedenceP(Precedence.function), getAssociativityP(Precedence.function), null));
    insertIntoTree(FunctionArgumentsNode(this, tokenList, makePrecedenceP(Precedence.numberVariable), getAssociativityP(Precedence.numberVariable), argumentList));
    insertIntoTree(AssignFunctionNode(this, assignToken, 0, getAssociativity(assignToken)));
    insertIntoTree(FunctionDescriptionNode(this, null, makePrecedenceP(Precedence.numberVariable), getAssociativityP(Precedence.numberVariable), expression));

    return true;
  }

  bool conversion() {
    var token = lexer.getNextToken();
    if (token.type == LexerTokenType.in_) {
      var tokenIn = token;
      token = lexer.getNextToken();
      if (token.type == LexerTokenType.unit) {
        var tokenTo = token;
        token = lexer.getNextToken();
        /* We can only convert representation base, if it is next to End Of Stream */
        if (token.type == LexerTokenType.plEOS) {
          insertIntoTree(ConvertBaseNode(this, tokenIn, makePrecedenceP(Precedence.convert), getAssociativity(tokenIn)));
          insertIntoTree(NameNode(this, tokenTo, makePrecedenceP(Precedence.unit), getAssociativity(tokenTo)));
          return true;
        }
        else {
          lexer.rollBack();
          lexer.rollBack();
          lexer.rollBack();
          return false;
        }
      }
      else {
        lexer.rollBack();
        lexer.rollBack();
        return false;
      }
    }
    else if (token.type == LexerTokenType.unit) {
      var tokenFrom = token;
      token = lexer.getNextToken();
      if (token.type == LexerTokenType.in_) {
        var tokenIn = token;
        token = lexer.getNextToken();
        if (token.type == LexerTokenType.unit) {
          insertIntoTree(NameNode(this, tokenFrom, makePrecedenceP(Precedence.unit), getAssociativity(tokenFrom)));
          insertIntoTree(ConvertNumberNode(this, tokenIn, makePrecedenceP(Precedence.convert), getAssociativity(tokenIn)));
          insertIntoTree(NameNode(this, token, makePrecedenceP(Precedence.unit), getAssociativity(token)));
          return true;
        }
        else {
          lexer.rollBack();
          lexer.rollBack();
          lexer.rollBack();
          return false;
        }
      }
      else {
        lexer.rollBack();
        lexer.rollBack();
        return false;
      }
    }
    else {
      lexer.rollBack();
      return false;
    }
  }

  bool expression() {
    // print('expression');
    // printTree();

    if (!expression1()) {
      return false;
    }
    if (!expression2()) {
      return false;
    }

    /* If there is a possible conversion at this level, insert it in the tree. */
    conversion();

    return true;
  }

  bool expression1() {
    // print('expression1');
    // printTree();

    var token = lexer.getNextToken();

    if (token.type == LexerTokenType.plEOS ||
        token.type == LexerTokenType.assign) {
      lexer.rollBack();
      return false;
    }

    if (token.type == LexerTokenType.lRBracket) {
      // print('token.type == LexerTokenType.lRBracket');
      depthLevel++;

      if (!expression()) {
        return false;
      }

      token = lexer.getNextToken();
      if (token.type == LexerTokenType.rRBracket) {
        // print('token.type == LexerTokenType.rRBracket');
        depthLevel--;
        token = lexer.getNextToken();
        lexer.rollBack();

        if (token.type == LexerTokenType.number) {
          insertIntoTree(MultiplyNode(
              this, null, makePrecedenceP(Precedence.multiply),
              getAssociativityP(Precedence.multiply)));

          if (!expression()) {
            return false;
          }
          else {
            return true;
          }
        }
        else {
          return true;
        }
      }
      //Expected ")" here...
      else {
        return false;
      }
    }
    else if (token.type == LexerTokenType.lSBracket) {
      depthLevel++;

      /* Give round, preference of Precedence.TOP aka 2, to keep it on the top of expression. */

      insertIntoTreeUnary(RoundNode(
          this, token, makePrecedenceP(Precedence.top),
          getAssociativity(token)));

      if (!expression()) {
        return false;
      }

      token = lexer.getNextToken();
      if (token.type == LexerTokenType.rSBracket) {
        depthLevel--;
        return true;
      }
      else {
        //Expected "]" here...
        return false;
      }
    }
    else if (token.type == LexerTokenType.lCBracket) {
      depthLevel++;

      /* Give fraction, preference of Precedence.TOP aka 2, to keep it on the top of expression. */

      insertIntoTreeUnary(FractionalComponentNode(
          this, token, makePrecedenceP(Precedence.top),
          getAssociativity(token)));

      if (!expression()) {
        return false;
      }

      token = lexer.getNextToken();
      if (token.type == LexerTokenType.rCBracket) {
        depthLevel--;
        return true;
      }
      //Expected "}" here...
      else {
        return false;
      }
    }
    else if (token.type == LexerTokenType.abs) {
      depthLevel++;

      /* Give abs, preference of Precedence.TOP aka 2, to keep it on the top of expression. */

      insertIntoTreeUnary(AbsoluteValueNode(
          this, token, makePrecedenceP(Precedence.top),
          getAssociativity(token)));

      if (!expression()) {
        return false;
      }

      token = lexer.getNextToken();
      if (token.type == LexerTokenType.abs) {
        depthLevel--;
        return true;
      }
      //Expected "|" here...
      else {
        return false;
      }
    }
    else if (token.type == LexerTokenType.not) {
      insertIntoTreeUnary(NotNode(this, token, makePrecedenceP(Precedence.not),
          getAssociativity(token)));

      if (!expression()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.number) {
      // print('token.type == LexerTokenType.number');
      int precedence = makePrecedenceT(token.type);
      Associativity associativity = getAssociativity(token);
      var node = ConstantNode(this, token, precedence, associativity);
      insertIntoTree(node);
      // print('insertIntoTree: ${node.token.text}, precedence = $precedence, associativity = $associativity');

      token = lexer.getNextToken();
      lexer.rollBack();

      if (token.type == LexerTokenType.function ||
          token.type == LexerTokenType.variable ||
          token.type == LexerTokenType.subNumber ||
          token.type == LexerTokenType.root ||
          token.type == LexerTokenType.root_3 ||
          token.type == LexerTokenType.root_4) {
        insertIntoTree(MultiplyNode(
            this, null, makePrecedenceP(Precedence.multiply),
            getAssociativityP(Precedence.multiply)));

        if (!variable()) {
          return false;
        }
        else {
          return true;
        }
      }
      else {
        return true;
      }
    }
    else if (token.type == LexerTokenType.lFloor) {
      depthLevel++;
      /* Give floor, preference of Precedence.TOP aka 2, to keep it on the top of expression. */

      insertIntoTreeUnary(FloorNode(this, null, makePrecedenceP(Precedence.top),
          getAssociativityP(Precedence.top)));

      if (!expression()) {
        return false;
      }

      token = lexer.getNextToken();
      if (token.type == LexerTokenType.rFloor) {
        depthLevel--;
        return true;
      }
      //Expected ⌋ here...
      else {
        return false;
      }
    }
    else if (token.type == LexerTokenType.lCeiling) {
      depthLevel++;
      /* Give ceiling, preference of Precedence.TOP aka 2, to keep it on the top of expression. */

      insertIntoTreeUnary(CeilingNode(
          this, null, makePrecedenceP(Precedence.top),
          getAssociativityP(Precedence.top)));

      if (!expression()) {
        return false;
      }

      token = lexer.getNextToken();
      if (token.type == LexerTokenType.rCeiling) {
        depthLevel--;
        return true;
      }
      //Expected ⌉ here...
      else {
        return false;
      }
    }
    else if (token.type == LexerTokenType.subtract) {
      // print('token.type == LexerTokenType.subtract');
      int precedence = makePrecedenceP(Precedence.unaryMinus);
      Associativity associativity = getAssociativityP(Precedence.unaryMinus);
      var node  = UnaryMinusNode(this, token, precedence, associativity);
      insertIntoTreeUnary(node);
      // print('insertIntoTreeUnary: ${node.token.text}, precedence = $precedence, associativity = $associativity');

      if (!expression1()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.add) {
      token = lexer.getNextToken();
      if (token.type == LexerTokenType.number) {
        /* Ignore ADD. It is not required. */
        insertIntoTree(ConstantNode(
            this, token, makePrecedenceT(token.type), getAssociativity(token)));
        return true;
      }
      else {
        return false;
      }
    }
    else {
      lexer.rollBack();
      if (!variable()) {
        return false;
      }
      else {
        return true;
      }
    }
  }

  bool expression2() {
    // print('expression2');
    // printTree();

    var token = lexer.getNextToken();
    if (token.type == LexerTokenType.lRBracket) {
      insertIntoTree(MultiplyNode(
          this, null, makePrecedenceP(Precedence.multiply),
          getAssociativityP(Precedence.multiply)));

      depthLevel++;
      if (!expression()) {
        return false;
      }
      token = lexer.getNextToken();
      if (token.type == LexerTokenType.rRBracket) {
        depthLevel--;

        if (!expression2()) {
          return false;
        }

        return true;
      }
      else {
        return false;
      }
    }
    else if (token.type == LexerTokenType.power) {
      insertIntoTree(XPowYNode(this, token, makePrecedenceT(token.type),
          getAssociativity(token)));

      if (!expression1()) {
        return false;
      }
      if (!expression2()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.supNumber) {
      insertIntoTree(XPowYIntegerNode(
          this, null, makePrecedenceP(Precedence.power),
          getAssociativityP(Precedence.power)));
      insertIntoTree(
          NameNode(this, token, makePrecedenceP(Precedence.numberVariable),
              getAssociativityP(Precedence.numberVariable)));

      if (!expression2()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.nSupNumber) {
      insertIntoTree(XPowYIntegerNode(
          this, null, makePrecedenceP(Precedence.power),
          getAssociativityP(Precedence.power)));
      insertIntoTree(
          NameNode(this, token, makePrecedenceP(Precedence.numberVariable),
              getAssociativityP(Precedence.numberVariable)));

      if (!expression2()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.factorial) {
      insertIntoTreeUnary(
          FactorialNode(this, token, makePrecedenceT(token.type),
              getAssociativity(token)));

      if (!expression2()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.multiply) {
      insertIntoTree(MultiplyNode(
          this, token, makePrecedenceT(token.type), getAssociativity(token)));

      if (!expression1()) {
        return false;
      }

      if (!expression2()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.percentage) {
      insertIntoTreeUnary(PercentNode(this, token, makePrecedenceT(token.type),
          getAssociativity(token)));

      if (!expression2()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.and) {
      insertIntoTree(AndNode(this, token, makePrecedenceT(token.type),
          getAssociativity(token)));

      if (!expression1()) {
        return false;
      }

      if (!expression2()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.or) {
      insertIntoTree(OrNode(this, token, makePrecedenceT(token.type),
          getAssociativity(token)));

      if (!expression1()) {
        return false;
      }

      if (!expression2()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.xor) {
      insertIntoTree(XorNode(this, token, makePrecedenceT(token.type),
          getAssociativity(token)));

      if (!expression1()) {
        return false;
      }

      if (!expression2()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.divide) {
      insertIntoTree(DivideNode(this, token, makePrecedenceT(token.type),
          getAssociativity(token)));

      if (!expression1()) {
        return false;
      }

      if (!expression2()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.shiftLeft ||
        token.type == LexerTokenType.shiftRight) {
      insertIntoTree(ShiftNode(this, token, makePrecedenceT(token.type),
          getAssociativity(token)));

      if (!expression1()) {
        return false;
      }

      if (!expression2()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.mod) {
      insertIntoTree(ModulusDivideNode(this, token, makePrecedenceT(token.type),
          getAssociativity(token)));

      if (!expression1()) {
        return false;
      }

      if (!expression2()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.add) {
      var node = AddNode(this, token, makePrecedenceT(token.type),
          getAssociativity(token));
      insertIntoTree(node);

      if (!expression1()) {
        return false;
      }

      token = lexer.getNextToken();
      if (token.type == LexerTokenType.percentage) {
        //FIXME: This condition needs to be verified for all cases.. :(
        if (node.right!.precedence > Precedence.percentage.value) {
          var nextToken = lexer.getNextToken();
          lexer.rollBack();

          if (nextToken.text != "" &&
              getPrecedence(nextToken.type).value < Precedence.percentage.value) {
            lexer.rollBack();
            if (!expression2()) {
              return true;
            }
          }

          node.precedence = makePrecedenceP(Precedence.percentage);
          node.doPercentage = true;
          return true;
        }
        else {
          /* Assume '%' to be part of 'expression PERCENTAGE' statement. */
          lexer.rollBack();
          if (!expression2()) {
            return true;
          }
        }
      }
      else {
        lexer.rollBack();
      }

      if (!expression2()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.subtract) {
      var node = SubtractNode(this, token, makePrecedenceT(token.type),
          getAssociativity(token));
      insertIntoTree(node);

      if (!expression1()) {
        return false;
      }
      token = lexer.getNextToken();
      if (token.type == LexerTokenType.percentage) {
        //FIXME: This condition needs to be verified for all cases.. :(
        if (node.right!.precedence > Precedence.percentage.value) {
          var nextToken = lexer.getNextToken();
          lexer.rollBack();

          if (nextToken.text != "" &&
              getPrecedence(nextToken.type).value < Precedence.percentage.value) {
            lexer.rollBack();
            if (!expression2()) {
              return true;
            }
          }

          node.precedence = makePrecedenceP(Precedence.percentage);
          node.doPercentage = true;
          return true;
        }
        else {
          /* Assume '%' to be part of 'expression PERCENTAGE' statement. */
          lexer.rollBack();
          if (!expression2()) {
            return true;
          }
        }
      }
      else {
        lexer.rollBack();
      }

      if (!expression2()) {
        return false;
      }

      return true;
    }
    else {
      lexer.rollBack();
      return true;
    }
  }

  bool variable() {
    // print('variable');
    // printTree();

    var token = lexer.getNextToken();
    if (token.type == LexerTokenType.function) {
      lexer.rollBack();
      if (!functionInvocation()) {
        return false;
      }
      return true;
    }
    else if (token.type == LexerTokenType.subNumber) {
      var tokenOld = token;
      token = lexer.getNextToken();
      if (token.type == LexerTokenType.root) {
        insertIntoTreeUnary(RootNode.withToken(
            this, token, makePrecedenceT(token.type), getAssociativity(token),
            tokenOld));
        if (!expression()) {
          return false;
        }

        return true;
      }
      else {
        return false;
      }
    }
    else if (token.type == LexerTokenType.root) {
      // print('token.type == LexerTokenType.root');
      int precedence = makePrecedenceT(token.type);
      Associativity associativity = getAssociativity(token);
      var node = RootNode(this, token, precedence, associativity, 2);
      insertIntoTreeUnary(node);
      // print('insertIntoTreeUnary: ${node.token.text}, precedence: $precedence, associativity: $associativity');

      if (!expression()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.root_3) {
      insertIntoTreeUnary(RootNode(
          this, token, makePrecedenceT(token.type), getAssociativity(token),
          3));

      if (!expression()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.root_4) {
      insertIntoTreeUnary(RootNode(
          this, token, makePrecedenceT(token.type), getAssociativity(token),
          4));

      if (!expression()) {
        return false;
      }

      return true;
    }
    else if (token.type == LexerTokenType.variable) {
      lexer.rollBack();
      // TODO: unknown function ERROR for (VARIABLE SUP_NUMBER expression).
      if (!term()) {
        return false;
      }

      return true;
    }
    else {
      return false;
    }
  }

  bool functionInvocation() {
    depthLevel++;
    int numTokenParsed = 0;
    var funToken = lexer.getNextToken();
    numTokenParsed++;
    String functionName = funToken.text;

    insertIntoTree(FunctionNameNode(
        this, funToken, makePrecedenceP(Precedence.numberVariable),
        getAssociativityP(Precedence.numberVariable), functionName));

    var token = lexer.getNextToken();
    numTokenParsed++;
    String? power;
    if (token.type == LexerTokenType.supNumber ||
        token.type == LexerTokenType.nSupNumber) {
      power = token.text;
      token = lexer.getNextToken();
      numTokenParsed++;
    }

    insertIntoTree(FunctionNode(
        this, funToken, makePrecedenceT(funToken.type),
        getAssociativity(funToken),
        power));

    if (token.type == LexerTokenType.lRBracket) {
      token = lexer.getNextToken();
      numTokenParsed++;
      int mDepth = 1;
      String argumentList = "";
      List<LexerToken> tokenList = [];

      while (token.type != LexerTokenType.plEOS &&
          token.type != LexerTokenType.assign) {
        if (token.type == LexerTokenType.lRBracket) {
          mDepth++;
        }
        else if (token.type == LexerTokenType.rRBracket) {
          mDepth--;
          if (mDepth == 0) {
            break;
          }
        }
        else {
          tokenList.add(token);
        }
        argumentList += token.text;
        token = lexer.getNextToken();
        numTokenParsed++;
      }

      if (token.type != LexerTokenType.rRBracket) {
        while (numTokenParsed-- > 0) {
          lexer.rollBack();
        }
        depthLevel--;
        return false;
      }

      insertIntoTree(FunctionArgumentsNode(
          this, tokenList, makePrecedenceP(Precedence.numberVariable),
          getAssociativityP(Precedence.numberVariable), argumentList));
    }
    else {
      lexer.rollBack();
      if (!expression1()) {
        lexer.rollBack();
        depthLevel--;
        return false;
      }

      token = lexer.getNextToken();
      if (token.type == LexerTokenType.factorial) {
        insertIntoTreeUnary(FactorialNode(
            this, token, makePrecedenceT(token.type), getAssociativity(token)));
      }
      else {
        lexer.rollBack();
      }

      depthLevel--;

      if (!expression2()) {
        lexer.rollBack();
        return false;
      }

      return true;
    }

    depthLevel--;
    return true;
  }

  bool term() {
    var token = lexer.getNextToken();

    if (token.type == LexerTokenType.variable) {
      var tokenOld = token;
      token = lexer.getNextToken();
      /* Check if the token is a valid variable or not. */
      if (!checkVariable(tokenOld.text)) {
        if (token.text == "(") {
          setError(ErrorCode.unknownFunction, tokenOld.text, tokenOld.startIndex, tokenOld.endIndex);
        }
        else {
          setError(ErrorCode.unknownVariable, tokenOld.text, tokenOld.startIndex, tokenOld.endIndex);
        }
        return false;
      }
      if (token.type == LexerTokenType.supNumber) {
        insertIntoTree(VariableWithPowerNode(
            this, tokenOld, makePrecedenceT(tokenOld.type),
            getAssociativity(tokenOld), token.text));
      }
      else {
        lexer.rollBack();
        insertIntoTree(VariableNode(
            this, tokenOld, makePrecedenceT(tokenOld.type),
            getAssociativity(tokenOld)));
      }

      if (!term2()) {
        return false;
      }

      return true;
    }
    else {
      return false;
    }
  }

  bool term2() {
    var token = lexer.getNextToken();
    lexer.rollBack();

    if (token.type == LexerTokenType.plEOS ||
        token.type == LexerTokenType.assign) {
      return true;
    }

    if (token.type == LexerTokenType.function ||
        token.type == LexerTokenType.variable ||
        token.type == LexerTokenType.subNumber ||
        token.type == LexerTokenType.root ||
        token.type == LexerTokenType.root_3 ||
        token.type == LexerTokenType.root_4) {
      /* Insert multiply in between variable and (function, variable, root) */
      insertIntoTree(MultiplyNode(
          this, null, makePrecedenceP(Precedence.multiply),
          getAssociativityP(Precedence.multiply)));
      if (!variable()) {
        return false;
      }
      return true;
    }
    else {
      return true;
    }
  }
}
