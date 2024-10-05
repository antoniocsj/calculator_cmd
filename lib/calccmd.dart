import 'dart:io';
import 'package:calculator/enums.dart';
import 'package:calculator/types.dart';
import 'package:calculator/serializer.dart';
import 'package:calculator/number.dart';
import 'package:calculator/equation.dart';

const int maxLine = 1024;

late Serializer resultSerializer;

void solve(String equation) {
  var e = Equation(equation);
  e.base = 10;
  e.wordlen = 32;
  e.angleUnits = AngleUnit.degrees;

  // variables to store the result of the parsing
  var ret = ErrorCode.none;
  var representationBase = 10;
  var errorToken = '';
  var errorStart = 0;
  var errorEnd = 0;

  // reference to the variables above
  var retRef = RefErrorCode(ret);
  var representationBaseRef = RefInt(representationBase);
  var errorTokenRef = RefString(errorToken);
  var errorStartRef = RefInt(errorStart);
  var errorEndRef = RefInt(errorEnd);

  // parse the equation
  var z = e.parse(
    representationBase: representationBaseRef,
    errorCode: retRef,
    errorToken: errorTokenRef,
    errorStart: errorStartRef,
    errorEnd: errorEndRef,
  );

  // update the variables from the references
  ret = retRef.value;
  representationBase = representationBaseRef.value;
  errorToken = errorTokenRef.value;
  errorStart = errorStartRef.value;
  errorEnd = errorEndRef.value;

  resultSerializer.setRepresentationBase(representationBase);
  if (z != null) {
    var str = resultSerializer.serialize(z);
    if (resultSerializer.error != null) {
      stderr.writeln(resultSerializer.error);
      resultSerializer.error = null;
    } else {
      stdout.writeln(str);
    }
  } else if (ret == ErrorCode.mp) {
    stderr.writeln("Error ${Number.error ?? errorToken}");
  } else {
    stderr.writeln("Error $ret");
  }
}

void main(List<String> args) {
  var requiresNewLine = false;

  resultSerializer = Serializer(DisplayFormat.automatic, 10, 9);

  while (true) {
    stdout.write("> ");
    var line = stdin.readLineSync();
    if (line != null) {
      line = line.trim();
    } else {
      requiresNewLine = true;
    }

    if (line == null || line == "exit" || line == "quit" || line == "") {
      break;
    }

    solve(line);
  }

  if (requiresNewLine) {
    stdout.writeln();
  }
}
