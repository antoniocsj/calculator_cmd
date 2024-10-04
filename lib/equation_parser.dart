import 'package:calculator/enums.dart';
import 'package:calculator/equation.dart';
import 'package:calculator/equation_lexer.dart';
import 'package:calculator/number.dart';
import 'package:calculator/types.dart';

// The following is a commented Vala code that defines the ParseNode class:
// public class ParseNode : Object
// {
// public Parser parser;
// public ParseNode? parent = null;
// public ParseNode? left = null;
// public ParseNode? right = null;
// public List<LexerToken> token_list;
// public uint precedence;
// public Associativity associativity;
// public string? value;
//
// public LexerToken token()
// {
//   assert(token_list.length() == 1);
//   return token_list.first().data;
// }
//
// public LexerToken first_token()
// {
//   return token_list.first().data;
// }
//
// public LexerToken last_token()
// {
//   return token_list.last().data;
// }
//
// public ParseNode.WithList (Parser parser, List<LexerToken> token_list, uint precedence, Associativity associativity, string? value = null)
// {
// this.parser = parser;
// this.token_list = token_list.copy_deep((CopyFunc) Object.ref);
// this.precedence = precedence;
// this.associativity = associativity;
// this.value = value;
//
// }
//
// public ParseNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity, string? value = null)
// {
// this.parser = parser;
// this.token_list = new List<LexerToken>();
// token_list.insert(token, 0);
// this.precedence = precedence;
// this.associativity = associativity;
// this.value = value;
// }
//
// public virtual Number? solve ()
// {
// return null;
// }
// }
//
// // the following is the equivalent Dart code to the previous commented Vala code that defines the ParseNode class:
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

// The following is a commented Vala code that defines the RNode class:
// public abstract class RNode : ParseNode
// {
//     protected RNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
//     {
//         base (parser, token, precedence, associativity);
//     }
//
//     public override Number? solve ()
//     {
//         var r = right.solve ();
//         if (r == null)
//             return null;
//         var z = solve_r (r);
//
//         /* check for errors */
//         Number.check_flags ();
//         if (Number.error != null)
//         {
//             var tmpleft = right;
//             var tmpright = right;
//             while (tmpleft.left != null) tmpleft = tmpleft.left;
//             while (tmpright.right != null) tmpright = tmpright.right;
//             parser.set_error (ErrorCode.MP, Number.error, tmpleft.first_token().start_index, tmpright.last_token().end_index);
//             Number.error = null;
//         }
//         return z;
//     }
//
//     public abstract Number? solve_r (Number r);
// }
// the following is the equivalent Dart code to the previous commented Vala code that defines the RNode class:
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

// The following is a commented Vala code that defines the LRNode class:
// public abstract class LRNode : ParseNode
// {
//     protected LRNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
//     {
//         base (parser, token, precedence, associativity);
//     }
//
//     public override Number? solve ()
//     {
//         var l = left.solve ();
//         var r = right.solve ();
//         if (l == null || r == null)
//             return null;
//         var z = solve_lr (l, r);
//
//         /* check for errors */
//         Number.check_flags ();
//         if (Number.error != null)
//         {
//             var tmpleft = left;
//             var tmpright = right;
//             while (tmpleft.left != null) tmpleft = tmpleft.left;
//             while (tmpright.right != null) tmpright = tmpright.right;
//             parser.set_error (ErrorCode.MP, Number.error, tmpleft.first_token().start_index, tmpright.last_token().end_index);
//             Number.error = null;
//         }
//         return z;
//     }
//
//     public abstract Number solve_lr (Number left, Number r);
// }
// the following is the equivalent Dart code to the previous commented Vala code that defines the LRNode class:
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

// The following is a commented Vala code that defines the ConstantNode class:
// public class ConstantNode : ParseNode
// {
// public ConstantNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve ()
// {
//   return mp_set_from_string (token().text, parser.number_base);
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the ConstantNode class:
class ConstantNode extends ParseNode {
  ConstantNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solve() {
    return mpSetFromString(token.text, parser.numberBase);
  }
}

// The following is a commented Vala code that defines the AssignNode class:
// public class AssignNode : RNode
// {
// public AssignNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve_r (Number r)
// {
//   parser.set_variable (left.token().text, r);
//   return r;
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the AssignNode class:
class AssignNode extends RNode {
  AssignNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solveR(Number r) {
    parser.setVariable(left!.token.text, r);
    return r;
  }
}

// The following is a commented Vala code that defines the AssignFunctionNode class:
// public class AssignFunctionNode : ParseNode
// {
// public AssignFunctionNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve ()
// {
//   if (left == null || right == null || left.left == null || left.right == null)
//     return null;
//
//   var function_name = left.left.value;
//   var arguments = left.right.value;
//   var description = right.value;
//
//   FunctionManager function_manager = FunctionManager.get_default_function_manager();
//   if (function_manager.add_function_with_properties (function_name, arguments, description, parser))
//     return new Number.integer (0);
//
//   return null;
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the AssignFunctionNode class:
class AssignFunctionNode extends ParseNode {
  AssignFunctionNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solve() {
    if (left == null || right == null || left?.left == null || left?.right == null) return null;

    var functionName = left!.left!.value;
    var arguments = left!.right!.value;
    var description = right!.value;

    var functionManager = FunctionManager.getDefaultFunctionManager();
    if (functionManager.addFunctionWithProperties(functionName, arguments, description, parser)) {
      return Number.fromInt(0);
    }

    return null;
  }
}

// The following is a commented Vala code that defines the NameNode class:
// public class NameNode : ParseNode
// {
// public NameNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity, string? text = null)
// {
// base (parser, token, precedence, associativity, text);
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the NameNode class:
class NameNode extends ParseNode {
  NameNode(super.parser, super.token, super.precedence, super.associativity, [super.text]);
  NameNode.withList(super.parser, super.tokenList, super.precedence, super.associativity, String super.text)
      : super.withList();
}

// The following is a commented Vala code that defines the VariableNode class:
// public class VariableNode : ParseNode
// {
// public VariableNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve ()
// {
//   /* If defined, then get the variable */
//   var ans = parser.get_variable (token().text);
//   if (ans != null)
//     return ans;
//
//   /* If has more than one character then assume a multiplication of variables */
//   // FIXME: Do this in the lexer
//   var value = new Number.integer (1);
//   var index = 0;
//   unichar c;
//   while (token().text.get_next_char (ref index, out c))
//   {
//     var t = parser.get_variable (c.to_string ());
//     if (t == null)
//     {
//       parser.set_error (ErrorCode.UNKNOWN_VARIABLE, token().text, first_token().start_index, last_token().end_index);
//       return null;
//     }
//     value = value.multiply (t);
//   }
//   return value;
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the VariableNode class:
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
    String c;
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

    return value;
  }
}

// The following is a commented Vala code that defines the VariableWithPowerNode class:
// public class VariableWithPowerNode : ParseNode
// {
// public VariableWithPowerNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity, string text)
// {
//   base (parser, token, precedence, associativity, text);
// }
//
// public override Number? solve ()
// {
//   var pow = super_atoi (value);
//
//   value = null;
//
//   /* If defined, then get the variable */
//   var ans = parser.get_variable (token().text);
//   if (ans != null)
//     return ans.xpowy_integer (pow);
//
//   /* If has more than one character then assume a multiplication of variables */
//   // FIXME: Do in lexer
//   var value = new Number.integer (1);
//   var index = 0;
//   unichar c;
//   while (token().text.get_next_char (ref index, out c))
//   {
//     var t = parser.get_variable (c.to_string ());
//     if (t == null)
//     {
//       parser.set_error (ErrorCode.UNKNOWN_VARIABLE, token().text, first_token().start_index, last_token().end_index);
//       return null;
//     }
//
//     /* If last term do power */
//     var i = index;
//     unichar next;
//     if (!token().text.get_next_char (ref i, out next))
//       t = t.xpowy_integer (pow);
//     value = value.multiply (t);
//   }
//
//   /* check for errors */
//   Number.check_flags ();
//   if (Number.error != null)
//   {
//     var tmpleft = left;
//     var tmpright = right;
//     while (tmpleft.left != null) tmpleft = tmpleft.left;
//     while (tmpright.right != null) tmpright = tmpright.right;
//     parser.set_error (ErrorCode.MP, Number.error, tmpleft.first_token().start_index, tmpright.last_token().end_index);
//     Number.error = null;
//   }
//
//   return value;
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the VariableWithPowerNode class:
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

      value = value.multiply(t);
    }

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

// The following is a commented Vala code that defines the FunctionNameNode class:
// public class FunctionNameNode : NameNode
// {
// public FunctionNameNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity, string name)
// {
//   base (parser, token, precedence, associativity, name);
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the FunctionNameNode class:
class FunctionNameNode extends NameNode {
  FunctionNameNode(super.parser, super.token, super.precedence, super.associativity, String super.name);
}

// The following is a commented Vala code that defines the FunctionArgumentsNode class:
// public class FunctionArgumentsNode : NameNode
// {
// public FunctionArgumentsNode (Parser parser, List<LexerToken> token_list, uint precedence, Associativity associativity, string arguments)
// {
//   base.WithList (parser, token_list, precedence, associativity, arguments);
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the FunctionArgumentsNode class:
class FunctionArgumentsNode extends NameNode {
  FunctionArgumentsNode(super.parser, super.tokenList, super.precedence, super.associativity, super.arguments)
      : super.withList();
}

// The following is a commented Vala code that defines the FunctionDescriptionNode class:
// public class FunctionDescriptionNode : NameNode
// {
// public FunctionDescriptionNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity, string description)
// {
//   base (parser, token, precedence, associativity, description);
// }
// }
// the following is the equivalent Dart code to the previous commented Vala code that defines the FunctionDescriptionNode class:
class FunctionDescriptionNode extends NameNode {
  FunctionDescriptionNode(super.parser, super.token, super.precedence, super.associativity, String super.description);
}

// The following is a commented Vala code that defines the FunctionNode class:
// public class FunctionNode : ParseNode
// {
// public FunctionNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity, string? text)
// {
//   base (parser, token, precedence, associativity, text);
// }
//
// public override Number? solve ()
// {
//   if (right == null || left == null)
//   {
//     parser.set_error (ErrorCode.UNKNOWN_FUNCTION);
//     return null;
//   }
//
//   var name = left.value;
//   if (name == null)
//   {
//     parser.set_error (ErrorCode.UNKNOWN_FUNCTION);
//     return null;
//   }
//
//   int pow = 1;
//   if (this.value != null)
//     pow = super_atoi (this.value);
//
//   if (pow < 0)
//   {
//     name = name + "⁻¹";
//     pow = -pow;
//   }
//
//   Number[] args = {};
//   if (right is FunctionArgumentsNode)
//   {
//     var argument_list = right.value;
//     var temp = "";
//     int depth = 0;
//     for (int i = 0; i < argument_list.length; i++)
//     {
//       string ss = argument_list.substring (i, 1);
//       if (ss == "(")
//         depth++;
//       else if (ss == ")")
//         depth--;
//       else if (ss == ";" && depth != 0)
//         ss = "$";
//       temp += ss;
//     }
//     var arguments = temp.split_set (";");
//
//     foreach (var argument in arguments)
//     {
//       argument = argument.replace ("$", ";").strip ();
//       var argument_parser = new ExpressionParser (argument, parser);
//
//       uint representation_base;
//       ErrorCode error_code;
//       string? error_token;
//       uint error_start;
//       uint error_end;
//
//       var ans = argument_parser.parse (out representation_base, out error_code, out error_token, out error_start, out error_end);
//
//       if (error_code == ErrorCode.NONE && ans != null)
//         args += ans;
//       else
//       {
//         parser.set_error (ErrorCode.UNKNOWN_VARIABLE, error_token, error_start, error_end);
//         return null;
//       }
//     }
//   }
//   else
//   {
//     var ans = right.solve ();
//     if (ans != null)
//       args += ans;
//     else
//     {
//       parser.set_error (ErrorCode.UNKNOWN_FUNCTION);
//       return null;
//     }
//   }
//
//   FunctionManager function_manager = FunctionManager.get_default_function_manager ();
//   var tmp = function_manager.evaluate_function (name, args, parser);
//
//   if (tmp != null)
//     tmp = tmp.xpowy_integer (pow);
//
//   /* check for errors */
//   Number.check_flags ();
//   if (Number.error != null)
//   {
//     parser.set_error (ErrorCode.MP, Number.error, right.first_token().start_index, right.last_token().end_index);
//     Number.error = null;
//   }
//
//   return tmp;
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the FunctionNode class:
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
        var ss = argumentList.substring(i, 1);
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
        var ans = result.result;
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

