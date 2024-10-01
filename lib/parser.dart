import 'package:calculator/enums.dart';
import 'package:calculator/lexer.dart';
import 'package:calculator/number.dart';


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
  RNode(Parser parser, LexerToken? token, int precedence, Associativity associativity)
      : super(parser, token, precedence, associativity);

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
      while (tmpleft?.left != null) tmpleft = tmpleft?.left;
      while (tmpright?.right != null) tmpright = tmpright?.right;
      parser.setError(ErrorCode.mp, Number.error, tmpleft?.firstToken().startIndex, tmpright?.lastToken().endIndex);
      Number.error = null;
    }
    return z;
  }

  Number? solveR(Number r);
}

abstract class LRNode extends ParseNode {
  LRNode(Parser parser, LexerToken? token, int precedence, Associativity associativity)
      : super(parser, token, precedence, associativity);

  @override
  Number? solve() {
    var l = left.solve();
    var r = right.solve();
    if (l == null || r == null) return null;
    var z = solveLR(l, r);

    // check for errors
    Number.checkFlags();
    if (Number.error != null) {
      var tmpleft = left;
      var tmpright = right;
      while (tmpleft.left != null) tmpleft = tmpleft.left;
      while (tmpright.right != null) tmpright = tmpright.right;
      parser.setError(ErrorCode.mp, Number.error, tmpleft.firstToken().startIndex, tmpright.lastToken().endIndex);
      Number.error = null;
    }
    return z;
  }

  Number solveLR(Number left, Number r);
}
