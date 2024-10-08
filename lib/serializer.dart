import 'package:calculator/enums.dart';
import 'package:calculator/types.dart';
import 'package:calculator/number.dart';

class Serializer {
  late int leadingDigits; // Number of digits to show before radix
  int trailingDigits; // Number of digits to show after radix
  DisplayFormat format; // Number display mode
  late bool showTsep; // Set if the thousands separator should be shown
  late bool showZeroes; // Set if trailing zeroes should be shown

  int numberBase; // Numeric base
  late int representationBase; // Representation base

  late String radix; // Locale specific radix string
  late String tsep; // Locale specific thousands separator
  late int tsepCount; // Number of digits between separator

  // is set when an error (for example precision error while converting) occurs
  String? error;

  Serializer(this.format, this.numberBase, this.trailingDigits) {
    // Initialize locale specific radix and thousands separator
    radix = '.'; // Default radix
    tsep = ' '; // Default thousands separator
    tsepCount = 3;

    representationBase = numberBase;
    leadingDigits = 12;
    showZeroes = false;
    showTsep = false;
  }

  String serialize(Number x) {
    // For base conversion equation, use FIXED format
    if (representationBase != numberBase) {
      RefInt nDigits = RefInt(0);
      return _castToString(x, nDigits);
    }

    switch (format) {
      case DisplayFormat.fixed:
        RefInt nDigits = RefInt(0);
        return _castToString(x, nDigits);
      case DisplayFormat.scientific:
        if (representationBase == 10) {
          RefInt nDigits = RefInt(0);
          return _castToExponentialString(x, false, nDigits);
        } else {
          RefInt nDigits = RefInt(0);
          return _castToString(x, nDigits);
        }
      case DisplayFormat.engineering:
        if (representationBase == 10) {
          RefInt nDigits = RefInt(0);
          return _castToExponentialString(x, true, nDigits);
        } else {
          RefInt nDigits = RefInt(0);
          return _castToString(x, nDigits);
        }
      case DisplayFormat.automatic:
      default:
        RefInt nDigits = RefInt(0);
        var s0 = _castToString(x, nDigits);

        // Decide leading digits based on number_base. Support 64 bits in programming mode.
        switch (getBase()) {
          // 64 digits for binary mode.
          case 2:
            if (nDigits.value  <= 64) {
              return s0;
            } else {
              return _castToExponentialString(x, false, nDigits);
            }
          // 22 digits for decimal mode.
          case 8:
            if (nDigits.value <= 22) {
              return s0;
            } else {
              return _castToExponentialString(x, false, nDigits);
            }
          // 16 digits for hexadecimal mode.
          case 16:
            if (nDigits.value <= 16) {
              return s0;
            } else {
              return _castToExponentialString(x, false, nDigits);
            }
          // Use default leading_digits for base 10 numbers.
          case 10:
          default:
            if (nDigits.value <= leadingDigits) {
              return s0;
            } else {
              return _castToExponentialString(x, false, nDigits);
            }
        }
    }
  }

  Number? fromString(String str) {
    // FIXME: Move mpSetFromString into here
    return mpSetFromString(str, numberBase);
  }

  void setBase(int numberBase) {
    this.numberBase = numberBase;
  }

  int getBase() {
    return numberBase;
  }

  void setRepresentationBase(int representationBase) {
    this.representationBase = representationBase;
  }

  int getRepresentationBase() {
    return representationBase;
  }

  void setRadix(String radix) {
    this.radix = radix;
  }

  String getRadix() {
    return radix;
  }

  void setThousandsSeparator(String separator) {
    tsep = separator;
  }

  String getThousandsSeparator() {
    return tsep;
  }

  int getThousandsSeparatorCount() {
    return tsepCount;
  }

  void setThousandsSeparatorCount(int count) {
    tsepCount = count;
  }

  void setShowThousandsSeparators(bool visible) {
    showTsep = visible;
  }

  bool getShowThousandsSeparators() {
    return showTsep;
  }

  void setShowTrailingZeroes(bool visible) {
    showZeroes = visible;
  }

  bool getShowTrailingZeroes() {
    return showZeroes;
  }

  int getLeadingDigits() {
    return leadingDigits;
  }

  void setLeadingDigits(int leadingDigits) {
    this.leadingDigits = leadingDigits;
  }

  int getTrailingDigits() {
    return trailingDigits;
  }

  void setTrailingDigits(int trailingDigits) {
    this.trailingDigits = trailingDigits;
  }

  DisplayFormat getNumberFormat() {
    return format;
  }

  void setNumberFormat(DisplayFormat format) {
    this.format = format;
  }