// The following is a commented Vala code that defines the UnaryMinusNode, AbsoluteValueNode, FloorNode, CeilingNode, FractionalComponentNode, RoundNode and PercentNode classes:
// public class UnaryMinusNode : RNode
// {
// public UnaryMinusNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve_r (Number r)
// {
//   return r.invert_sign ();
// }
// }
//
// public class AbsoluteValueNode : RNode
// {
// public AbsoluteValueNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve_r (Number r)
// {
//   return r.abs ();
// }
// }
//
// public class FloorNode : RNode
// {
// public FloorNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve_r (Number r)
// {
//   return r.floor ();
// }
// }
//
// public class CeilingNode : RNode
// {
// public CeilingNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve_r (Number r)
// {
//   return r.ceiling ();
// }
// }
//
// public class FractionalComponentNode : RNode
// {
// public FractionalComponentNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve_r (Number r)
// {
//   return r.fractional_part ();
// }
// }
//
// public class RoundNode : RNode
// {
// public RoundNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve_r (Number r)
// {
//   return r.round ();
// }
// }
//
// public class PercentNode : RNode
// {
// public PercentNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve_r (Number r)
// {
//   return r.divide_integer (100);
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the UnaryMinusNode, AbsoluteValueNode, FloorNode, CeilingNode, FractionalComponentNode, RoundNode and PercentNode classes:
class UnaryMinusNode extends RNode {
  UnaryMinusNode(super.parser, super.token, super.precedence, super.associativity);

  @override
  Number? solveR(Number r) {
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

// The following is a commented Vala code that defines the FactorialNode, AddNode, SubtractNode, MultiplyNode and ShiftNode classes:
// public class FactorialNode : RNode
// {
// public FactorialNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve_r (Number r)
// {
//   return r.factorial ();
// }
// }
//
// public class AddNode : LRNode
// {
// public bool do_percentage = false;
//
// public AddNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number solve_lr (Number l, Number r)
// {
//   if (do_percentage)
//   {
//     var per = r.add (new Number.integer (100));
//     per = per.divide_integer (100);
//     return l.multiply (per);
//   }
//   else
//     return l.add (r);
// }
// }
//
//
// public class SubtractNode : LRNode
// {
// public bool do_percentage = false;
//
// public SubtractNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number solve_lr (Number l, Number r)
// {
//   if (do_percentage)
//   {
//     var per = r.add (new Number.integer (-100));
//     per = per.divide_integer (-100);
//     return l.multiply (per);
//   }
//   else
//     return l.subtract (r);
// }
// }
//
// public class MultiplyNode : LRNode
// {
// public MultiplyNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number solve_lr (Number l, Number r)
// {
//   return l.multiply (r);
// }
// }
//
// public class ShiftNode : LRNode
// {
// public ShiftNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number solve_lr (Number l, Number r)
// {
//   if (first_token().type == LexerTokenType.SHIFT_LEFT)
//     return l.shift (r.to_integer ());
//   else
//     return l.shift (r.multiply_integer (-1).to_integer ());
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the FactorialNode, AddNode, SubtractNode, MultiplyNode and ShiftNode classes:
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

// The following is a commented Vala code that defines the DivideNode class:
// public class DivideNode : LRNode
// {
// public DivideNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number solve_lr (Number l, Number r)
// {
//   var z = l.divide (r);
//   if (Number.error != null)
//   {
//     uint token_start = 0;
//     uint token_end = 0;
//     var tmpleft = right;
//     var tmpright = right;
//     while (tmpleft.left != null) tmpleft = tmpleft.left;
//     while (tmpright.right != null) tmpright = tmpright.right;
//     if (tmpleft.first_token() != null) token_start = tmpleft.first_token().start_index;
//     if (tmpright.last_token() != null) token_end = tmpright.last_token().end_index;
//     parser.set_error (ErrorCode.MP, Number.error, token_start, token_end);
//     Number.error = null;
//   }
//   return z;
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the DivideNode class:
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

// The following is a commented Vala code that defines the ModulusDivideNode class:
// public class ModulusDivideNode : LRNode
// {
// public ModulusDivideNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve ()
// {
//   if (left is XPowYNode)
//   {
//     var base_value = left.left.solve ();
//     var exponent = left.right.solve ();
//     var mod = right.solve ();
//     if (base_value == null || exponent == null || mod == null)
//       return null;
//     var z = base_value.modular_exponentiation (exponent, mod);
//
//     /* check for errors */
//     Number.check_flags ();
//     if (Number.error != null)
//     {
//       var tmpleft = left;
//       var tmpright = right;
//       while (tmpleft.left != null) tmpleft = tmpleft.left;
//       while (tmpright.right != null) tmpright = tmpright.right;
//       parser.set_error (ErrorCode.MP, Number.error, tmpleft.first_token().start_index, tmpright.last_token().end_index);
//       Number.error = null;
//     }
//
//     return z;
//   }
//   else
//   {
//     var l = left.solve ();
//     var r = right.solve ();
//     if (l == null || r == null)
//       return null;
//     var z = solve_lr (l, r);
//
//     /* check for errors */
//     Number.check_flags ();
//     if (Number.error != null)
//     {
//       var tmpleft = left;
//       var tmpright = right;
//       while (tmpleft.left != null) tmpleft = tmpleft.left;
//       while (tmpright.right != null) tmpright = tmpright.right;
//       parser.set_error (ErrorCode.MP, Number.error, tmpleft.first_token().start_index, tmpright.last_token().end_index);
//       Number.error = null;
//     }
//
//     return z;
//   }
// }
//
// public override Number solve_lr (Number l, Number r)
// {
//   return l.modulus_divide (r);
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the ModulusDivideNode class:
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
        while (tmpleft!.left != null) tmpleft = tmpleft.left;
        while (tmpright!.right != null) tmpright = tmpright.right;
        parser.setError(ErrorCode.mp, Number.error, tmpleft.firstToken.startIndex, tmpright.lastToken.endIndex);
        Number.error = null;
      }

