import 'dart:io';
import 'package:calculator/enums.dart';
import 'package:calculator/types.dart';
import 'package:calculator/serializer.dart';
import 'package:calculator/number.dart';
import 'package:calculator/equation.dart';

const int maxLine = 1024;

late Serializer resultSerializer;

String? solve(String equation) {
  // var e = Equation(equation);
  var e = ConvertEquation(equation);
  // e.base = 10;
  // e.wordlen = 32;
  // e.angleUnits = AngleUnit.degrees;

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

// tests for the solve function
void testCases1() {
  resultSerializer = Serializer(DisplayFormat.automatic, 10, 9);

  var testCases = [
    // ['+1+2--3', '6'],
    // ['-0+0', '0'],
    // ['--2 - --3', '-1'],
    // ['-2---3', '-5'],
    // ['+1 + +2', '3'],
    // ['-----1', '-1'],
    // ['------1', '1'],
    // ['3.6 + 1.8', '5.4'],
    // ['3.6 - 1.8', '1.8'],
    // ['3.6 * 1.8', '6.48'],
    // ['3.6 / 1.8', '2'],
    // ['3.6 ^ 1.8', '10.031006259'],
    // ['36 mod 18', '0'],
    // ['3.6 + 1.8 * 2', '7.2'],
    // ['3.6 * 1.8 + 2', '8.48'],
    // ['3.6 + 1.8 / 2', '4.5'],
    // ['3.6 / 1.8 + 2', '4'],
    // ['3.6 - 1.8 * 2', '0'],
    // ['3.6 * 1.8 - 2', '4.48'],
    // ['3.6 - 1.8 / 2', '2.7'],
    // ['3.6 / 1.8 - 2', '0'],
    // ['3.6 ^ 1.8 * 2', '20.062012517'],
    // ['3.6 * 1.8 ^ 2', '11.664'],
    // ['3.6 ^ 1.8 / 2', '5.015503129'],
    // ['3.6 / 1.8 ^ 2', '1.111111111'],
    // ['3.6 ^ 1.8 + 2', '12.031006259'],
    // ['3.6 + 1.8 ^ 2', '6.84'],
    // ['3.6 ^ 1.8 - 2', '8.031006259'],
    // ['3.6 - 1.8 ^ 2', '0.36'],
    // ['3 ^ 8 mod 5', '1'],
    // ['36 mod 7 ^ 2', '36'],
    // ['36 mod 8 mod 3', '1'],
    // ['36 mod 11 + 2', '5'],
    // ['36 + 19 mod 2', '37'],
    // ['2 ^ 1000', '1.071508607×10³⁰¹'],
    // ['2³³³', '1.74980058×10¹⁰⁰'],
    // ['1/2²²', '0.000000238'],
    // ['sin(1)', '0.017452406'],
    // ['cos(1)', '0.999847695'],
    // ['tan(1)', '0.017455065'],
    // ['asin(1)', '90'],
    // ['acos(1)', '0'],
    // ['atan(1)', '45'],
    // ['sinh(1)', '1.175201194'],
    // ['cosh(1)', '1.543080635'],
    // ['tanh(1)', '0.761594156'],
    // ['asinh(1)', '0.881373587'],
    // ['acosh(1)', '0'],
    // ['log(1)', '0'],
    // ['log(1.2)', '0.079181246'],
    // ['log(16; 2)', '4'],
    // ['log(1024; 2)', '10'],
    // ['log(1000)', '3'],
    // ['log(100000000000000000000000000000)', '29'],
    // ['log(0.001)', '-3'],
    // ['log(0.0000000000000000000000000001)', '-28'],
    // ['ln(e)', '1'],
    // ['e', '2.718281828'],
    // ['pi', '3.141592654'],
    // ['log(1; 2)', '0'],
    // ['log(365; 128)', '1.215964665'],
    // ['{[(5+8)*3+2]+7/(1.6+(2.08-3.9))}/{(6-1.5)^(1.2+3.4)*[4-7.77]}', '0.241108609'],
    // ['(sin(2.3605)/-5.69)/(cos(sin(1/3.1415)*2)+0.05)-1/tan[(0.589)^(0.123)+1.28]+{cosh(4.36+(6.87^3.4+9.7)/3.1415)+log(4.456)}*(atan(1/acosh(1.2^2^2)))', '-8.146815842'],
    // ['sin(1+(1/((6*(e*pi)^(tanh[{1}*[2*asinh({1}/[2]*({3}*{4})*5)-6]^7]^8)/2/3)/4)-[tan(10)/cos(5+3*2)]^5))', '0.087155743'],
    // ['pi/1+pi/2+pi/3+pi/4+pi/5+pi/6+pi/7+pi/8+pi/9+pi/10', '9.201625149'],
    // ['√2', '1.414213562'],
    // ['2¹⁰', '1024'],
    // ['½', '0.5'],
    // ['⅓', '0.333333333'],
    // ['½+⅓', '0.833333333'],
    // ['½/⅓', '1.5'],
    // ['½²', '0.25'],
    // ['sin⁻¹(½²)²', '209.598359094'],
    // ['0 ∧ 0', '0'],
    // ['0 ∧ 1', '0'],
    // ['1 ∧ 0', '0'],
    // ['1 ∧ 1', '1'],
    // ['0 ∨ 0', '0'],
    // ['0 ∨ 1', '1'],
    // ['1 ∨ 0', '1'],
    // ['1 ∨ 1', '1'],
    // ['0 ⊻ 0', '0'],
    // ['0 ⊻ 1', '1'],
    // ['1 ⊻ 0', '1'],
    // ['1 ⊻ 1', '0'],
    // ['¬0', '4294967295'],
    // ['¬1', '4294967294'],
    // ['¬¬0', '0'],
    // ['¬¬1', '1'],
    // ['¬¬¬0', '4294967295'],
    // ['2^3^3', '134217728'],
    // ['100*½', '50'],
    // ['pi^e^pi-e^pi^e', '313768293556.051566006'],
    // ['1 m in cm', '100'],
    // ['1 mm to km', '0.000001'],
    // ['1 ly to m', '9.460730473×10¹⁵'],
    // ['√2', '1.414213562'],
    // ['√3', '1.732050808'],
    // ['√4', '2'],
    // ['√2^10', '32'],
    // ['√2²⁰', '1024'],
    // ['sin(pi)÷√(1-∛2)', '-0.107495152i'],
    // ['⌊cosh(pi)÷(√pi-∛pi)^e⌋ mod ⌈(e^pi+pi^e)×{2³÷∜e²}⌉', '12'],
    // ['[1.1]', '1'],
    // ['[1.9]', '2'],
    // ['[-2.1]', '-2'],
    // ['[-2.9]', '-3'],
    // ['[1.1]+[1.9]', '3'],
    // ['[1.1]-[1.9]', '-1'],
    // ['[1.1]*[1.9]', '2'],
    // ['[1.1]/[1.9]', '0.5'],
    // ['[1.1]^2', '1'],
    // ['[1.1]^3', '1'],
    // ['⌊1.1⌋+⌊1.9⌋', '2'],
    // ['⌈1.1⌉+⌈1.9⌉', '4'],
    // ['⌊-1.1⌋+⌊-1.9⌋', '-4'],
    // ['⌈-1.1⌉+⌈-1.9⌉', '-2'],
    // ['2²^2', '1'],
    // ['(2²)²', '16'],
    // ['i*i', '-1'],
    // ['√(-1)', 'i'],
    ['√-1', 'i'],
    // ['√ +2', '1.414213562'],
    // ['√ -1', 'i'],
    // ['√i', '0.707106781+0.707106781i'],
    // ['sin(i)', '1.175201194i'],
    // ['log(-1)', '1.364376354i'],
    // ['i^i', '0.207879576'],
    // ['e^i', '0.540302306+0.841470985i'],
    // ['e^(pi*i)', '-1'],
    // ['i^(e*pi)', '0.661624966+0.749834918i'],
    // ['pi^(i*e)', '-0.999553201+0.029889754i'],
    // ['log(i)', '0.682188177i'],
    // ['(1+√5)/2', '1.618033989'],
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

void loopReadSolve() {
  resultSerializer = Serializer(DisplayFormat.automatic, 10, 9);

  while (true) {
    stdout.write('< ');
    var line = stdin.readLineSync();
    if (line == null) {
      break;
    }
    if (line.isEmpty) {
      break;
    }
    var output = solve(line);
    stdout.writeln(output);
  }
}

void main() {
  testCases1();
  // loopReadSolve();
}