  String _castToString(Number x, RefInt nDigits) {
    var string = StringBuffer();

    var xReal = x.realComponent();
    _castToStringReal(xReal, representationBase, false, nDigits, string);
    if (x.isComplex()) {
      var xImag = x.imaginaryComponent();
      var forceSign = true;

      if (string.toString() == '0') {
        string.clear();
        forceSign = false;
      }

      var s = StringBuffer();
      RefInt nComplexDigits = RefInt(0);

      _castToStringReal(xImag, representationBase, forceSign, nComplexDigits, s);

      if (nComplexDigits.value > nDigits.value) {
        nDigits.value = nComplexDigits.value;
      }

      if (s.toString() == '0' || s.toString() == '+0' || s.toString() == '-0') {
        if (string.toString() == '') {
          string.assign('0'); // real component is empty, the imaginary very small, we shouldn't return blank
        }
      }
      else if (s.toString() == '1') {
        string.append('i');
      }
      else if (s.toString() == '+1') {
        string.append('+i');
      }
      else if (s.toString() == '-1') {
        string.append('-i');
      }
      else {
        if (s.toString() == '+0') {
          string.append('+');
        }
        else if (s.toString() != '0') {
          string.append(s.toString());
        }

        string.append('i');
      }
    }

    return string.toString();
  }

  void _castToStringReal(Number x, int numberBase, bool forceSign, RefInt nDigits, StringBuffer string) {
    // var digits = "0123456789ABCDEF".split('');
    const List<String> digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8',
                                 '9', 'A', 'B', 'C', 'D', 'E', 'F'];

    var number = x;
    if (number.isNegative()) {
      number = number.abs();
    }

    // Add rounding factor
    var temp = Number.fromInt(numberBase);
    temp = temp.xpowyInteger(-(trailingDigits + 1));
    temp = temp.multiplyInteger(numberBase);
    temp = temp.divideInteger(2);
    var roundedNumber = number.add(temp);

    // Write out the integer component least significant digit to most
    temp = roundedNumber.floor();
    int i = 0;

    do {
      if (numberBase == 10 && showTsep && i == tsepCount) {
        string.prepend(tsep);
        i = 0;
      }
      i++;

      var t = temp.divideInteger(numberBase);
      t = t.floor();
      var t2 = t.multiplyInteger(numberBase);
      var t3 = temp.subtract(t2);
      var d = t3.toInteger();

      if (d < 16 && d >= 0) {
        string.prepend(digits[d]);
      } else {
        // Handle error
        string.prepend('?');
        error = "Overflow: the result couldn’t be calculated";
        string.assign('0');
        break;
      }

      nDigits.value++;
      temp = t;
    } while (!temp.isZero());

    var lastNonZero = string.length;

    string.append(radix);

    // Write out the fractional component
    temp = roundedNumber.fractionalComponent();
    for (i = 0; i < trailingDigits; i++) {
      if (temp.isZero()) {
        break;
      }

      temp = temp.multiplyInteger(numberBase);
      var digit = temp.floor();
      var d = digit.toInteger();

      string.append(digits[d]);

      if (d != 0) {
        lastNonZero = string.length;
      }

      temp = temp.subtract(digit);
    }

    // Strip trailing zeroes
    if (!showZeroes || trailingDigits == 0) {
      // Truncar a string para os primeiros 'lastNonZero' caracteres
      string.truncate(lastNonZero);
    }

    // Add sign on non-zero values
    if (string.toString() != '0' || forceSign) {
      if (x.isNegative()) {
        string.prepend('-');
      } else if (forceSign) {
        string.prepend('+');
      }
    }

    // Append base suffix if not in default base
    if (numberBase != this.numberBase) {
      const List<String> subDigits = ['₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];
      int multiplier = 1;
      int b = numberBase;

      while (numberBase ~/ multiplier != 0) {
        multiplier *= 10;
      }

      while (multiplier != 1) {
        multiplier ~/= 10;
        int d = b ~/ multiplier;
        b -= d * multiplier;
        string.append(subDigits[d]);
      }
    }
  }

  int _castToExponentialStringReal(Number x, StringBuffer string, bool engFormat, RefInt nDigits) {
    if (x.isNegative()) {
      string.append('-');
    }

    var mantissa = x.abs();
    var base_ = Number.fromInt(numberBase);
    var base3 = base_.xpowyInteger(3);
    var base10 = base_.xpowyInteger(10);
    var t = Number.fromInt(1);
    var base10inv = t.divide(base10);

    var exponent = 0;
    if (!mantissa.isZero()) {
      while (!engFormat && mantissa.compare(base10) >= 0) {
        exponent += 10;
        mantissa = mantissa.multiply(base10inv);
      }

      while ((!engFormat && mantissa.compare(base_) >= 0) ||
              (engFormat && (mantissa.compare(base3) >= 0 || exponent % 3 != 0))) {
        exponent += 1;
        mantissa = mantissa.divide(base_);
      }

      while (!engFormat && mantissa.compare(base10inv) < 0) {
        exponent -= 10;
        mantissa = mantissa.multiply(base10);
      }

      t = Number.fromInt(1);
      while (mantissa.compare(t) < 0 || (engFormat && exponent % 3 != 0)) {
        exponent -= 1;
        mantissa = mantissa.multiply(base_);
      }
    }

    string.append(_castToString(mantissa, nDigits));
    return exponent;
  }