      return z;
    } else {
      var l = left!.solve();
      var r = right!.solve();
      if (l == null || r == null) return null;
      var z = solveLR(l, r);

      /* check for errors */
      Number.checkFlags();
      if (Number.error != null) {
        var tmpleft = left;
        var tmpright = right;
        while (tmpleft!.left != null) tmpleft = tmpleft.left;
        while (tmpright!.right != null) tmpright = tmpright.right;
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

// The following is a commented Vala code that defines the RootNode class:
// public class RootNode : RNode
// {
// private int n;
// private LexerToken? token_n;
//
// public RootNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity, int n)
// {
//   base (parser, token, precedence, associativity);
//   this.n = n;
//   this.token_n = null;
// }
//
// public RootNode.WithToken (Parser parser, LexerToken? token, uint precedence, Associativity associativity, LexerToken token_n)
// {
// base (parser, token, precedence, associativity);
// n = 0;
// this.token_n = token_n;
// }
//
// public override Number? solve_r (Number r)
// {
//   if (n == 0 && token_n != null)
//   {
//     n = sub_atoi(token_n.text);
//   }
//   if (n == 0)
//   {
//     string error = _("The zeroth root of a number is undefined");
//     parser.set_error (ErrorCode.MP, error, token_n.start_index, token_n.end_index);
//     return null;
//   }
//   return r.root (n);
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the RootNode class:
class RootNode extends RNode {
  late int n;
  LexerToken? tokenN;

  RootNode(super.parser, super.token, super.precedence, super.associativity, this.n) {
    tokenN = null;
  }

  RootNode.withToken(super.parser, super.token, super.precedence, super.associativity, LexerToken this.tokenN) {
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

// The following is a commented Vala code that defines the XPowYNode, XPowYIntegerNode and NotNode classes:
// public class XPowYNode : LRNode
// {
// public XPowYNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number solve_lr (Number l, Number r)
// {
//   return l.xpowy (r);
// }
// }
//
// /**
//  * This class is a XPowY in which the right token is an nsup number.
//  */
// public class XPowYIntegerNode : ParseNode
// {
// public XPowYIntegerNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve ()
// {
//   var val = left.solve ();
//
//   // Are we inside a nested pow?
//   if (val == null)
//   {
//     val = new Number.integer (super_atoi (left.token().text));
//   }
//
//   int64 pow;
//
//   if (right.token() != null)
//     pow = super_atoi (right.token().text);
//   else
//     pow = right.solve ().to_integer ();
//
//   if (val == null)
//     return null;
//
//   var z = val.xpowy_integer (pow);
//
//   /* check for errors */
//   Number.check_flags ();
//   if (Number.error != null)
//   {
//     var tmpleft = left;
//     var tmpright = right;
//     while (tmpleft.left != null) tmpleft = tmpleft.left;
//     while (tmpright.right != null) tmpright = tmpright.right;
//     parser.set_error (ErrorCode.MP, Number.error, tmpleft.first_token().start_index, tmpright.last_token().end_index);
//     Number.error = null;
//   }
//
//   return z;
// }
// }
//
// public class NotNode : RNode
// {
// public NotNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number? solve_r (Number r)
// {
//   if (!mp_is_overflow (r, parser.wordlen))
//   {
//     parser.set_error (ErrorCode.OVERFLOW);
//     return new Number.integer (0);
//   }
//
//   return r.not (parser.wordlen);
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the XPowYNode, XPowYIntegerNode and NotNode classes:
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

    if (right!.token != null) {
      pow = superAtoi(right!.token!.text);
    } else {
      pow = right!.solve()!.toInteger();
    }

    if (val == null) return null;

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

// The following is a commented Vala code that defines the AndNode, OrNode and XorNode classes:
// public class AndNode : LRNode
// {
// public AndNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number solve_lr (Number l, Number r)
// {
//   return l.and (r);
// }
// }
//
// public class OrNode : LRNode
// {
// public OrNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number solve_lr (Number l, Number r)
// {
//   return l.or (r);
// }
// }
//
// public class XorNode : LRNode
// {
// public XorNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number solve_lr (Number l, Number r)
// {
//   return l.xor (r);
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the AndNode, OrNode and XorNode classes:
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

// The following is a commented Vala code that defines the ConvertNode, ConvertBaseNode and ConvertNumberNode classes:
// public class ConvertNode : LRNode
// {
// public ConvertNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
//   base (parser, token, precedence, associativity);
// }
//
// public override Number solve_lr (Number l, Number r)
// {
//   string from;
//   if (left.value != null)
//   {
//     from = left.value;
//     left.value = null;
//   }
//   else
//     from = left.token().text;
//
//   string to;
//   if (right.value != null)
//   {
//     to = right.value;
//     right.value = null;
//   }
//   else
//     to = right.token().text;
//
//   var tmp = new Number.integer (1);
//
//   var ans = parser.convert (tmp, from, to);
//   if (ans == null)
//     parser.set_error (ErrorCode.UNKNOWN_CONVERSION);
//
//   return ans;
// }
// }
//
// public class ConvertBaseNode : ParseNode
// {
// public ConvertBaseNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity, string? value = null)
// {
// base (parser, token, precedence, associativity, value);
// }
//
// public override Number? solve ()
// {
// string name = value;
//
// if (name == null && right != null)
// name = right.token ().text;
//
// if (name == "hex" || name == "hexadecimal")
// parser.set_representation_base (16);
// else if (name == "dec" || name == "decimal")
// parser.set_representation_base (10);
// else if (name == "oct" || name == "octal")
// parser.set_representation_base (8);
// else if (name == "bin" || name == "binary")
// parser.set_representation_base (2);
// else
// {
// parser.set_error (ErrorCode.UNKNOWN_CONVERSION, token().text, first_token().start_index, last_token().end_index);
// return null;
// }
// return left.solve ();
// }
// }
//
// public class ConvertNumberNode : ParseNode
// {
// public ConvertNumberNode (Parser parser, LexerToken? token, uint precedence, Associativity associativity)
// {
// base (parser, token, precedence, associativity);
// }
//
// public override Number? solve ()
// {
// string from;
// if (left.value != null)
// {
// from = left.value;
// left.value = null;
// }
// else
// from = left.token().text;
//
// string to;
// if (right.value != null)
// {
// to = right.value;
// right.value = null;
// }
// else
// to = right.token().text;
//
// var tmp = left.left.solve();
// if (tmp == null)
// return null;
//
// var ans = parser.convert (tmp, from, to);
// if (ans == null)
// parser.set_error (ErrorCode.UNKNOWN_CONVERSION);
//
// return ans;
// }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the ConvertNode, ConvertBaseNode and ConvertNumberNode classes:
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

// The following is a commented Vala code that defines the Parser class:
// public class Parser
// {
//     private string input;
//     private ParseNode root;
//     private ParseNode right_most;
//     private Lexer lexer;
//     public int number_base;
//     public int wordlen;
//     public AngleUnit angle_units;
//     private uint depth_level;
//     private ErrorCode error;
//     private string error_token;
//     private int error_token_start;
//     private int error_token_end;
//     private uint representation_base;
//
//     public static HashTable<string, Number> CONSTANTS;
//
//     static construct {
//         CONSTANTS = new HashTable<string, Number> (str_hash, str_equal);
//         CONSTANTS.insert ("e", new Number.eulers ());
//         CONSTANTS.insert ("pi", new Number.pi ());
//         CONSTANTS.insert ("tau", new Number.tau ());
//         CONSTANTS.insert ("π", new Number.pi ());
//         CONSTANTS.insert ("τ", new Number.tau ());
//         CONSTANTS.insert ("i", new Number.i ());
//     }
//
//     public Parser (string input, int number_base, int wordlen, AngleUnit angle_units)
//     {
//         this.input = input;
//         lexer = new Lexer (input, this, number_base);
//         root = null;
//         depth_level = 0;
//         right_most = null;
//         this.number_base = number_base;
//         this.representation_base = number_base;
//         this.wordlen = wordlen;
//         this.angle_units = angle_units;
//         error = ErrorCode.NONE;
//         error_token = null;
//         error_token_start = 0;
//         error_token_end = 0;
//     }
//
//     public bool create_parse_tree (out uint representation_base, out ErrorCode error_code, out string? error_token, out uint error_start, out uint error_end)
//     {
//         representation_base = number_base;
//         /* Scan string and split into tokens */
//         lexer.scan ();
//
//         /* Parse tokens */
//         var ret = statement ();
//
//         var token = lexer.get_next_token ();
//         if (token.type == LexerTokenType.ASSIGN)
//         {
//             token = lexer.get_next_token ();
//             if (token.type != LexerTokenType.PL_EOS)
//             {
//                 /* Full string is not parsed. */
//                 if (error == ErrorCode.NONE)
//                     set_error (ErrorCode.INVALID, token.text, token.start_index, token.end_index);
//
//                 error_code = error;
//                 error_token = this.error_token;
//                 error_start = error_token_start;
//                 error_end = error_token_end;
//                 return false;
//             }
//         }
//         if (token.type != LexerTokenType.PL_EOS)
//         {
//             /* Full string is not parsed. */
//             if (error == ErrorCode.NONE)
//                 set_error (ErrorCode.INVALID, token.text, token.start_index, token.end_index);
//
//             error_code = error;
//             error_token = this.error_token;
//             error_start = error_token_start;
//             error_end = error_token_end;
//             return false;
//         }
//
//         /* Input can't be parsed with grammar. */
//         if (!ret)
//         {
//             if (error == ErrorCode.NONE)
//                 set_error (ErrorCode.INVALID);
//
//             error_code = error;
//             error_token = this.error_token;
//             error_start = error_token_start;
//             error_end = error_token_end;
//             return false;
//         }
//
//         error_code = ErrorCode.NONE;
//         error_token = null;
//         error_start = 0;
//         error_end = 0;
//
//         return true;
//     }
//
//     public void set_error (ErrorCode errorno, string? token = null, uint token_start = 0, uint token_end = 0)
//     {
//         error = errorno;
//         error_token = token;
//         error_token_start = input.char_count (token_start);
//         error_token_end = input.char_count (token_end);
//     }
//
//     public void set_representation_base (uint new_base)
//     {
//         representation_base = new_base;
//     }
//
//     public virtual bool variable_is_defined (string name)
//     {
//         return false;
//     }
//
//     public virtual Number? get_variable (string name)
//     {
//         return null;
//     }
//
//     public virtual void set_variable (string name, Number x)
//     {
//     }
//
//     public virtual bool function_is_defined (string name)
//     {
//         return false;
//     }
//
//     public virtual bool unit_is_defined (string name)
//     {
//         return false;
//     }
//
//     public virtual bool literal_base_is_defined (string name)
//     {
//         return false;
//     }
//
//     public virtual Number? convert (Number x, string x_units, string z_units)
//     {
//         return null;
//     }
//
//     /* Start parsing input string. And call evaluate on success. */
//     public Number? parse (out uint representation_base, out ErrorCode error_code, out string? error_token, out uint error_start, out uint error_end)
//     {
//         var is_successfully_parsed = create_parse_tree (out representation_base, out error_code, out error_token, out error_start, out error_end);
//
//         if (!is_successfully_parsed)
//             return null;
//         var ans = root.solve ();
//         if (ans == null && this.error == ErrorCode.NONE)
//         {
//             error_code = ErrorCode.INVALID;
//             error_token = null;
//             error_start = error_token_start;
//             error_end = error_token_end;
//             return null;
//         }
//
//         representation_base = this.representation_base;
//         error_code = this.error;
//         error_token = this.error_token;
//         error_start = this.error_token_start;
//         error_end = this.error_token_end;
//         return ans;
//     }
//
//     /* Converts LexerTokenType to Precedence value. */
//     private Precedence get_precedence (LexerTokenType type)
//     {
//         /* WARNING: This function doesn't work for Unary Plus and Unary Minus. Use their precedence directly while inserting them in tree. */
//         if (type == LexerTokenType.ADD || type == LexerTokenType.SUBTRACT)
//             return Precedence.ADD_SUBTRACT;
//         if (type == LexerTokenType.MULTIPLY)
//             return Precedence.MULTIPLY;
//         if (type == LexerTokenType.MOD)
//             return Precedence.MOD;
//         if (type == LexerTokenType.DIVIDE)
//             return Precedence.DIVIDE;
//         if (type == LexerTokenType.NOT)
//             return Precedence.NOT;
//         if (type == LexerTokenType.ROOT || type == LexerTokenType.ROOT_3 || type == LexerTokenType.ROOT_4)
//             return Precedence.ROOT;
//         if (type == LexerTokenType.FUNCTION)
//             return Precedence.FUNCTION;
//         if (type == LexerTokenType.AND || type == LexerTokenType.OR || type == LexerTokenType.XOR)
//             return Precedence.BOOLEAN;
//         if (type == LexerTokenType.PERCENTAGE)
//             return Precedence.PERCENTAGE;
//         if (type == LexerTokenType.POWER)
//             return Precedence.POWER;
//         if (type == LexerTokenType.FACTORIAL)
//             return Precedence.FACTORIAL;
//         if (type == LexerTokenType.NUMBER || type == LexerTokenType.VARIABLE)
//             return Precedence.NUMBER_VARIABLE;
//         if (type == LexerTokenType.UNIT)
//             return Precedence.UNIT;
//         if (type == LexerTokenType.IN)
//             return Precedence.CONVERT;
//         if (type == LexerTokenType.SHIFT_LEFT || type == LexerTokenType.SHIFT_RIGHT)
//             return Precedence.SHIFT;
//         if (type == LexerTokenType.L_R_BRACKET || type == LexerTokenType.R_R_BRACKET)
//             return Precedence.DEPTH;
//         return Precedence.TOP;
//     }
//
//     /* Return associativity of specific token type from precedence. */
//     private Associativity get_associativity_p (Precedence type)
//     {
//         if (type == Precedence.BOOLEAN || type == Precedence.DIVIDE || type == Precedence.MOD || type == Precedence.MULTIPLY || type == Precedence.ADD_SUBTRACT)
//             return Associativity.LEFT;
//         if (type == Precedence.POWER)
//             return Associativity.RIGHT;
//         /* For all remaining / non-associative operators, return Left Associativity. */
//         return Associativity.LEFT;
//     }
//
//     /* Return associativity of specific token by converting it to precedence first. */
//     private Associativity get_associativity (LexerToken token)
//     {
//         return get_associativity_p (get_precedence (token.type));
//     }
//
//     /* Generate precedence for a node from precedence value. Includes depth_level. */
//     private uint make_precedence_p (Precedence p)
//     {
//         return p + (depth_level * Precedence.DEPTH);
//     }
//
//     /* Generate precedence for a node from lexer token type. Includes depth_level. */
//     private uint make_precedence_t (LexerTokenType type)
//     {
//         return get_precedence (type) + (depth_level * Precedence.DEPTH);
//     }
//
//     /* Compares two nodes to decide, which will be parent and which will be child. */
//     private bool cmp_nodes (ParseNode? left, ParseNode? right)
//     {
//         /* Return values:
//          * true = right goes up (near root) in parse tree.
//          * false = left  goes up (near root) in parse tree.
//          */
//         if (left == null)
//             return false;
//         if (left.precedence > right.precedence)
//             return true;
//         else if (left.precedence < right.precedence)
//             return false;
//         else
//             return right.associativity != Associativity.RIGHT;
//     }
//
//     /* Unified interface (unary and binary nodes) to insert node into parse tree. */
//     private void insert_into_tree_all (ParseNode node, bool unary_function)
//     {
//         if (root == null)
//         {
//             root = node;
//             right_most = root;
//             return;
//         }
//         ParseNode tmp = right_most;
//         while (cmp_nodes (tmp, node))
//             tmp = tmp.parent;
//
//         if (unary_function)
//         {
//             /* If tmp is null, that means, we have to insert new node at root. */
//             if (tmp == null)
//             {
//                 node.right = root;
//                 node.right.parent = node;
//
//                 root = node;
//             }
//             else
//             {
//                 node.right = tmp.right;
//                 if (node.right != null)
//                     node.right.parent = node;
//
//                 tmp.right = node;
//                 if (tmp.right != null)
//                     tmp.right.parent = tmp;
//
//             }
//             right_most = node;
//             while (right_most.right != null)
//                 right_most = right_most.right;
//         }
//         else
//         {
//             /* If tmp is null, that means, we have to insert new node at root. */
//             if (tmp == null)
//             {
//                 node.left = root;
//                 node.left.parent = node;
//
//                 root = node;
//             }
//             else
//             {
//                 node.left = tmp.right;
//                 if (node.left != null)
//                     node.left.parent = node;
//
//                 tmp.right = node;
//                 if (tmp.right != null)
//                     tmp.right.parent = tmp;
//
//             }
//             right_most = node;
//         }
//     }
//
//     /* Insert binary node into the parse tree. */
//     private void insert_into_tree (ParseNode node)
//     {
//         insert_into_tree_all (node, false);
//     }
//
//     /* Insert unary node into the parse tree. */
//     private void insert_into_tree_unary (ParseNode node)
//     {
//         insert_into_tree_all (node, true);
//     }
//
//     /* Recursive call to free every node of parse-tree. */
//     private void destroy_all_nodes (ParseNode node)
//     {
//         if (node == null)
//             return;
//
//         destroy_all_nodes (node.left);
//         destroy_all_nodes (node.right);
//         /* Don't call free for tokens, as they are allocated and freed in lexer. */
//         /* WARNING: If node.value is freed elsewhere, please assign it null before calling destroy_all_nodes (). */
//     }
//
//     /* LL (*) parser. Lookahead count depends on tokens. Handle with care. :P */
//
//     /* Check if string "name" is a valid variable for given Parser. It is the same code, used to get the value of variable in parserfunc.c. */
//     private bool check_variable (string name)
//     {
//         /* If defined, then get the variable */
//         if (variable_is_defined (name))
//             return true;
//
//         /* If has more than one character then assume a multiplication of variables */
//         var index = 0;
//         unichar c;
//         while (name.get_next_char (ref index, out c))
//         {
//             if (!variable_is_defined (c.to_string ()))
//                 return false;
//         }
//
//         return true;
//     }
//
//     private bool statement ()
//     {
//         var token = lexer.get_next_token ();
//         if (token.type == LexerTokenType.VARIABLE || token.type == LexerTokenType.FUNCTION)
//         {
//             var token_old = token;
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.ASSIGN)
//             {
//                 insert_into_tree (new NameNode (this, token_old, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity (token_old)));
//                 insert_into_tree (new AssignNode (this, token, 0, get_associativity (token)));
//
//                 if (!expression ())
//                     return false;
//
//                 return true;
//             }
//             else
//             {
//                 lexer.roll_back ();
//                 lexer.roll_back ();
//
//                 if (token.type == LexerTokenType.L_R_BRACKET)
//                 {
//                     if (function_definition ())
//                         return true;
//                 }
//
//                 if (!expression ())
//                     return false;
//
//                 return true;
//             }
//         }
//         else
//         {
//             lexer.roll_back ();
//             if (!expression ())
//                 return false;
//             return true;
//         }
//     }
//
//     private bool function_definition ()
//     {
//         int num_token_parsed = 0;
//         var token = lexer.get_next_token ();
//         num_token_parsed++;
//
//         string function_name = token.text;
//         lexer.get_next_token ();
//         num_token_parsed++;
//
//         token = lexer.get_next_token ();
//         num_token_parsed++;
//         string argument_list = "";
//         List<LexerToken> token_list = new List<LexerToken> ();
//
//         while (token.type != LexerTokenType.R_R_BRACKET && token.type != LexerTokenType.PL_EOS)
//         {
//             token_list.append (token);
//             argument_list += token.text;
//             token = lexer.get_next_token ();
//             num_token_parsed++;
//         }
//
//         if (token.type == LexerTokenType.PL_EOS)
//         {
//             while (num_token_parsed-- > 0)
//                 lexer.roll_back ();
//             return false;
//         }
//
//         var assign_token = lexer.get_next_token ();
//         num_token_parsed++;
//         if (assign_token.type != LexerTokenType.ASSIGN)
//         {
//             while (num_token_parsed-- > 0)
//                 lexer.roll_back ();
//             return false;
//         }
//
//         string expression = "";
//         token = lexer.get_next_token ();
//         while (token.type != LexerTokenType.PL_EOS)
//         {
//             expression += token.text;
//             token = lexer.get_next_token ();
//         }
//
//         insert_into_tree (new FunctionNameNode (this, null, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity_p (Precedence.NUMBER_VARIABLE), function_name));
//         insert_into_tree (new FunctionNode (this, null, make_precedence_p (Precedence.FUNCTION), get_associativity_p (Precedence.FUNCTION), null));
//         insert_into_tree (new FunctionArgumentsNode (this, token_list, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity_p (Precedence.NUMBER_VARIABLE), argument_list));
//         insert_into_tree (new AssignFunctionNode (this, assign_token, 0, get_associativity (assign_token)));
//         insert_into_tree (new FunctionDescriptionNode (this, null, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity_p (Precedence.NUMBER_VARIABLE), expression));
//
//         return true;
//     }
//
//     private bool conversion ()
//     {
//         var token = lexer.get_next_token ();
//         if (token.type == LexerTokenType.IN)
//         {
//             var token_in = token;
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.UNIT)
//             {
//                 var token_to = token;
//                 token = lexer.get_next_token ();
//                 /* We can only convert representation base, if it is next to End Of Stream */
//                 if (token.type == LexerTokenType.PL_EOS)
//                 {
//                     insert_into_tree (new ConvertBaseNode (this, token_in, make_precedence_p (Precedence.CONVERT), get_associativity (token_in)));
//                     insert_into_tree (new NameNode (this, token_to, make_precedence_p (Precedence.UNIT), get_associativity (token_to)));
//                     return true;
//                 }
//                 else
//                 {
//                     lexer.roll_back ();
//                     lexer.roll_back ();
//                     lexer.roll_back ();
//                     return false;
//                 }
//             }
//             else
//             {
//                 lexer.roll_back ();
//                 lexer.roll_back ();
//                 return false;
//             }
//         }
//         else if (token.type == LexerTokenType.UNIT)
//         {
//             var token_from = token;
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.IN)
//             {
//                 var token_in = token;
//                 token = lexer.get_next_token ();
//                 if (token.type == LexerTokenType.UNIT)
//                 {
//                     insert_into_tree (new NameNode (this, token_from, make_precedence_p (Precedence.UNIT), get_associativity (token_from)));
//                     insert_into_tree (new ConvertNumberNode (this, token_in, make_precedence_p (Precedence.CONVERT), get_associativity (token_in)));
//                     insert_into_tree (new NameNode (this, token, make_precedence_p (Precedence.UNIT), get_associativity (token)));
//                     return true;
//                 }
//                 else
//                 {
//                     lexer.roll_back ();
//                     lexer.roll_back ();
//                     lexer.roll_back ();
//                     return false;
//                 }
//             }
//             else
//             {
//                 lexer.roll_back ();
//                 lexer.roll_back ();
//                 return false;
//             }
//         }
//         else
//         {
//             lexer.roll_back ();
//             return false;
//         }
//     }
//
//     private bool expression ()
//     {
//         if (!expression_1 ())
//             return false;
//         if (!expression_2 ())
//             return false;
//         /* If there is a possible conversion at this level, insert it in the tree. */
//         conversion ();
//         return true;
//     }
//
//     private bool expression_1 ()
//     {
//         var token = lexer.get_next_token ();
//
//         if (token.type == LexerTokenType.PL_EOS || token.type == LexerTokenType.ASSIGN)
//         {
//             lexer.roll_back ();
//             return false;
//         }
//
//         if (token.type == LexerTokenType.L_R_BRACKET)
//         {
//             depth_level++;
//
//             if (!expression ())
//                 return false;
//
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.R_R_BRACKET)
//             {
//                 depth_level--;
//                 token = lexer.get_next_token ();
//                 lexer.roll_back ();
//
//                 if (token.type == LexerTokenType.NUMBER)
//                 {
//                     insert_into_tree (new MultiplyNode (this, null, make_precedence_p (Precedence.MULTIPLY), get_associativity_p (Precedence.MULTIPLY)));
//
//                     if (!expression ())
//                         return false;
//                     else
//                         return true;
//                  }
//                  else
//                      return true;
//             }
//             //Expected ")" here...
//             else
//                 return false;
//         }
//         else if (token.type == LexerTokenType.L_S_BRACKET)
//         {
//             depth_level++;
//
//             /* Give round, preference of Precedence.TOP aka 2, to keep it on the top of expression. */
//
//             insert_into_tree_unary (new RoundNode (this, token, make_precedence_p (Precedence.TOP), get_associativity (token)));
//
//             if (!expression ())
//                 return false;
//
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.R_S_BRACKET)
//             {
//                 depth_level--;
//                 return true;
//             }
//             else
//             //Expected "]" here...
//                 return false;
//         }
//         else if (token.type == LexerTokenType.L_C_BRACKET)
//         {
//             depth_level++;
//
//             /* Give fraction, preference of Precedence.TOP aka 2, to keep it on the top of expression. */
//
//             insert_into_tree_unary (new FractionalComponentNode (this, token, make_precedence_p (Precedence.TOP), get_associativity (token)));
//
//             if (!expression ())
//                 return false;
//
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.R_C_BRACKET)
//             {
//                 depth_level--;
//                 return true;
//             }
//             //Expected "}" here...
//             else
//                 return false;
//         }
//         else if (token.type == LexerTokenType.ABS)
//         {
//             depth_level++;
//
//             /* Give abs, preference of Precedence.TOP aka 2, to keep it on the top of expression. */
//
//             insert_into_tree_unary (new AbsoluteValueNode (this, token, make_precedence_p (Precedence.TOP), get_associativity (token)));
//
//             if (!expression ())
//                 return false;
//
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.ABS)
//             {
//                 depth_level--;
//                 return true;
//             }
//             //Expected "|" here...
//             else
//                 return false;
//         }
//         else if (token.type == LexerTokenType.NOT)
//         {
//             insert_into_tree_unary (new NotNode (this, token, make_precedence_p (Precedence.NOT), get_associativity (token)));
//
//             if (!expression ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.NUMBER)
//         {
//             insert_into_tree (new ConstantNode (this, token, make_precedence_t (token.type), get_associativity (token)));
//
//             token = lexer.get_next_token ();
//             lexer.roll_back ();
//
//             if (token.type == LexerTokenType.FUNCTION || token.type == LexerTokenType.VARIABLE || token.type == LexerTokenType.SUB_NUMBER || token.type == LexerTokenType.ROOT || token.type == LexerTokenType.ROOT_3 || token.type == LexerTokenType.ROOT_4)
//             {
//                 insert_into_tree (new MultiplyNode (this, null, make_precedence_p (Precedence.MULTIPLY), get_associativity_p (Precedence.MULTIPLY)));
//
//                 if (!variable ())
//                     return false;
//                 else
//                     return true;
//             }
//             else
//                 return true;
//         }
//         else if (token.type == LexerTokenType.L_FLOOR)
//         {
//             depth_level++;
//             /* Give floor, preference of Precedence.TOP aka 2, to keep it on the top of expression. */
//
//             insert_into_tree_unary (new FloorNode (this, null, make_precedence_p (Precedence.TOP), get_associativity_p (Precedence.TOP)));
//
//             if (!expression ())
//                 return false;
//
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.R_FLOOR)
//             {
//                 depth_level--;
//                 return true;
//             }
//             //Expected ⌋ here...
//             else
//                 return false;
//         }
//         else if (token.type == LexerTokenType.L_CEILING)
//         {
//             depth_level++;
//             /* Give ceiling, preference of Precedence.TOP aka 2, to keep it on the top of expression. */
//
//             insert_into_tree_unary (new CeilingNode (this, null, make_precedence_p (Precedence.TOP), get_associativity_p (Precedence.TOP)));
//
//             if (!expression ())
//                 return false;
//
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.R_CEILING)
//             {
//                 depth_level--;
//                 return true;
//             }
//             //Expected ⌉ here...
//             else
//                 return false;
//         }
//         else if (token.type == LexerTokenType.SUBTRACT)
//         {
//             insert_into_tree_unary (new UnaryMinusNode (this, token, make_precedence_p (Precedence.UNARY_MINUS), get_associativity_p (Precedence.UNARY_MINUS)));
//
//             if (!expression_1 ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.ADD)
//         {
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.NUMBER)
//             {
//                 /* Ignore ADD. It is not required. */
//                 insert_into_tree (new ConstantNode (this, token, make_precedence_t (token.type), get_associativity (token)));
//                 return true;
//             }
//             else
//                 return false;
//         }
//         else
//         {
//             lexer.roll_back ();
//             if (!variable ())
//                 return false;
//             else
//                 return true;
//         }
//     }
//
//     private bool expression_2 ()
//     {
//         var token = lexer.get_next_token ();
//         if (token.type == LexerTokenType.L_R_BRACKET)
//         {
//             insert_into_tree (new MultiplyNode (this, null, make_precedence_p (Precedence.MULTIPLY), get_associativity_p (Precedence.MULTIPLY)));
//
//             depth_level++;
//             if (!expression ())
//                 return false;
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.R_R_BRACKET)
//             {
//                 depth_level--;
//
//                 if (!expression_2 ())
//                     return false;
//
//                 return true;
//             }
//             else
//                 return false;
//         }
//         else if (token.type == LexerTokenType.POWER)
//         {
//             insert_into_tree (new XPowYNode (this, token, make_precedence_t (token.type), get_associativity (token)));
//
//             if (!expression_1 ())
//                 return false;
//             if (!expression_2 ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.SUP_NUMBER)
//         {
//             insert_into_tree (new XPowYIntegerNode (this, null, make_precedence_p (Precedence.POWER), get_associativity_p (Precedence.POWER)));
//             insert_into_tree (new NameNode (this, token, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity_p (Precedence.NUMBER_VARIABLE)));
//
//             if (!expression_2 ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.NSUP_NUMBER)
//         {
//             insert_into_tree (new XPowYIntegerNode (this, null, make_precedence_p (Precedence.POWER), get_associativity_p (Precedence.POWER)));
//             insert_into_tree (new NameNode (this, token, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity_p (Precedence.NUMBER_VARIABLE)));
//
//             if (!expression_2 ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.FACTORIAL)
//         {
//             insert_into_tree_unary (new FactorialNode (this, token, make_precedence_t (token.type), get_associativity (token)));
//
//             if (!expression_2 ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.MULTIPLY)
//         {
//             insert_into_tree (new MultiplyNode (this, token, make_precedence_t (token.type), get_associativity (token)));
//
//             if (!expression_1 ())
//                 return false;
//             if (!expression_2 ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.PERCENTAGE)
//         {
//             insert_into_tree_unary (new PercentNode (this, token, make_precedence_t (token.type), get_associativity (token)));
//
//             if (!expression_2 ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.AND)
//         {
//             insert_into_tree (new AndNode (this, token, make_precedence_t (token.type), get_associativity (token)));
//
//             if (!expression_1 ())
//                 return false;
//             if (!expression_2 ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.OR)
//         {
//             insert_into_tree (new OrNode (this, token, make_precedence_t (token.type), get_associativity (token)));
//
//             if (!expression_1 ())
//                 return false;
//             if (!expression_2 ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.XOR)
//         {
//             insert_into_tree (new XorNode (this, token, make_precedence_t (token.type), get_associativity (token)));
//
//             if (!expression_1 ())
//                 return false;
//             if (!expression_2 ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.DIVIDE)
//         {
//             insert_into_tree (new DivideNode (this, token, make_precedence_t (token.type), get_associativity (token)));
//
//             if (!expression_1 ())
//                 return false;
//             if (!expression_2 ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.SHIFT_LEFT || token.type == LexerTokenType.SHIFT_RIGHT)
//         {
//             insert_into_tree (new ShiftNode (this, token, make_precedence_t (token.type), get_associativity (token)));
//
//             if (!expression_1 ())
//                 return false;
//             if (!expression_2 ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.MOD)
//         {
//             insert_into_tree (new ModulusDivideNode (this, token, make_precedence_t (token.type), get_associativity (token)));
//
//             if (!expression_1 ())
//                 return false;
//             if (!expression_2 ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.ADD)
//         {
//             var node = new AddNode (this, token, make_precedence_t (token.type), get_associativity (token));
//             insert_into_tree (node);
//
//             if (!expression_1 ())
//                 return false;
//
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.PERCENTAGE)
//             {
//                 //FIXME: This condition needs to be verified for all cases.. :(
//                 if (node.right.precedence > Precedence.PERCENTAGE)
//                 {
//                     var next_token  = lexer.get_next_token ();
//                     lexer.roll_back ();
//
//                     if (next_token.text != "" && get_precedence (next_token.type) < Precedence.PERCENTAGE)
//                     {
//                         lexer.roll_back ();
//                         if (!expression_2 ())
//                             return true;
//                     }
//
//                     node.precedence = make_precedence_p (Precedence.PERCENTAGE);
//                     node.do_percentage = true;
//                     return true;
//                 }
//                 else
//                 {
//                     /* Assume '%' to be part of 'expression PERCENTAGE' statement. */
//                     lexer.roll_back ();
//                     if (!expression_2 ())
//                         return true;
//                 }
//             }
//             else
//                 lexer.roll_back ();
//
//             if (!expression_2 ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.SUBTRACT)
//         {
//             var node = new SubtractNode (this, token, make_precedence_t (token.type), get_associativity (token));
//             insert_into_tree (node);
//
//             if (!expression_1 ())
//                 return false;
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.PERCENTAGE)
//             {
//                 //FIXME: This condition needs to be verified for all cases.. :(
//                 if (node.right.precedence > Precedence.PERCENTAGE)
//                 {
//                     var next_token  = lexer.get_next_token ();
//                     lexer.roll_back ();
//
//                     if (next_token.text != "" && get_precedence (next_token.type) < Precedence.PERCENTAGE)
//                     {
//                         lexer.roll_back ();
//                         if (!expression_2 ())
//                             return true;
//                     }
//
//                     node.precedence = make_precedence_p (Precedence.PERCENTAGE);
//                     node.do_percentage = true;
//                     return true;
//                 }
//                 else
//                 {
//                     /* Assume '%' to be part of 'expression PERCENTAGE' statement. */
//                     lexer.roll_back ();
//                     if (!expression_2 ())
//                         return true;
//                 }
//             }
//             else
//                 lexer.roll_back ();
//
//             if (!expression_2 ())
//                 return false;
//
//             return true;
//         }
//         else
//         {
//             lexer.roll_back ();
//             return true;
//         }
//     }
//
//     private bool variable ()
//     {
//         var token = lexer.get_next_token ();
//         if (token.type == LexerTokenType.FUNCTION)
//         {
//             lexer.roll_back ();
//             if (!function_invocation ())
//                 return false;
//             return true;
//         }
//         else if (token.type == LexerTokenType.SUB_NUMBER)
//         {
//             var token_old = token;
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.ROOT)
//             {
//                 insert_into_tree_unary (new RootNode.WithToken (this, token, make_precedence_t (token.type), get_associativity (token), token_old));
//                 if (!expression ())
//                     return false;
//
//                 return true;
//             }
//             else
//                 return false;
//         }
//         else if (token.type == LexerTokenType.ROOT)
//         {
//             insert_into_tree_unary (new RootNode (this, token, make_precedence_t (token.type), get_associativity (token), 2));
//
//             if (!expression ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.ROOT_3)
//         {
//             insert_into_tree_unary (new RootNode (this, token, make_precedence_t (token.type), get_associativity (token), 3));
//
//             if (!expression ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.ROOT_4)
//         {
//             insert_into_tree_unary (new RootNode (this, token, make_precedence_t (token.type), get_associativity (token), 4));
//
//             if (!expression ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.VARIABLE)
//         {
//             lexer.roll_back ();
//             //TODO: unknown function ERROR for (VARIABLE SUP_NUMBER expression).
//             if (!term ())
//                 return false;
//
//             return true;
//         }
//         else
//             return false;
//     }
//
//     private bool function_invocation ()
//     {
//         depth_level++;
//         int num_token_parsed = 0;
//         var fun_token = lexer.get_next_token ();
//         num_token_parsed ++;
//         string function_name = fun_token.text;
//
//         insert_into_tree (new FunctionNameNode (this, fun_token, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity_p (Precedence.NUMBER_VARIABLE), function_name));
//
//         var token = lexer.get_next_token ();
//         num_token_parsed++;
//         string? power = null;
//         if (token.type == LexerTokenType.SUP_NUMBER || token.type == LexerTokenType.NSUP_NUMBER)
//         {
//             power = token.text;
//             token = lexer.get_next_token ();
//             num_token_parsed++;
//         }
//
//         insert_into_tree (new FunctionNode (this, fun_token, make_precedence_t (fun_token.type), get_associativity (fun_token), power));
//
//         if (token.type == LexerTokenType.L_R_BRACKET)
//         {
//             token = lexer.get_next_token ();
//             num_token_parsed++;
//             int m_depth = 1;
//             string argument_list = "";
//             List<LexerToken> token_list = new List<LexerToken>();
//
//             while (token.type != LexerTokenType.PL_EOS && token.type != LexerTokenType.ASSIGN)
//             {
//                 if (token.type == LexerTokenType.L_R_BRACKET)
//                     m_depth++;
//                 else if (token.type == LexerTokenType.R_R_BRACKET)
//                 {
//                     m_depth--;
//                     if (m_depth == 0)
//                         break;
//                 }
//                 else
//                     token_list.append(token);
//                 argument_list += token.text;
//                 token = lexer.get_next_token ();
//                 num_token_parsed++;
//             }
//
//             if (token.type != LexerTokenType.R_R_BRACKET)
//             {
//                 while (num_token_parsed-- > 0)
//                     lexer.roll_back ();
//                 depth_level--;
//                 return false;
//             }
//
//             insert_into_tree (new FunctionArgumentsNode (this, token_list, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity_p (Precedence.NUMBER_VARIABLE), argument_list));
//         }
//         else
//         {
//             lexer.roll_back ();
//             if (!expression_1 ())
//             {
//                 lexer.roll_back ();
//                 depth_level--;
//                 return false;
//             }
//
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.FACTORIAL)
//                 insert_into_tree_unary (new FactorialNode (this, token, make_precedence_t (token.type), get_associativity (token)));
//             else
//                 lexer.roll_back ();
//
//             depth_level--;
//
//             if (!expression_2 ())
//             {
//                 lexer.roll_back ();
//                 return false;
//             }
//             return true;
//         }
//
//         depth_level--;
//         return true;
//     }
//
//     private bool term ()
//     {
//         var token = lexer.get_next_token ();
//
//         if (token.type == LexerTokenType.VARIABLE)
//         {
//             var token_old = token;
//             token = lexer.get_next_token ();
//             /* Check if the token is a valid variable or not. */
//             if (!check_variable (token_old.text))
//             {
//                 if (token.text == "(")
//                     set_error (ErrorCode.UNKNOWN_FUNCTION, token_old.text, token_old.start_index, token_old.end_index);
//                 else
//                     set_error (ErrorCode.UNKNOWN_VARIABLE, token_old.text, token_old.start_index, token_old.end_index);
//                 return false;
//             }
//             if (token.type == LexerTokenType.SUP_NUMBER)
//                 insert_into_tree (new VariableWithPowerNode (this, token_old, make_precedence_t (token_old.type), get_associativity (token_old), token.text));
//             else
//             {
//                 lexer.roll_back ();
//                 insert_into_tree (new VariableNode (this, token_old, make_precedence_t (token_old.type), get_associativity (token_old)));
//             }
//
//             if (!term_2 ())
//                 return false;
//
//             return true;
//         }
//         else
//             return false;
//     }
//
//     private bool term_2 ()
//     {
//         var token = lexer.get_next_token ();
//         lexer.roll_back ();
//
//         if (token.type == LexerTokenType.PL_EOS || token.type == LexerTokenType.ASSIGN)
//             return true;
//
//         if (token.type == LexerTokenType.FUNCTION || token.type == LexerTokenType.VARIABLE || token.type == LexerTokenType.SUB_NUMBER || token.type == LexerTokenType.ROOT || token.type == LexerTokenType.ROOT_3 || token.type == LexerTokenType.ROOT_4)
//         {
//             /* Insert multiply in between variable and (function, variable, root) */
//             insert_into_tree (new MultiplyNode (this, null, make_precedence_p (Precedence.MULTIPLY), get_associativity_p (Precedence.MULTIPLY)));
//             if (!variable ())
//                 return false;
//             return true;
//         }
//         else
//             return true;
//     }
// }
//
// the following is the equivalent Dart code to the previous commented Vala code that defines the Parser class:
//
class Parser {
  // Vala code:
  //     private string input;
  //     private ParseNode root;
  //     private ParseNode right_most;
  //     private Lexer lexer;
  //     public int number_base;
  //     public int wordlen;
  //     public AngleUnit angle_units;
  //     private uint depth_level;
  //     private ErrorCode error;
  //     private string error_token;
  //     private int error_token_start;
  //     private int error_token_end;
  //     private uint representation_base;
  //
  //     public static HashTable<string, Number> CONSTANTS;
  //
  //     static construct {
  //         CONSTANTS = new HashTable<string, Number> (str_hash, str_equal);
  //         CONSTANTS.insert ("e", new Number.eulers ());
  //         CONSTANTS.insert ("pi", new Number.pi ());
  //         CONSTANTS.insert ("tau", new Number.tau ());
  //         CONSTANTS.insert ("π", new Number.pi ());
  //         CONSTANTS.insert ("τ", new Number.tau ());
  //         CONSTANTS.insert ("i", new Number.i ());
  //     }
  //
  // Dart code:
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
    "e": Number.eulers(),
    "pi": Number.pi(),
    "tau": Number.tau(),
    "π": Number.pi(),
    "τ": Number.tau(),
    "i": Number.i()
  };

  // Getter for wordLen
  int get wordlen => wordLen;

  // the following is a commented Vala code that defines the Parser constructor:
  // public Parser (string input, int number_base, int wordlen, AngleUnit angle_units)
  // {
  //   this.input = input;
  //   lexer = new Lexer (input, this, number_base);
  //   root = null;
  //   depth_level = 0;
  //   right_most = null;
  //   this.number_base = number_base;
  //   this.representation_base = number_base;
  //   this.wordlen = wordlen;
  //   this.angle_units = angle_units;
  //   error = ErrorCode.NONE;
  //   error_token = null;
  //   error_token_start = 0;
  //   error_token_end = 0;
  // }
  //
  // this is the equivalent Dart code to the previous commented Vala code that defines the Parser constructor:
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

  // the following is a commented Vala code that defines the create_parse_tree method:
