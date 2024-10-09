import 'dart:io';
import 'package:calculator/enums.dart';
import 'package:calculator/types.dart';
import 'package:calculator/serializer.dart';
import 'package:calculator/number.dart';
import 'package:calculator/equation.dart';

const int maxLine = 1024;

late Serializer resultSerializer;

String? solve(String equation) {
  var e = Equation(equation);
  e.base = 10;
  e.wordlen = 32;
  e.angleUnits = AngleUnit.degrees;

  // variables to store the result of the parsing
  var errorCode = ErrorCode.none;
  var representationBase = 10;
  var errorToken = '';
  var errorStart = 0;
  var errorEnd = 0;

  // reference to the variables above
  var errorCodeRef = RefErrorCode(errorCode);
  var representationBaseRef = RefInt(representationBase);
  var errorTokenRef = RefString(errorToken);
  var errorStartRef = RefInt(errorStart);
  var errorEndRef = RefInt(errorEnd);

  // parse the equation
  var z = e.parse(
    representationBase: representationBaseRef,
    errorCode: errorCodeRef,
    errorToken: errorTokenRef,
    errorStart: errorStartRef,
    errorEnd: errorEndRef,
  );

  // update the variables from the references
  errorCode = errorCodeRef.value;
  representationBase = representationBaseRef.value;
  errorToken = errorTokenRef.value;
  errorStart = errorStartRef.value;
  errorEnd = errorEndRef.value;

  resultSerializer.setRepresentationBase(representationBase);
  String? output = '';

  if (z != null) {
    var str = resultSerializer.serialize(z);
    if (resultSerializer.error != null) {
      // stderr.writeln(resultSerializer.error);
      output = resultSerializer.error;
      resultSerializer.error = null;
    } else {
      // stdout.writeln(str);
      output = str;
    }
  } else if (errorCode == ErrorCode.mp) {
    // stderr.writeln("Error ${Number.error ?? errorToken}");
    output = "Error ${Number.error ?? errorToken}";
  } else {
    // stderr.writeln("Error $errorCode");
    output = "Error $errorCode";
  }

  return output;
}

// void main(List<String> args) {
//   var requiresNewLine = false;
//
//   resultSerializer = Serializer(DisplayFormat.automatic, 10, 9);
//
//   while (true) {
//     stdout.write("> ");
//     var line = stdin.readLineSync();
//     if (line != null) {
//       line = line.trim();
//     } else {
//       requiresNewLine = true;
//     }
//
//     if (line == null || line == "exit" || line == "quit" || line == "") {
//       break;
//     }
//
//     solve(line);
//   }
//
//   if (requiresNewLine) {
//     stdout.writeln();
//   }
// }

// void main() {
//   resultSerializer = Serializer(DisplayFormat.automatic, 10, 9);
//
//   String line = '3.6 + 1.8';
//   solve(line);
// }

// tests for the solve function
void main() {
  resultSerializer = Serializer(DisplayFormat.automatic, 10, 9);

  var testCases = [
    // ['3.6 + 1.8', '5.4'],
    // ['3.6 - 1.8', '1.8'],
    // ['3.6 * 1.8', '6.48'],
    // ['3.6 / 1.8', '2'],
    // ['3.6 ^ 1.8', '10.031006259'],
    ['36 mod 18', '0'],
    // ['3.6 + 1.8 * 2', '7.2'],
    // ['3.6 * 1.8 + 2', '9.48'],
    // ['3.6 + 1.8 / 2', '4.5'],
    // ['3.6 / 1.8 + 2', '3'],
    // ['3.6 - 1.8 * 2', '0'],
    // ['3.6 * 1.8 - 2', '4.48'],
    // ['3.6 - 1.8 / 2', '2.7'],
    // ['3.6 / 1.8 - 2', '0'],
    // ['3.6 ^ 1.8 * 2', '9.331854'],
    // ['3.6 * 1.8 ^ 2', '11.664'],
    // ['3.6 ^ 1.8 / 2', '2.332963'],
    // ['3.6 / 1.8 ^ 2', '1'],
    // ['3.6 ^ 1.8 + 2', '6.065927'],
    // ['3.6 + 1.8 ^ 2', '6.24'],
    // ['3.6 ^ 1.8 - 2', '2.465927'],
    // ['3.6 - 1.8 ^ 2', '1.44'],
    // ['3.6 ^ 1.8 % 2', '1.665927'],
    // ['3.6 % 1.8 ^ 2', '0'],
    // ['3.6 % 1.8 % 2', '0'],
    // ['3.6 % 1.8 + 2', '4.4'],
    // ['3.6 + 1.8 % 2', '5.4'],
  ];

  for (var testCase in testCases) {
    var input = testCase[0];
    var expected = testCase[1];
    var output = solve(input);

    if (output != expected) {
      stderr.writeln('Test failed: $input => $output, expected $expected');
    }
    else {
      stdout.writeln('Test passed: $input => $output');
    }

  }
}