  String _castToExponentialString(Number x, bool engFormat, RefInt nDigits) {
    var string = StringBuffer();
    var xReal = x.realComponent();
    var exponent = _castToExponentialStringReal(xReal, string, engFormat, nDigits);
    _appendExponent(string, exponent);

    if (x.isComplex()) {
      var xImag = x.imaginaryComponent();

      if (string.toString() == '0') {
        string.clear();
      }

      var s = StringBuffer();
      RefInt nComplexDigits = RefInt(0);
      exponent = _castToExponentialStringReal(xImag, s, engFormat, nComplexDigits);

      if (nComplexDigits.value > nDigits.value) {
        nDigits.value = nComplexDigits.value;
      }

      if (s.toString() == '0' || s.toString() == '+0' || s.toString() == '-0') {
        // Do nothing
      }
      else if (s.toString() == '1') {
        string.append('i');
      }
      else if (s.toString() == '+1') {
        string.append('+i');
      }
      else if (s.toString() == '-1') {
        string.append('-i');
      }
      else {
        if (s.toString() == '+0') {
          string.append('+');
        }
        else if (s.toString() != '0') {
          string.append(s.toString());
        }

        string.append('i');
      }

      _appendExponent(string, exponent);
    }

    return string.toString();
  }

  void _appendExponent(StringBuffer string, int exponent) {
    const List<String> superDigits = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];

    if (exponent == 0) {
      return;
    }

    string.append('×10'); // FIXME: Use the current base
    if (exponent < 0) {
      exponent = -exponent;
      string.append('⁻');
    }

    var superValue = '$exponent';
    for (var i = 0; i < superValue.length; i++) {
      string.append(superDigits[superValue[i].codeUnitAt(0) - '0'.codeUnitAt(0)]);
    }
  }
}

// Tests for the Serializer class

void testSerializer() {
  var s = Serializer(DisplayFormat.automatic, 10, 10);
  var x = Number.fromDouble(3.6, 1.8);
  print('x: ${s.serialize(x)}');

  s.setBase(2);
  print('x: ${s.serialize(x)}');

  s.setBase(8);
  print('x: ${s.serialize(x)}');

  s.setBase(16);
  print('x: ${s.serialize(x)}');

  s.setBase(10);
  print('x: ${s.serialize(x)}');

  s.setRepresentationBase(2);
  print('x: ${s.serialize(x)}');

  s.setRepresentationBase(8);
  print('x: ${s.serialize(x)}');

  s.setRepresentationBase(16);
  print('x: ${s.serialize(x)}');

  s.setRepresentationBase(10);
  print('x: ${s.serialize(x)}');

  s.setRadix(',');
  print('x: ${s.serialize(x)}');

  s.setRadix('.');
  print('x: ${s.serialize(x)}');

  s.setThousandsSeparator(' ');
  print('x: ${s.serialize(x)}');

  s.setThousandsSeparatorCount(4);
  print('x: ${s.serialize(x)}');

  s.setShowThousandsSeparators(true);
  print('x: ${s.serialize(x)}');

  s.setShowThousandsSeparators(false);
  print('x: ${s.serialize(x)}');

  s.setShowTrailingZeroes(true);
  print('x: ${s.serialize(x)}');

  s.setShowTrailingZeroes(false);
  print('x: ${s.serialize(x)}');

  s.setLeadingDigits(16);
  print('x: ${s.serialize(x)}');

  s.setTrailingDigits(16);
  print('x: ${s.serialize(x)}');

  s.setNumberFormat(DisplayFormat.fixed);
  print('x: ${s.serialize(x)}');

  s.setNumberFormat(DisplayFormat.scientific);
  print('x: ${s.serialize(x)}');

  s.setNumberFormat(DisplayFormat.engineering);
  print('x: ${s.serialize(x)}');

  s.setNumberFormat(DisplayFormat.automatic);
  print('x: ${s.serialize(x)}');

  var y = s.fromString('3.6');
  print('y: ${s.serialize(y!)}');
}

void main() {
  testSerializer();
}