//     public bool create_parse_tree (out uint representation_base, out ErrorCode error_code, out string? error_token, out uint error_start, out uint error_end)
//     {
//         representation_base = number_base;
//         /* Scan string and split into tokens */
//         lexer.scan ();
//
//         /* Parse tokens */
//         var ret = statement ();
//
//         var token = lexer.get_next_token ();
//         if (token.type == LexerTokenType.ASSIGN)
//         {
//             token = lexer.get_next_token ();
//             if (token.type != LexerTokenType.PL_EOS)
//             {
//                 /* Full string is not parsed. */
//                 if (error == ErrorCode.NONE)
//                     set_error (ErrorCode.INVALID, token.text, token.start_index, token.end_index);
//
//                 error_code = error;
//                 error_token = this.error_token;
//                 error_start = error_token_start;
//                 error_end = error_token_end;
//                 return false;
//             }
//         }
//         if (token.type != LexerTokenType.PL_EOS)
//         {
//             /* Full string is not parsed. */
//             if (error == ErrorCode.NONE)
//                 set_error (ErrorCode.INVALID, token.text, token.start_index, token.end_index);
//
//             error_code = error;
//             error_token = this.error_token;
//             error_start = error_token_start;
//             error_end = error_token_end;
//             return false;
//         }
//
//         /* Input can't be parsed with grammar. */
//         if (!ret)
//         {
//             if (error == ErrorCode.NONE)
//                 set_error (ErrorCode.INVALID);
//
//             error_code = error;
//             error_token = this.error_token;
//             error_start = error_token_start;
//             error_end = error_token_end;
//             return false;
//         }
//
//         error_code = ErrorCode.NONE;
//         error_token = null;
//         error_start = 0;
//         error_end = 0;
//
//         return true;
//     }
//
  // this is the equivalent Dart code to the previous commented Vala code that defines the createParseTree method:
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

  // The following is a commented Vala code that defines the setError method:
// public void set_error (ErrorCode errorno, string? token = null, uint token_start = 0, uint token_end = 0)
// {
// error = errorno;
// error_token = token;
// error_token_start = input.char_count (token_start);
// error_token_end = input.char_count (token_end);
// }
//
// this is the equivalent Dart code to the previous commented Vala code that defines the setError method:
//
  void setError(ErrorCode errorno,
      [String? token, int tokenStart = 0, int tokenEnd = 0]) {
    error = errorno;
    errorToken = token;
    errorTokenStart = input.charCount(tokenStart);
    errorTokenEnd = input.charCount(tokenEnd);
  }

  // The following is a commented Vala code that defines the following methods: setRepresentationBase, variableIsDefined, getVariable, setVariable, functionIsDefined, unitIsDefined, literalBaseIsDefined, and convert:
// public void set_representation_base (uint new_base)
// {
//   representation_base = new_base;
// }
//
// public virtual bool variable_is_defined (string name)
// {
//   return false;
// }
//
// public virtual Number? get_variable (string name)
// {
//   return null;
// }
//
// public virtual void set_variable (string name, Number x)
// {
// }
//
// public virtual bool function_is_defined (string name)
// {
//   return false;
// }
//
// public virtual bool unit_is_defined (string name)
// {
//   return false;
// }
//
// public virtual bool literal_base_is_defined (string name)
// {
//   return false;
// }
//
// public virtual Number? convert (Number x, string x_units, string z_units)
// {
//   return null;
// }
//
// this is the equivalent Dart code to the previous commented Vala code that defines the following methods: setRepresentationBase, variableIsDefined, getVariable, setVariable, functionIsDefined, unitIsDefined, literalBaseIsDefined, and convert:
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

  // The following is a commented Vala code that defines the following method parse:
//   /* Start parsing input string. And call evaluate on success. */
//   public Number? parse (out uint representation_base, out ErrorCode error_code, out string? error_token, out uint error_start, out uint error_end)
//   {
//   var is_successfully_parsed = create_parse_tree (out representation_base, out error_code, out error_token, out error_start, out error_end);
//
//   if (!is_successfully_parsed)
//   return null;
//   var ans = root.solve ();
//   if (ans == null && this.error == ErrorCode.NONE)
//   {
//   error_code = ErrorCode.INVALID;
//   error_token = null;
//   error_start = error_token_start;
//   error_end = error_token_end;
//   return null;
//   }
//
//   representation_base = this.representation_base;
//   error_code = this.error;
//   error_token = this.error_token;
//   error_start = this.error_token_start;
//   error_end = this.error_token_end;
//   return ans;
//   }
//
// this is the equivalent Dart code to the previous commented Vala code that defines the parse method:
  /* Start parsing input string. And call evaluate on success. */
  ParseResult parse() {
    var result = createParseTree();

    if (!result.result) {
      return ParseResult(
          representationBase: numberBase,
          errorCode: result.errorCode,
          errorToken: result.errorToken,
          errorStart: result.errorStart,
          errorEnd: result.errorEnd,
          result: null);
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
          result: null);
    }

    return ParseResult(
        representationBase: representationBase,
        errorCode: error,
        errorToken: errorToken,
        errorStart: errorTokenStart,
        errorEnd: errorTokenEnd,
        result: ans);
  }

  // The following is a commented Vala code that defines the following method get_precedence.
// /* Converts LexerTokenType to Precedence value. */
//   private Precedence get_precedence (LexerTokenType type)
//   {
//     /* WARNING: This function doesn't work for Unary Plus and Unary Minus. Use their precedence directly while inserting them in tree. */
//     if (type == LexerTokenType.ADD || type == LexerTokenType.SUBTRACT)
//       return Precedence.ADD_SUBTRACT;
//     if (type == LexerTokenType.MULTIPLY)
//       return Precedence.MULTIPLY;
//     if (type == LexerTokenType.MOD)
//       return Precedence.MOD;
//     if (type == LexerTokenType.DIVIDE)
//       return Precedence.DIVIDE;
//     if (type == LexerTokenType.NOT)
//       return Precedence.NOT;
//     if (type == LexerTokenType.ROOT || type == LexerTokenType.ROOT_3 || type == LexerTokenType.ROOT_4)
//       return Precedence.ROOT;
//     if (type == LexerTokenType.FUNCTION)
//       return Precedence.FUNCTION;
//     if (type == LexerTokenType.AND || type == LexerTokenType.OR || type == LexerTokenType.XOR)
//       return Precedence.BOOLEAN;
//     if (type == LexerTokenType.PERCENTAGE)
//       return Precedence.PERCENTAGE;
//     if (type == LexerTokenType.POWER)
//       return Precedence.POWER;
//     if (type == LexerTokenType.FACTORIAL)
//       return Precedence.FACTORIAL;
//     if (type == LexerTokenType.NUMBER || type == LexerTokenType.VARIABLE)
//       return Precedence.NUMBER_VARIABLE;
//     if (type == LexerTokenType.UNIT)
//       return Precedence.UNIT;
//     if (type == LexerTokenType.IN)
//       return Precedence.CONVERT;
//     if (type == LexerTokenType.SHIFT_LEFT || type == LexerTokenType.SHIFT_RIGHT)
//       return Precedence.SHIFT;
//     if (type == LexerTokenType.L_R_BRACKET || type == LexerTokenType.R_R_BRACKET)
//       return Precedence.DEPTH;
//     return Precedence.TOP;
//   }
//
// this is the equivalent Dart code to the previous commented Vala code that defines the getPrecedence method:
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

  // The following is a commented Vala code that defines the methods get_associativity_p, get_associativity, make_precedence_p, make_precedence_t and cmp_nodes:
//   /* Return associativity of specific token type from precedence. */
//   private Associativity get_associativity_p (Precedence type)
//   {
//     if (type == Precedence.BOOLEAN || type == Precedence.DIVIDE || type == Precedence.MOD || type == Precedence.MULTIPLY || type == Precedence.ADD_SUBTRACT)
//       return Associativity.LEFT;
//     if (type == Precedence.POWER)
//       return Associativity.RIGHT;
//     /* For all remaining / non-associative operators, return Left Associativity. */
//     return Associativity.LEFT;
//   }
//
//   /* Return associativity of specific token by converting it to precedence first. */
//   private Associativity get_associativity (LexerToken token)
//   {
//     return get_associativity_p (get_precedence (token.type));
//   }
//
//   /* Generate precedence for a node from precedence value. Includes depth_level. */
//   private uint make_precedence_p (Precedence p)
//   {
//     return p + (depth_level * Precedence.DEPTH);
//   }
//
//   /* Generate precedence for a node from lexer token type. Includes depth_level. */
//   private uint make_precedence_t (LexerTokenType type)
//   {
//     return get_precedence (type) + (depth_level * Precedence.DEPTH);
//   }
//
//   /* Compares two nodes to decide, which will be parent and which will be child. */
//   private bool cmp_nodes (ParseNode? left, ParseNode? right)
//   {
//     /* Return values:
//          * true = right goes up (near root) in parse tree.
//          * false = left  goes up (near root) in parse tree.
//          */
//     if (left == null)
//       return false;
//     if (left.precedence > right.precedence)
//       return true;
//     else if (left.precedence < right.precedence)
//       return false;
//     else
//       return right.associativity != Associativity.RIGHT;
//   }
//
// this is the equivalent Dart code to the previous commented Vala code that defines the following methods: getAssociativityP, getAssociativity, makePrecedenceP, makePrecedenceT, and cmpNodes:
  /* Return associativity of specific token type from precedence. */
  Associativity getAssociativityP(Precedence type) {
    if (type == Precedence.boolean || type == Precedence.divide ||
        type == Precedence.mod || type == Precedence.multiply ||
        type == Precedence.addSubtract) {
      return Associativity.left;
    }
    if (type == Precedence.power) {
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
    return p.index + (depthLevel * Precedence.depth.index);
  }

  /* Generate precedence for a node from lexer token type. Includes depthLevel. */
  int makePrecedenceT(LexerTokenType type) {
    return getPrecedence(type).index + (depthLevel * Precedence.depth.index);
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
    } else if (left.precedence < right.precedence) {
      return false;
    } else {
      return right.associativity != Associativity.right;
    }
  }

  // The following is a commented Vala code that defines the following methods: insert_into_tree_all, insert_into_tree, and insert_into_tree_unary:
  // /* Unified interface (unary and binary nodes) to insert node into parse tree. */
  // private void insert_into_tree_all (ParseNode node, bool unary_function)
  // {
  //   if (root == null)
  //   {
  //     root = node;
  //     right_most = root;
  //     return;
  //   }
  //   ParseNode tmp = right_most;
  //   while (cmp_nodes (tmp, node))
  //     tmp = tmp.parent;
  //
  //   if (unary_function)
  //   {
  //     /* If tmp is null, that means, we have to insert new node at root. */
  //     if (tmp == null)
  //     {
  //       node.right = root;
  //       node.right.parent = node;
  //
  //       root = node;
  //     }
  //     else
  //     {
  //       node.right = tmp.right;
  //       if (node.right != null)
  //         node.right.parent = node;
  //
  //       tmp.right = node;
  //       if (tmp.right != null)
  //         tmp.right.parent = tmp;
  //
  //     }
  //     right_most = node;
  //     while (right_most.right != null)
  //       right_most = right_most.right;
  //   }
  //   else
  //   {
  //     /* If tmp is null, that means, we have to insert new node at root. */
  //     if (tmp == null)
  //     {
  //       node.left = root;
  //       node.left.parent = node;
  //
  //       root = node;
  //     }
  //     else
  //     {
  //       node.left = tmp.right;
  //       if (node.left != null)
  //         node.left.parent = node;
  //
  //       tmp.right = node;
  //       if (tmp.right != null)
  //         tmp.right.parent = tmp;
  //
  //     }
  //     right_most = node;
  //   }
  // }
  //
  // /* Insert binary node into the parse tree. */
  // private void insert_into_tree (ParseNode node)
  // {
  //   insert_into_tree_all (node, false);
  // }
  //
  // /* Insert unary node into the parse tree. */
  // private void insert_into_tree_unary (ParseNode node)
  // {
  //   insert_into_tree_all (node, true);
  // }
  //
  // this is the equivalent Dart code to the previous commented Vala code that defines the following methods: insertIntoTreeAll, insertIntoTree, and insertIntoTreeUnary:
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
      } else {
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
    } else {
      /* If tmp is null, that means, we have to insert new node at root. */
      if (tmp == null) {
        node.left = root;
        node.left!.parent = node;

        root = node;
      } else {
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

  // Consider the following lines of commented Vala code that defines the following methods: destroy_all_nodes, check_variable, and statement:
//   /* Recursive call to free every node of parse-tree. */
//   private void destroy_all_nodes (ParseNode node)
//   {
//     if (node == null)
//       return;
//
//     destroy_all_nodes (node.left);
//     destroy_all_nodes (node.right);
//     /* Don't call free for tokens, as they are allocated and freed in lexer. */
//     /* WARNING: If node.value is freed elsewhere, please assign it null before calling destroy_all_nodes (). */
//   }
//
//   /* LL (*) parser. Lookahead count depends on tokens. Handle with care. :P */
//
//   /* Check if string "name" is a valid variable for given Parser. It is the same code, used to get the value of variable in parserfunc.c. */
//   private bool check_variable (string name)
//   {
//     /* If defined, then get the variable */
//     if (variable_is_defined (name))
//       return true;
//
//     /* If has more than one character then assume a multiplication of variables */
//     var index = 0;
//     unichar c;
//     while (name.get_next_char (ref index, out c))
//     {
//       if (!variable_is_defined (c.to_string ()))
//         return false;
//     }
//
//     return true;
//   }
//
//   private bool statement ()
//   {
//     var token = lexer.get_next_token ();
//     if (token.type == LexerTokenType.VARIABLE || token.type == LexerTokenType.FUNCTION)
//     {
//       var token_old = token;
//       token = lexer.get_next_token ();
//       if (token.type == LexerTokenType.ASSIGN)
//       {
//         insert_into_tree (new NameNode (this, token_old, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity (token_old)));
//         insert_into_tree (new AssignNode (this, token, 0, get_associativity (token)));
//
//         if (!expression ())
//           return false;
//
//         return true;
//       }
//       else
//       {
//         lexer.roll_back ();
//         lexer.roll_back ();
//
//         if (token.type == LexerTokenType.L_R_BRACKET)
//         {
//           if (function_definition ())
//             return true;
//         }
//
//         if (!expression ())
//           return false;
//
//         return true;
//       }
//     }
//     else
//     {
//       lexer.roll_back ();
//       if (!expression ())
//         return false;
//       return true;
//     }
//   }
//
// this is the equivalent Dart code to the previous commented Vala code that defines the following methods: destroyAllNodes, checkVariable, and statement:
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

    // Consider the following lines of commented Vala code:
    // /* If has more than one character then assume a multiplication of variables */
    // var index = 0;
    // unichar c;
    // while (name.get_next_char (ref index, out c))
    // {
    //   if (!variable_is_defined (c.to_string ()))
    //     return false;
    // }
    //
    // this is the equivalent of the above Vala code:
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

    return true;
  }

  bool statement() {
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
      } else {
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
    } else {
      lexer.rollBack();
      if (!expression()) {
        return false;
      }
      return true;
    }
  }

  // The following is a commented Vala code that defines the following methods: function_definition, conversion, expression, expression_1, and expression_2:
  // private bool function_definition ()
  // {
  //   int num_token_parsed = 0;
  //   var token = lexer.get_next_token ();
  //   num_token_parsed++;
  //
  //   string function_name = token.text;
  //   lexer.get_next_token ();
  //   num_token_parsed++;
  //
  //   token = lexer.get_next_token ();
  //   num_token_parsed++;
  //   string argument_list = "";
  //   List<LexerToken> token_list = new List<LexerToken> ();
  //
  //   while (token.type != LexerTokenType.R_R_BRACKET && token.type != LexerTokenType.PL_EOS)
  //   {
  //     token_list.append (token);
  //     argument_list += token.text;
  //     token = lexer.get_next_token ();
  //     num_token_parsed++;
  //   }
  //
  //   if (token.type == LexerTokenType.PL_EOS)
  //   {
  //     while (num_token_parsed-- > 0)
  //       lexer.roll_back ();
  //     return false;
  //   }
  //
  //   var assign_token = lexer.get_next_token ();
  //   num_token_parsed++;
  //   if (assign_token.type != LexerTokenType.ASSIGN)
  //   {
  //     while (num_token_parsed-- > 0)
  //       lexer.roll_back ();
  //     return false;
  //   }
  //
  //   string expression = "";
  //   token = lexer.get_next_token ();
  //   while (token.type != LexerTokenType.PL_EOS)
  //   {
  //     expression += token.text;
  //     token = lexer.get_next_token ();
  //   }
  //
  //   insert_into_tree (new FunctionNameNode (this, null, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity_p (Precedence.NUMBER_VARIABLE), function_name));
  //   insert_into_tree (new FunctionNode (this, null, make_precedence_p (Precedence.FUNCTION), get_associativity_p (Precedence.FUNCTION), null));
  //   insert_into_tree (new FunctionArgumentsNode (this, token_list, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity_p (Precedence.NUMBER_VARIABLE), argument_list));
  //   insert_into_tree (new AssignFunctionNode (this, assign_token, 0, get_associativity (assign_token)));
  //   insert_into_tree (new FunctionDescriptionNode (this, null, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity_p (Precedence.NUMBER_VARIABLE), expression));
  //
  //   return true;
  // }
  //
  // private bool conversion ()
  // {
  //   var token = lexer.get_next_token ();
  //   if (token.type == LexerTokenType.IN)
  //   {
  //     var token_in = token;
  //     token = lexer.get_next_token ();
  //     if (token.type == LexerTokenType.UNIT)
  //     {
  //       var token_to = token;
  //       token = lexer.get_next_token ();
  //       /* We can only convert representation base, if it is next to End Of Stream */
  //       if (token.type == LexerTokenType.PL_EOS)
  //       {
  //         insert_into_tree (new ConvertBaseNode (this, token_in, make_precedence_p (Precedence.CONVERT), get_associativity (token_in)));
  //         insert_into_tree (new NameNode (this, token_to, make_precedence_p (Precedence.UNIT), get_associativity (token_to)));
  //         return true;
  //       }
  //       else
  //       {
  //         lexer.roll_back ();
  //         lexer.roll_back ();
  //         lexer.roll_back ();
  //         return false;
  //       }
  //     }
  //     else
  //     {
  //       lexer.roll_back ();
  //       lexer.roll_back ();
  //       return false;
  //     }
  //   }
  //   else if (token.type == LexerTokenType.UNIT)
  //   {
  //     var token_from = token;
  //     token = lexer.get_next_token ();
  //     if (token.type == LexerTokenType.IN)
  //     {
  //       var token_in = token;
  //       token = lexer.get_next_token ();
  //       if (token.type == LexerTokenType.UNIT)
  //       {
  //         insert_into_tree (new NameNode (this, token_from, make_precedence_p (Precedence.UNIT), get_associativity (token_from)));
  //         insert_into_tree (new ConvertNumberNode (this, token_in, make_precedence_p (Precedence.CONVERT), get_associativity (token_in)));
  //         insert_into_tree (new NameNode (this, token, make_precedence_p (Precedence.UNIT), get_associativity (token)));
  //         return true;
  //       }
  //       else
  //       {
  //         lexer.roll_back ();
  //         lexer.roll_back ();
  //         lexer.roll_back ();
  //         return false;
  //       }
  //     }
  //     else
  //     {
  //       lexer.roll_back ();
  //       lexer.roll_back ();
  //       return false;
  //     }
  //   }
  //   else
  //   {
  //     lexer.roll_back ();
  //     return false;
  //   }
  // }
  //
  // private bool expression ()
  // {
  //   if (!expression_1 ())
  //     return false;
  //   if (!expression_2 ())
  //     return false;
  //   /* If there is a possible conversion at this level, insert it in the tree. */
  //   conversion ();
  //   return true;
  // }
  //
  // private bool expression_1 ()
  // {
  //   var token = lexer.get_next_token ();
  //
  //   if (token.type == LexerTokenType.PL_EOS || token.type == LexerTokenType.ASSIGN)
  //   {
  //     lexer.roll_back ();
  //     return false;
  //   }
  //
  //   if (token.type == LexerTokenType.L_R_BRACKET)
  //   {
  //     depth_level++;
  //
  //     if (!expression ())
  //       return false;
  //
  //     token = lexer.get_next_token ();
  //     if (token.type == LexerTokenType.R_R_BRACKET)
  //     {
  //       depth_level--;
  //       token = lexer.get_next_token ();
  //       lexer.roll_back ();
  //
  //       if (token.type == LexerTokenType.NUMBER)
  //       {
  //         insert_into_tree (new MultiplyNode (this, null, make_precedence_p (Precedence.MULTIPLY), get_associativity_p (Precedence.MULTIPLY)));
  //
  //         if (!expression ())
  //           return false;
  //         else
  //           return true;
  //       }
  //       else
  //         return true;
  //     }
  //     //Expected ")" here...
  //     else
  //       return false;
  //   }
  //   else if (token.type == LexerTokenType.L_S_BRACKET)
  //   {
  //     depth_level++;
  //
  //     /* Give round, preference of Precedence.TOP aka 2, to keep it on the top of expression. */
  //
  //     insert_into_tree_unary (new RoundNode (this, token, make_precedence_p (Precedence.TOP), get_associativity (token)));
  //
  //     if (!expression ())
  //       return false;
  //
  //     token = lexer.get_next_token ();
  //     if (token.type == LexerTokenType.R_S_BRACKET)
  //     {
  //       depth_level--;
  //       return true;
  //     }
  //     else
  //       //Expected "]" here...
  //       return false;
  //   }
  //   else if (token.type == LexerTokenType.L_C_BRACKET)
  //   {
  //     depth_level++;
  //
  //     /* Give fraction, preference of Precedence.TOP aka 2, to keep it on the top of expression. */
  //
  //     insert_into_tree_unary (new FractionalComponentNode (this, token, make_precedence_p (Precedence.TOP), get_associativity (token)));
  //
  //     if (!expression ())
  //       return false;
  //
  //     token = lexer.get_next_token ();
  //     if (token.type == LexerTokenType.R_C_BRACKET)
  //     {
  //       depth_level--;
  //       return true;
  //     }
  //     //Expected "}" here...
  //     else
  //       return false;
  //   }
  //   else if (token.type == LexerTokenType.ABS)
  //   {
  //     depth_level++;
  //
  //     /* Give abs, preference of Precedence.TOP aka 2, to keep it on the top of expression. */
  //
  //     insert_into_tree_unary (new AbsoluteValueNode (this, token, make_precedence_p (Precedence.TOP), get_associativity (token)));
  //
  //     if (!expression ())
  //       return false;
  //
  //     token = lexer.get_next_token ();
  //     if (token.type == LexerTokenType.ABS)
  //     {
  //       depth_level--;
  //       return true;
  //     }
  //     //Expected "|" here...
  //     else
  //       return false;
  //   }
  //   else if (token.type == LexerTokenType.NOT)
  //   {
  //     insert_into_tree_unary (new NotNode (this, token, make_precedence_p (Precedence.NOT), get_associativity (token)));
  //
  //     if (!expression ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.NUMBER)
  //   {
  //     insert_into_tree (new ConstantNode (this, token, make_precedence_t (token.type), get_associativity (token)));
  //
  //     token = lexer.get_next_token ();
  //     lexer.roll_back ();
  //
  //     if (token.type == LexerTokenType.FUNCTION || token.type == LexerTokenType.VARIABLE || token.type == LexerTokenType.SUB_NUMBER || token.type == LexerTokenType.ROOT || token.type == LexerTokenType.ROOT_3 || token.type == LexerTokenType.ROOT_4)
  //     {
  //       insert_into_tree (new MultiplyNode (this, null, make_precedence_p (Precedence.MULTIPLY), get_associativity_p (Precedence.MULTIPLY)));
  //
  //       if (!variable ())
  //         return false;
  //       else
  //         return true;
  //     }
  //     else
  //       return true;
  //   }
  //   else if (token.type == LexerTokenType.L_FLOOR)
  //   {
  //     depth_level++;
  //     /* Give floor, preference of Precedence.TOP aka 2, to keep it on the top of expression. */
  //
  //     insert_into_tree_unary (new FloorNode (this, null, make_precedence_p (Precedence.TOP), get_associativity_p (Precedence.TOP)));
  //
  //     if (!expression ())
  //       return false;
  //
  //     token = lexer.get_next_token ();
  //     if (token.type == LexerTokenType.R_FLOOR)
  //     {
  //       depth_level--;
  //       return true;
  //     }
  //     //Expected ⌋ here...
  //     else
  //       return false;
  //   }
  //   else if (token.type == LexerTokenType.L_CEILING)
  //   {
  //     depth_level++;
  //     /* Give ceiling, preference of Precedence.TOP aka 2, to keep it on the top of expression. */
  //
  //     insert_into_tree_unary (new CeilingNode (this, null, make_precedence_p (Precedence.TOP), get_associativity_p (Precedence.TOP)));
  //
  //     if (!expression ())
  //       return false;
  //
  //     token = lexer.get_next_token ();
  //     if (token.type == LexerTokenType.R_CEILING)
  //     {
  //       depth_level--;
  //       return true;
  //     }
  //     //Expected ⌉ here...
  //     else
  //       return false;
  //   }
  //   else if (token.type == LexerTokenType.SUBTRACT)
  //   {
  //     insert_into_tree_unary (new UnaryMinusNode (this, token, make_precedence_p (Precedence.UNARY_MINUS), get_associativity_p (Precedence.UNARY_MINUS)));
  //
  //     if (!expression_1 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.ADD)
  //   {
  //     token = lexer.get_next_token ();
  //     if (token.type == LexerTokenType.NUMBER)
  //     {
  //       /* Ignore ADD. It is not required. */
  //       insert_into_tree (new ConstantNode (this, token, make_precedence_t (token.type), get_associativity (token)));
  //       return true;
  //     }
  //     else
  //       return false;
  //   }
  //   else
  //   {
  //     lexer.roll_back ();
  //     if (!variable ())
  //       return false;
  //     else
  //       return true;
  //   }
  // }
  //
  // private bool expression_2 ()
  // {
  //   var token = lexer.get_next_token ();
  //   if (token.type == LexerTokenType.L_R_BRACKET)
  //   {
  //     insert_into_tree (new MultiplyNode (this, null, make_precedence_p (Precedence.MULTIPLY), get_associativity_p (Precedence.MULTIPLY)));
  //
  //     depth_level++;
  //     if (!expression ())
  //       return false;
  //     token = lexer.get_next_token ();
  //     if (token.type == LexerTokenType.R_R_BRACKET)
  //     {
  //       depth_level--;
  //
  //       if (!expression_2 ())
  //         return false;
  //
  //       return true;
  //     }
  //     else
  //       return false;
  //   }
  //   else if (token.type == LexerTokenType.POWER)
  //   {
  //     insert_into_tree (new XPowYNode (this, token, make_precedence_t (token.type), get_associativity (token)));
  //
  //     if (!expression_1 ())
  //       return false;
  //     if (!expression_2 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.SUP_NUMBER)
  //   {
  //     insert_into_tree (new XPowYIntegerNode (this, null, make_precedence_p (Precedence.POWER), get_associativity_p (Precedence.POWER)));
  //     insert_into_tree (new NameNode (this, token, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity_p (Precedence.NUMBER_VARIABLE)));
  //
  //     if (!expression_2 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.NSUP_NUMBER)
  //   {
  //     insert_into_tree (new XPowYIntegerNode (this, null, make_precedence_p (Precedence.POWER), get_associativity_p (Precedence.POWER)));
  //     insert_into_tree (new NameNode (this, token, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity_p (Precedence.NUMBER_VARIABLE)));
  //
  //     if (!expression_2 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.FACTORIAL)
  //   {
  //     insert_into_tree_unary (new FactorialNode (this, token, make_precedence_t (token.type), get_associativity (token)));
  //
  //     if (!expression_2 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.MULTIPLY)
  //   {
  //     insert_into_tree (new MultiplyNode (this, token, make_precedence_t (token.type), get_associativity (token)));
  //
  //     if (!expression_1 ())
  //       return false;
  //     if (!expression_2 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.PERCENTAGE)
  //   {
  //     insert_into_tree_unary (new PercentNode (this, token, make_precedence_t (token.type), get_associativity (token)));
  //
  //     if (!expression_2 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.AND)
  //   {
  //     insert_into_tree (new AndNode (this, token, make_precedence_t (token.type), get_associativity (token)));
  //
  //     if (!expression_1 ())
  //       return false;
  //     if (!expression_2 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.OR)
  //   {
  //     insert_into_tree (new OrNode (this, token, make_precedence_t (token.type), get_associativity (token)));
  //
  //     if (!expression_1 ())
  //       return false;
  //     if (!expression_2 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.XOR)
  //   {
  //     insert_into_tree (new XorNode (this, token, make_precedence_t (token.type), get_associativity (token)));
  //
  //     if (!expression_1 ())
  //       return false;
  //     if (!expression_2 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.DIVIDE)
  //   {
  //     insert_into_tree (new DivideNode (this, token, make_precedence_t (token.type), get_associativity (token)));
  //
  //     if (!expression_1 ())
  //       return false;
  //     if (!expression_2 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.SHIFT_LEFT || token.type == LexerTokenType.SHIFT_RIGHT)
  //   {
  //     insert_into_tree (new ShiftNode (this, token, make_precedence_t (token.type), get_associativity (token)));
  //
  //     if (!expression_1 ())
  //       return false;
  //     if (!expression_2 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.MOD)
  //   {
  //     insert_into_tree (new ModulusDivideNode (this, token, make_precedence_t (token.type), get_associativity (token)));
  //
  //     if (!expression_1 ())
  //       return false;
  //     if (!expression_2 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.ADD)
  //   {
  //     var node = new AddNode (this, token, make_precedence_t (token.type), get_associativity (token));
  //     insert_into_tree (node);
  //
  //     if (!expression_1 ())
  //       return false;
  //
  //     token = lexer.get_next_token ();
  //     if (token.type == LexerTokenType.PERCENTAGE)
  //     {
  //       //FIXME: This condition needs to be verified for all cases.. :(
  //       if (node.right.precedence > Precedence.PERCENTAGE)
  //       {
  //         var next_token  = lexer.get_next_token ();
  //         lexer.roll_back ();
  //
  //         if (next_token.text != "" && get_precedence (next_token.type) < Precedence.PERCENTAGE)
  //         {
  //           lexer.roll_back ();
  //           if (!expression_2 ())
  //             return true;
  //         }
  //
  //         node.precedence = make_precedence_p (Precedence.PERCENTAGE);
  //         node.do_percentage = true;
  //         return true;
  //       }
  //       else
  //       {
  //         /* Assume '%' to be part of 'expression PERCENTAGE' statement. */
  //         lexer.roll_back ();
  //         if (!expression_2 ())
  //           return true;
  //       }
  //     }
  //     else
  //       lexer.roll_back ();
  //
  //     if (!expression_2 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else if (token.type == LexerTokenType.SUBTRACT)
  //   {
  //     var node = new SubtractNode (this, token, make_precedence_t (token.type), get_associativity (token));
  //     insert_into_tree (node);
  //
  //     if (!expression_1 ())
  //       return false;
  //     token = lexer.get_next_token ();
  //     if (token.type == LexerTokenType.PERCENTAGE)
  //     {
  //       //FIXME: This condition needs to be verified for all cases.. :(
  //       if (node.right.precedence > Precedence.PERCENTAGE)
  //       {
  //         var next_token  = lexer.get_next_token ();
  //         lexer.roll_back ();
  //
  //         if (next_token.text != "" && get_precedence (next_token.type) < Precedence.PERCENTAGE)
  //         {
  //           lexer.roll_back ();
  //           if (!expression_2 ())
  //             return true;
  //         }
  //
  //         node.precedence = make_precedence_p (Precedence.PERCENTAGE);
  //         node.do_percentage = true;
  //         return true;
  //       }
  //       else
  //       {
  //         /* Assume '%' to be part of 'expression PERCENTAGE' statement. */
  //         lexer.roll_back ();
  //         if (!expression_2 ())
  //           return true;
  //       }
  //     }
  //     else
  //       lexer.roll_back ();
  //
  //     if (!expression_2 ())
  //       return false;
  //
  //     return true;
  //   }
  //   else
  //   {
  //     lexer.roll_back ();
  //     return true;
  //   }
  // }
  //
  // this is the equivalent Dart code to the previous commented Vala code that defines the following methods: functionDefinition, conversion, expression, expression1, and expression2:
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
    var token = lexer.getNextToken();

    if (token.type == LexerTokenType.plEOS ||
        token.type == LexerTokenType.assign) {
      lexer.rollBack();
      return false;
    }

    if (token.type == LexerTokenType.lRBracket) {
      depthLevel++;

      if (!expression()) {
        return false;
      }

      token = lexer.getNextToken();
      if (token.type == LexerTokenType.rRBracket) {
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
      insertIntoTree(ConstantNode(
          this, token, makePrecedenceT(token.type), getAssociativity(token)));

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
      insertIntoTreeUnary(UnaryMinusNode(
          this, token, makePrecedenceP(Precedence.unaryMinus),
          getAssociativityP(Precedence.unaryMinus)));

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

// The following is a commented Vala code that defines the following methods: variable,function_invocation, term andterm_2.
//     private bool variable ()
//     {
//         var token = lexer.get_next_token ();
//         if (token.type == LexerTokenType.FUNCTION)
//         {
//             lexer.roll_back ();
//             if (!function_invocation ())
//                 return false;
//             return true;
//         }
//         else if (token.type == LexerTokenType.SUB_NUMBER)
//         {
//             var token_old = token;
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.ROOT)
//             {
//                 insert_into_tree_unary (new RootNode.WithToken (this, token, make_precedence_t (token.type), get_associativity (token), token_old));
//                 if (!expression ())
//                     return false;
//
//                 return true;
//             }
//             else
//                 return false;
//         }
//         else if (token.type == LexerTokenType.ROOT)
//         {
//             insert_into_tree_unary (new RootNode (this, token, make_precedence_t (token.type), get_associativity (token), 2));
//
//             if (!expression ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.ROOT_3)
//         {
//             insert_into_tree_unary (new RootNode (this, token, make_precedence_t (token.type), get_associativity (token), 3));
//
//             if (!expression ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.ROOT_4)
//         {
//             insert_into_tree_unary (new RootNode (this, token, make_precedence_t (token.type), get_associativity (token), 4));
//
//             if (!expression ())
//                 return false;
//
//             return true;
//         }
//         else if (token.type == LexerTokenType.VARIABLE)
//         {
//             lexer.roll_back ();
//             //TODO: unknown function ERROR for (VARIABLE SUP_NUMBER expression).
//             if (!term ())
//                 return false;
//
//             return true;
//         }
//         else
//             return false;
//     }
//
//     private bool function_invocation ()
//     {
//         depth_level++;
//         int num_token_parsed = 0;
//         var fun_token = lexer.get_next_token ();
//         num_token_parsed ++;
//         string function_name = fun_token.text;
//
//         insert_into_tree (new FunctionNameNode (this, fun_token, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity_p (Precedence.NUMBER_VARIABLE), function_name));
//
//         var token = lexer.get_next_token ();
//         num_token_parsed++;
//         string? power = null;
//         if (token.type == LexerTokenType.SUP_NUMBER || token.type == LexerTokenType.NSUP_NUMBER)
//         {
//             power = token.text;
//             token = lexer.get_next_token ();
//             num_token_parsed++;
//         }
//
//         insert_into_tree (new FunctionNode (this, fun_token, make_precedence_t (fun_token.type), get_associativity (fun_token), power));
//
//         if (token.type == LexerTokenType.L_R_BRACKET)
//         {
//             token = lexer.get_next_token ();
//             num_token_parsed++;
//             int m_depth = 1;
//             string argument_list = "";
//             List<LexerToken> token_list = new List<LexerToken>();
//
//             while (token.type != LexerTokenType.PL_EOS && token.type != LexerTokenType.ASSIGN)
//             {
//                 if (token.type == LexerTokenType.L_R_BRACKET)
//                     m_depth++;
//                 else if (token.type == LexerTokenType.R_R_BRACKET)
//                 {
//                     m_depth--;
//                     if (m_depth == 0)
//                         break;
//                 }
//                 else
//                     token_list.append(token);
//                 argument_list += token.text;
//                 token = lexer.get_next_token ();
//                 num_token_parsed++;
//             }
//
//             if (token.type != LexerTokenType.R_R_BRACKET)
//             {
//                 while (num_token_parsed-- > 0)
//                     lexer.roll_back ();
//                 depth_level--;
//                 return false;
//             }
//
//             insert_into_tree (new FunctionArgumentsNode (this, token_list, make_precedence_p (Precedence.NUMBER_VARIABLE), get_associativity_p (Precedence.NUMBER_VARIABLE), argument_list));
//         }
//         else
//         {
//             lexer.roll_back ();
//             if (!expression_1 ())
//             {
//                 lexer.roll_back ();
//                 depth_level--;
//                 return false;
//             }
//
//             token = lexer.get_next_token ();
//             if (token.type == LexerTokenType.FACTORIAL)
//                 insert_into_tree_unary (new FactorialNode (this, token, make_precedence_t (token.type), get_associativity (token)));
//             else
//                 lexer.roll_back ();
//
//             depth_level--;
//
//             if (!expression_2 ())
//             {
//                 lexer.roll_back ();
//                 return false;
//             }
//             return true;
//         }
//
//         depth_level--;
//         return true;
//     }
//
//     private bool term ()
//     {
//         var token = lexer.get_next_token ();
//
//         if (token.type == LexerTokenType.VARIABLE)
//         {
//             var token_old = token;
//             token = lexer.get_next_token ();
//             /* Check if the token is a valid variable or not. */
//             if (!check_variable (token_old.text))
//             {
//                 if (token.text == "(")
//                     set_error (ErrorCode.UNKNOWN_FUNCTION, token_old.text, token_old.start_index, token_old.end_index);
//                 else
//                     set_error (ErrorCode.UNKNOWN_VARIABLE, token_old.text, token_old.start_index, token_old.end_index);
//                 return false;
//             }
//             if (token.type == LexerTokenType.SUP_NUMBER)
//                 insert_into_tree (new VariableWithPowerNode (this, token_old, make_precedence_t (token_old.type), get_associativity (token_old), token.text));
//             else
//             {
//                 lexer.roll_back ();
//                 insert_into_tree (new VariableNode (this, token_old, make_precedence_t (token_old.type), get_associativity (token_old)));
//             }
//
//             if (!term_2 ())
//                 return false;
//
//             return true;
//         }
//         else
//             return false;
//     }
//
//     private bool term_2 ()
//     {
//         var token = lexer.get_next_token ();
//         lexer.roll_back ();
//
//         if (token.type == LexerTokenType.PL_EOS || token.type == LexerTokenType.ASSIGN)
//             return true;
//
//         if (token.type == LexerTokenType.FUNCTION || token.type == LexerTokenType.VARIABLE || token.type == LexerTokenType.SUB_NUMBER || token.type == LexerTokenType.ROOT || token.type == LexerTokenType.ROOT_3 || token.type == LexerTokenType.ROOT_4)
//         {
//             /* Insert multiply in between variable and (function, variable, root) */
//             insert_into_tree (new MultiplyNode (this, null, make_precedence_p (Precedence.MULTIPLY), get_associativity_p (Precedence.MULTIPLY)));
//             if (!variable ())
//                 return false;
//             return true;
//         }
//         else
//             return true;
//     }
//
// this is the equivalent Dart code to the previous commented Vala code that defines the following methods: variable, functionInvocation, term and term2:
  bool variable() {
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
      insertIntoTreeUnary(RootNode(
          this, token, makePrecedenceT(token.type), getAssociativity(token),
          2));

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
