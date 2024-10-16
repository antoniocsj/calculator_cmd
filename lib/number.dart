import 'dart:math' as math;
import 'package:calculator/enums.dart';
import 'package:calculator/mpfr.dart';
import 'package:calculator/mpfr_bindings.dart';
import 'package:calculator/mpc.dart';
import 'package:calculator/types.dart';
import 'package:calculator/serializer.dart';

typedef BitwiseFunc = int Function(int v1, int v2);

class Number {
  static int precision = 1000;
  static String? error;

  late Complex num;

  // Getter para a precisão
  int get getPrecision => precision;

  // Setter para a precisão
  set setPrecision(int value) {
    precision = value;
  }

  // Obter a precisão em dígitos decimais
  static int get precisionInDigits => _calulatePrecisionInDigits;

  // calcular a precisão em dígitos decimais a partir da precisão em bits.
  // fórmula usada: n_digits = floor(n_bits * log10(2))
  static int get _calulatePrecisionInDigits {
    return (precision * math.log(2) / math.log(10)).floor();
  }

  // calcular a precisão em bits a partir da precisão em dígitos decimais.
  // fórmula usada: n_bits = ceil(n_digits * log2(10))
  // int get _calulatePrecisionInBits {
  //   return (precisionInDigits * math.log(10) / math.log(2)).ceil();
  // }

  // calcular o número de dígitos a partir do número de bits e da base
  static int _calculateDigits(int bits, int base) {
    if (base <= 1) {
      throw ArgumentError('Base must be greater than 1');
    }
    return (bits * math.log(2) / math.log(base)).floor();
  }

  // calcular o número de bits a partir do número de dígitos e da base
  // static int _calculateBits(int digits, int base) {
  //   if (base <= 1) {
  //     throw ArgumentError('Base must be greater than 1');
  //   }
  //   return (digits * log(base) / log(2)).ceil();
  // }

  // Construtor padrão
  Number() {
    num = Complex(precision);
  }

  Number.fromInt(int real, [int imag = 0]) {
    num = Complex.fromInt(real, imag, precision);
  }

  Number.fromUInt(int real, [int imag = 0]) {
    num = Complex.fromUInt(real, imag, precision);
  }

  Number.fromFraction(int numerator, int denominator) {
    if (denominator < 0) {
      numerator = -numerator;
      denominator = -denominator;
    }
    num = Complex.fromInt(numerator, 0, precision);
    num.divideUInt(num, denominator);
  }

  Number.fromReal(Real real, [Real? imag]) {
    num = Complex.fromReal(real, imag, precision);
  }

  Number.fromDouble(double real, [double imag = 0]) {
    num = Complex.fromDouble(real, imag, precision);
  }

  Number.fromComplex(Number r, Number i) {
    num = Complex.fromComplex(r.num, i.num, precision);
  }

  Number.polar(Number r, Number theta, [AngleUnit unit = AngleUnit.radians]) {
    var x = theta.cos(unit).multiply(r);
    var y = theta.sin(unit).multiply(r);
    num = Complex.fromComplex(x.num, y.num, precision);
  }

  // Construtor do número de Euler: 2.718281828
  Number.e() {
    num = Complex.e(precision);
  }

  // Construtor da constante de Euler-Mascheroni: 0.577215665
  Number.em() {
    num = Complex.em(precision);
  }

  Number.i() {
    num = Complex.fromInt(0, 1, precision);
  }

  Number.pi() {
    num = Complex.pi(precision);
  }

  Number.tau() {
    num = Complex.tau(precision);
  }

  Number.random() {
    var rnd = math.Random().nextDouble();
    num = Complex.fromDouble(rnd, rnd, precision);
    // pesquisar como fazer isso usando a biblioteca mpfr e mpc.
  }

  void dispose() {
    num.dispose();
  }

  int toInteger() {
    var rePtr = num.getRealPointer();
    return mpfr.mpfr_get_si(rePtr, mpfr_rnd_t.MPFR_RNDN);
  }

  int toUnsignedInteger() {
    var rePtr = num.getRealPointer();
    return mpfr.mpfr_get_ui(rePtr, mpfr_rnd_t.MPFR_RNDN);
  }

  double toFloat() {
    var rePtr = num.getRealPointer();
    return mpfr.mpfr_get_flt(rePtr, mpfr_rnd_t.MPFR_RNDN);
  }

  double toDouble() {
    var rePtr = num.getRealPointer();
    return mpfr.mpfr_get_d(rePtr, mpfr_rnd_t.MPFR_RNDN);
  }

  bool isZero() {
    return num.isZero();
  }

  bool isNegative() {
    var rePtr = num.getRealPointer();
    return mpfr.mpfr_sgn(rePtr) < 0;
  }

  bool isInteger() {
    if (isComplex()) {
      return false;
    } else {
      var rePtr = num.getRealPointer();
      return mpfr.mpfr_integer_p(rePtr) != 0;
    }
  }

  bool isPositiveInteger() {
    return isInteger() && !isNegative();
  }

  bool isNatural() {
    return isPositiveInteger();
  }

  // return true if the number has an imaginary part
  bool isComplex() {
    var imPtr = num.getImaginaryPointer();
    return mpfr.mpfr_zero_p(imPtr) == 0;
  }

  // Return error if overflow or underflow
  static void checkFlags() {
    if (mpfr.mpfr_overflow_p() != 0) {
      error = 'Overflow';
    } else if (mpfr.mpfr_underflow_p() != 0) {
      error = 'Underflow';
    }
  }

  bool equals(Number y) {
    return num.isEqual(y.num);
  }

  int compare(Number y) {
    var rePtrThis = num.getRealPointer();
    var rePtrY = y.num.getRealPointer();
    return mpfr.mpfr_cmp(rePtrThis, rePtrY);
  }

  Number sgn() {
    var rePtr = num.getRealPointer();
    var z = Number.fromInt(mpfr.mpfr_sgn(rePtr));
    return z;
  }

  Number invertSign() {
    var z = Number();
    z.num.negate(num);
    return z;
  }

  Number abs() {
    var z = Number();
    var imPtrZ = z.num.getImaginaryPointer();
    mpfr.mpfr_set_zero(imPtrZ, 1);

    var rePtrZ = z.num.getRealPointer();
    mpfr.mpfr_abs(rePtrZ, num.getRealPointer(), mpfr_rnd_t.MPFR_RNDN);
    return z;
  }

  Number arg([AngleUnit unit = AngleUnit.radians]) {
    if (isZero()) {
      error = 'Argument of zero is undefined';
      return Number.fromInt(0);
    }

    var z = Number();
    var rePtrZ = z.num.getRealPointer();
    var imPtrZ = z.num.getImaginaryPointer();

    mpfr.mpfr_set_zero(imPtrZ, 1);
    mpc.mpc_arg(rePtrZ, num.getPointer(), mpfr_rnd_t.MPFR_RNDN);

    mpcFromRadians(z.num, z.num, unit);
    // MPC returns -π for the argument of negative real numbers if
    // their imaginary part is -0 (which it is in the numbers
    // created by test-equation), we want +π for all real negative
    // numbers

    if (!isComplex() && isNegative()) {
      mpfr.mpfr_abs(rePtrZ, rePtrZ, mpfr_rnd_t.MPFR_RNDN);
    }

    return z;
  }

  Number conjugate() {
    var z = Number();
    z.num.conj(num);
    return z;
  }

  Number realComponent() {
    var z = Number();
    z.num.setMPReal(num.getRealPointer());
    return z;
  }

  Number imaginaryComponent() {
    // Copy imaginary component to real component
    var z = Number();
    z.num.setMPReal(num.getImaginaryPointer());
    return z;
  }

  Number integerComponent() {
    var z = Number();
    var rePtrZ = z.num.getRealPointer();
    var imPtrZ = z.num.getImaginaryPointer();

    // set the imaginary part of z to zero
    mpfr.mpfr_set_zero(imPtrZ, 1);

    // truncate the real part of z to an integer
    mpfr.mpfr_trunc(rePtrZ, num.getRealPointer());

    return z;
  }

  // Returns z = x mod 1
  Number fractionalComponent() {
    var z = Number();
    var rePtrZ = z.num.getRealPointer();
    var imPtrZ = z.num.getImaginaryPointer();

    // set the imaginary part of z to zero
    mpfr.mpfr_set_zero(imPtrZ, 1);

    // set the real part of z to the fractional part of the real part of this
    mpfr.mpfr_frac(rePtrZ, num.getRealPointer(), mpfr_rnd_t.MPFR_RNDN);

    return z;
  }

  /* Returns z = {x} */
  Number fractionalPart() {
    return subtract(floor());
  }

  // Returns z = ⌊x⌋
  Number floor() {
    var z = Number();
    var rePtrZ = z.num.getRealPointer();
    var imPtrZ = z.num.getImaginaryPointer();

    // set the imaginary part of z to zero
    mpfr.mpfr_set_zero(imPtrZ, 1);

    // set the real part of z to the floor of the real part of this
    mpfr.mpfr_floor(rePtrZ, num.getRealPointer());

    return z;
  }

  // Returns z = ⌈x⌉
  Number ceiling() {
    var z = Number();
    var rePtrZ = z.num.getRealPointer();
    var imPtrZ = z.num.getImaginaryPointer();

    // set the imaginary part of z to zero
    mpfr.mpfr_set_zero(imPtrZ, 1);

    // set the real part of z to the ceiling of the real part of this
    mpfr.mpfr_ceil(rePtrZ, num.getRealPointer());

    return z;
  }

  // Returns z = [x]
  Number round() {
    var z = Number();
    var rePtrZ = z.num.getRealPointer();
    var imPtrZ = z.num.getImaginaryPointer();

    // set the imaginary part of z to zero
    mpfr.mpfr_set_zero(imPtrZ, 1);

    // set the real part of z to the round of the real part of this
    mpfr.mpfr_round(rePtrZ, num.getRealPointer());

    return z;
  }

  // Returns z = 1 / x
  Number reciprocal() {
    var z = Number();
    var rePtrZ = z.num.getRealPointer();

    // set z to (1, 0)
    z.num.setInt(1);

    // divide z by this
    z.num.mpRealDivide(rePtrZ, num.getPointer());

    return z;
  }

  // Returns z = e^x
  Number epowy() {
    var z = Number();
    z.num.exp(num);
    return z;
  }

  // Returns z = x^y
  Number xpowy(Number y) {
    // 0^-n invalid */
    if (isZero() && y.isNegative()) {
      error = '0^(-n) is undefined';
      return Number.fromInt(0);
    }

    // 0^0 is indeterminate
    if (isZero() && y.isZero()) {
      error = '0^0 is indeterminate';
      return Number.fromInt(0);
    }

    if (!isComplex() && !y.isComplex() && !y.isInteger()) {
      var reciprocal = y.reciprocal();
      if (reciprocal.isInteger()) {
        return root(reciprocal.toInteger());
      }
    }

    var z = Number();
    z.num.power(num, y.num);
    return z;
  }

  // Returns z = x^y
  Number xpowyInteger(int n) {
    // 0^-n is invalid
    if (isZero() && n < 0) {
      error = '0^(-n) is undefined';
      return Number.fromInt(0);
    }

    // 0^0 is indeterminate
    if (isZero() && n == 0) {
      error = '0^0 is indeterminate';
      return Number.fromInt(0);
    }

    var z = Number();
    z.num.powerInt(num, n);
    return z;
  }

  // Returns z = n√x
  Number root(int n) {
    int p;

    var z = Number();
    if (n == 0) {
      error = '0√x is undefined';
      return Number.fromInt(0);
    } else if (n < 0) {
      // n√x = 1 / n√(1/x)
      z.num.uIntDivide(1, num);
      p = -n;
    } else {
      z.num.setComplex(num);
      p = n;
    }

    if (!isComplex() && (!isNegative() || (p & 1) == 1)) {
      // If x is real and non-negative or n is odd, we can take the real version of the nth root
      var rePtrZ = z.num.getRealPointer();
      var imPtrZ = z.num.getImaginaryPointer();

      mpfr.mpfr_root(rePtrZ, rePtrZ, p, mpfr_rnd_t.MPFR_RNDN);
      mpfr.mpfr_set_zero(imPtrZ, 1);
    } else {
      // If x is complex or negative and n is even, we can't take the real version of the nth root
      // but we can take the complex version of the nth root using the function mpc_root
      var tmp = Real(precision);

      tmp.setUInt(p);
      tmp.uintDiv(1, tmp);

      z.num.powerReal(z.num, tmp);
    }

    return z;
  }

  // Returns z = √x
  Number sqrt() {
    return root(2);
  }

  // Returns z = ln x
  Number ln() {
    // ln(0) is undefined
    if (isZero()) {
      error = 'ln(0) is undefined';
      return Number.fromInt(0);
    }

    var z = Number();
    z.num.log(num);

    // MPC returns -π for the imaginary part of the log of
    // negative real numbers if their imaginary part is -0 (which
    // it is in the numbers created by test-equation), we want +π
    // for all real negative numbers
    if (!isComplex() && isNegative()) {
      var imPtrZ = z.num.getImaginaryPointer();
      mpfr.mpfr_abs(imPtrZ, imPtrZ, mpfr_rnd_t.MPFR_RNDN);
    }

    return z;
  }

  /* Returns z = log_n x */
  Number logarithm(int n) {
    // log_n(0) is undefined
    if (isZero()) {
      error = 'log_n(0) is undefined';
      return Number.fromInt(0);
    }

    // log_n(x) = ln(x) / ln(n)
    var z = Number.fromInt(n);
    return ln().divide(z.ln());
  }

  /* Returns z = x! */
  Number factorial() {
    // 0! = 1
    if (isZero()) {
      return Number.fromInt(1);
    }

    if (!isNatural()) {
      // Factorial Not defined for Complex or for negative numbers
      if (isNegative() || isComplex()) {
        error = 'Factorial not defined for negative numbers or complex numbers';
        return Number.fromInt(0);
      }

      // Factorial(x) = Γ(x + 1)
      var tmp = add(Number.fromInt(1));
      var tmp2 = Real(precision);
      tmp2.gammaPtr(tmp.num.getRealPointer());

      return Number.fromReal(tmp2);
    }

    // Convert to integer - if couldn't be converted then the factorial would be too big anyway
    var value = toInteger();
    var z = Number.fromInt(value);

    // Factorial(x) = x! = x * (x - 1) * (x - 2) * ... * 1
    for (var i = 2; i < value; i++) {
      z = z.multiplyInteger(i);
    }

    return z;
  }

  // Returns z = x + y
  Number add(Number y) {
    var z = Number();
    z.num.add(num, y.num);
    return z;
  }

  // Returns z = x - y
  Number subtract(Number y) {
    var z = Number();
    z.num.subtract(num, y.num);
    return z;
  }

  // Returns z = x × y
  Number multiply(Number y) {
    var z = Number();
    z.num.multiply(num, y.num);
    return z;
  }

  // Returns z = x × y
  Number multiplyInteger(int y) {
    var z = Number();
    z.num.multiplyInt(num, y);
    return z;
  }

  // Returns z = x ÷ y
  Number divide(Number y) {
    if (y.isZero()) {
      error = 'Division by zero';
      return Number.fromInt(0);
    }

    var z = Number();
    z.num.divide(num, y.num);
    return z;
  }

  // Returns z = x ÷ y
  Number divideInteger(int y) {
    return divide(Number.fromInt(y));
  }

  // Sets z = x mod y
  Number modulusDivide(Number y) {
    if (!isInteger() || !y.isInteger()) {
      error = 'Modulus division is only defined for integers';
      return Number.fromInt(0);
    }

    var t1 = divide(y).floor();
    var t2 = t1.multiply(y);
    var z = subtract(t2);

    t1 = Number.fromInt(0);
    if ((y.compare(t1) < 0 && z.compare(t1) > 0) ||
        (y.compare(t1) > 0 && z.compare(t1) < 0)) {
      z = z.add(y);
    }

    return z;
  }

  // Returns z = x ^ y mod p
  Number modularExponentiation(Number exp, Number mod) {
    var baseValue = copy();

    if (exp.isNegative()) {
      baseValue = baseValue.reciprocal();
    }

    var expValue = exp.abs();
    var ans = Number.fromInt(1);
    var two = Number.fromInt(2);

    while (!expValue.isZero()) {
      bool isEven = expValue.modulusDivide(two).isZero();

      if (!isEven) {
        ans = ans.multiply(baseValue).modulusDivide(mod);
      }

      baseValue = baseValue.multiply(baseValue).modulusDivide(mod);
      expValue = expValue.divideInteger(2).floor();
    }

    return ans.modulusDivide(mod);
  }

  // Returns z = sin x
  Number sin([AngleUnit unit = AngleUnit.radians]) {
    var z = Number();

    if (isComplex()) {
      z.num.setComplex(num);
    }
    else {
      mpcToRadians(z.num, num, unit);
    }

    z.num.sin(z.num);
    return z;
  }

  // Returns z = cos x
  Number cos([AngleUnit unit = AngleUnit.radians]) {
    var z = Number();

    if (isComplex()) {
      z.num.setComplex(num);
    }
    else {
      mpcToRadians(z.num, num, unit);
    }

    z.num.cos(z.num);
    return z;
  }

  // Returns z = tan x
  Number tan([AngleUnit unit = AngleUnit.radians]) {
    // Check for undefined values
    var xRadians = toRadians(unit);
    var check =
        xRadians.subtract(Number.pi().divideInteger(2)).divide(Number.pi());

    if (check.isInteger()) {
      error = 'tan(π/2 + nπ) is undefined';
      return Number.fromInt(0);
    }

    var z = Number();

    if (isComplex()) {
      z.num.setComplex(num);
    }
    else {
      mpcToRadians(z.num, num, unit);
    }

    z.num.tan(z.num);
    return z;
  }

  /* Returns z = sin⁻¹ x */
  Number asin([AngleUnit unit = AngleUnit.radians]) {
    if (compare(Number.fromInt(1)) > 0 || compare(Number.fromInt(-1)) < 0) {
      error = 'asin(x) is only defined for -1 ≤ x ≤ 1';
      return Number.fromInt(0);
    }

    var z = Number();
    z.num.asin(num);

    if (!z.isComplex()) {
      mpcFromRadians(z.num, z.num, unit);
    }

    return z;
  }

  /* Returns z = cos⁻¹ x */
  Number acos([AngleUnit unit = AngleUnit.radians]) {
    if (compare(Number.fromInt(1)) > 0 || compare(Number.fromInt(-1)) < 0) {
      error = 'acos(x) is only defined for -1 ≤ x ≤ 1';
      return Number.fromInt(0);
    }

    var z = Number();
    z.num.acos(num);

    if (!z.isComplex()) {
      mpcFromRadians(z.num, z.num, unit);
    }

    return z;
  }

  /* Returns z = tan⁻¹ x */
  Number atan([AngleUnit unit = AngleUnit.radians]) {
    // Check x != i and x != -i
    if (equals(Number.i()) || equals(Number.i().invertSign())) {
      error = 'atan(±i) is undefined';
      return Number.fromInt(0);
    }

    var z = Number();
    z.num.atan(num);

    if (!z.isComplex()) {
      mpcFromRadians(z.num, z.num, unit);
    }

    return z;
  }

  // Returns z = sinh x
  Number sinh() {
    var z = Number();
    z.num.sinh(num);
    return z;
  }

  // Returns z = cosh x
  Number cosh() {
    var z = Number();
    z.num.cosh(num);
    return z;
  }

  // Returns z = tanh x
  Number tanh() {
    var z = Number();
    z.num.tanh(num);
    return z;
  }

  // Returns z = sinh⁻¹ x
  Number asinh() {
    var z = Number();
    z.num.asinh(num);
    return z;
  }

  // Returns z = cosh⁻¹ x
  Number acosh() {
    // Check x >= 1
    var t = Number.fromInt(1);

    if (compare(t) < 0) {
      error = 'acosh(x) is only defined for x ≥ 1';
      return Number.fromInt(0);
    }

    var z = Number();
    z.num.acosh(num);

    return z;
  }

  // Returns z = tanh⁻¹ x
  Number atanh() {
    // Check -1 <= x <= 1
    if (compare(Number.fromInt(1)) >= 0 || compare(Number.fromInt(-1)) <= 0) {
      error = 'atanh(x) is only defined for -1 ≤ x ≤ 1';
      return Number.fromInt(0);
    }

    var z = Number();
    z.num.atanh(num);

    return z;
  }

  // Returns z = boolean AND for each bit in x and z
  Number and(Number y) {
    if (!isPositiveInteger() || !y.isPositiveInteger()) {
      error = 'Bitwise operations are only defined for positive integers';
      return Number.fromInt(0);
    }

    return bitwise(y, (int v1, int v2) => v1 & v2, 0);
  }

  // Returns z = boolean OR for each bit in x and z
  Number or(Number y) {
    if (!isPositiveInteger() || !y.isPositiveInteger()) {
      error = 'Bitwise operations are only defined for positive integers';
      return Number.fromInt(0);
    }

    return bitwise(y, (int v1, int v2) => v1 | v2, 0);
  }

  // Returns z = boolean XOR for each bit in x and z
  Number xor(Number y) {
    if (!isPositiveInteger() || !y.isPositiveInteger()) {
      error = 'Bitwise operations are only defined for positive integers';
      return Number.fromInt(0);
    }

    return bitwise(y, (int v1, int v2) => v1 ^ v2, 0);
  }

  // Returns z = boolean NOT for each bit in x and z for word of length 'wordlen'
  Number not(int wordlen) {
    if (!isPositiveInteger()) {
      error = 'Bitwise operations are only defined for positive integers';
      return Number.fromInt(0);
    }

    return bitwise(Number.fromInt(0), (int v1, int v2) => v1 ^ 0xF, wordlen);
  }

  // Returns z = x masked to 'wordlen' bits
  Number mask(Number x, int wordlen) {
    // Convert to a hexadecimal string and use last characters
    var text = x.toHexString();
    var len = text.length;
    var offset = wordlen ~/ 4;

    offset = len > offset ? len - offset : 0;

    var z = mpSetFromString(text.substring2(offset), 16, false);

    if (z == null) {
      error = 'Invalid hexadecimal string';
      return Number.fromInt(0);
    } else {
      return z;
    }
  }

  // Returns z = x shifted by 'count' bits.  Positive shift increases the value, negative decreases
  Number shift(int count) {
    if (!isPositiveInteger()) {
      error = 'Bitwise operations are only defined for positive integers';
      return Number.fromInt(0);
    }

    // Initialize an integer 2^count
    var operand = Number.fromUInt(2).xpowyInteger(count.abs());

    // If positive shift return x*operand
    if (count >= 0) {
      return multiply(operand);
    }
    else {
      // If negative return floor ( x/operand )
      if (compare(operand) < 0) {
        error = 'Shift operation underflow';
        return Number.fromInt(0);
      }
      return divide(operand).floor();
    }
  }

  // Returns the ones complement of x for word of length 'wordlen'
  Number onesComplement(int wordlen) {
    if (!isPositiveInteger()) {
      error = 'Bitwise operations are only defined for positive integers';
      return Number.fromInt(0);
    }

    return bitwise(Number.fromInt(0), (int v1, int v2) => v1 ^ v2, wordlen)
        .not(wordlen);
  }

  // Returns the twos complement of x for word of length 'wordlen'
  Number twosComplement(int wordlen) {
    if (!isPositiveInteger()) {
      error = 'Bitwise operations are only defined for positive integers';
      return Number.fromInt(0);
    }

    return onesComplement(wordlen).add(Number.fromInt(1));
  }

  // In: An p := p \in 2Z+1; An b := gcd(b,p) = 1
  // Out:  A boolean showing that p is probably prime
  bool isSprp(Number p, int b) {
    var unit = Number.fromUInt(1);
    var pMinusOne = p.subtract(unit);
    var d = pMinusOne;
    var two = Number.fromUInt(2);

    // Factor out powers of 2 from p-1
    int twofactor = 0;

    while (true) {
      var tmp = d.divide(two);
      if (tmp.isInteger()) {
        d = tmp;
        twofactor++;
      } else {
        break;
      }
    }

    var x = Number.fromUInt(b).modularExponentiation(d, p);

    if (x.equals(unit) || x.equals(pMinusOne)) {
      return true;
    }

    for (var i = 0; i < twofactor; i++) {
      x = x.multiply(x).modulusDivide(p);

      if (x.equals(pMinusOne)) {
        return true;
      }
    }

    return false;
  }

  // In : An x := x \in 2Z+1 and gcd(x,[2,..,2ln(2)**2])=1
  // Out: A boolean correctly evaluating x as composite or prime assuming the GRH
  //
  // Even if the GRH is false, the probability of number-theoretic error is far lower than
  // machine error */
  bool isPrime(Number x) {
    // initializes bases as an array of the first 13 prime numbers
    var bases = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41];

    var sup = x.ln().toUnsignedInteger() + 1;

    // J.Sorenson & J.Webster's  optimization
    if (sup < 56) {
      for (var i = 0; i < bases.length; i++) {
        if (!isSprp(x, bases[i])) {
          return false;
        }
      }
      return true;
    } else {
      sup = 2 * sup * sup;

      for (var i = 0; i < sup; i++) {
        if (!isSprp(x, i)) {
          return false;
        }
      }

      return true;
    }
  }

  // Returns a list of all prime factors in x as Numbers
  List<Number> factorize() {
    var factors = <Number>[];
    var value = abs();

    if (value.isZero()) {
      factors.add(value);
      return factors;
    }

    if (value.equals(Number.fromInt(1))) {
      factors.add(this);
      return factors;
    }

    if (value.compare(Number.fromInt(0xFFFFFFFF)) > 0) {
      if (isPrime(value)) {
        factors.add(value);
        return factors;
      }
    }

    // if value < 2^64-1, call for factorize_uint64 function which deals in integers
    var intMax = Number.fromUInt(0xFFFFFFFFFFFFFFFF);

    if (value.compare(intMax) <= 0) {
      var factorsInt64 = factorizeUint64(value.toUnsignedInteger());

      if (isNegative()) {
        // invert the sign of the factors in factorsInt64
        for (var i = 0; i < factorsInt64.length; i++) {
          factorsInt64[i] = factorsInt64[i].invertSign();
        }
      }

      return factorsInt64;
    }

    var divisor = Number.fromInt(2);

    while (true) {
      var tmp = value.divide(divisor);

      if (tmp.isInteger()) {
        value = tmp;
        factors.add(divisor);
      } else {
        break;
      }
    }

    divisor = Number.fromInt(3);
    var root = value.sqrt();

    while (divisor.compare(root) <= 0) {
      var tmp = value.divide(divisor);

      if (tmp.isInteger()) {
        value = tmp;
        root = value.sqrt();
        factors.add(divisor);
      } else {
        divisor = divisor.add(Number.fromInt(2));
      }
    }

    if (value.compare(Number.fromInt(1)) > 0) {
      factors.add(value);
    }

    if (isNegative()) {
      // invert the sign of the factors in factors
      for (var i = 0; i < factors.length; i++) {
        factors[i] = factors[i].invertSign();
      }
    }

    return factors;
  }

  // Returns a list of all prime factors in x as Numbers
  List<Number> factorizeUint64(int n) {
    var factors = <Number>[];

    while (n % 2 == 0) {
      n ~/= 2;
      factors.add(Number.fromUInt(2));
    }

    for (int divisor = 3; divisor <= n / divisor; divisor += 2) {
      while (n % divisor == 0) {
        n ~/= divisor;
        factors.add(Number.fromUInt(divisor));
      }
    }

    if (n > 1) {
      factors.add(Number.fromUInt(n));
    }

    return factors;
  }

  Number copy() {
    var z = Number();
    z.num.setComplex(num);
    return z;
  }

  static void mpcFromRadians(Complex res, Complex op, AngleUnit unit) {
    int i;

    switch (unit) {
      case AngleUnit.radians:
        if (res != op) {
          res.setComplex(op);
        }
        return;

      case AngleUnit.degrees:
        i = 180;
        break;

      case AngleUnit.gradians:
        i = 200;
        break;

      default:
        return;
    }

    var scale = Real(precision);
    scale.setPi();
    scale.intDiv(i, scale);
    res.multiplyReal(op, scale);

    scale.dispose();
  }

  static void mpcToRadians(Complex res, Complex op, AngleUnit unit) {
    int i;

    switch (unit) {
      case AngleUnit.radians:
        if (res != op) {
          res.setComplex(op);
        }
        return;

      case AngleUnit.degrees:
        i = 180;
        break;

      case AngleUnit.gradians:
        i = 200;
        break;

      default:
        return;
    }

    var scale = Real(precision);
    scale.setPi();
    scale.divInt(scale, i);
    res.multiplyReal(op, scale);

    scale.dispose();
  }

  Number toRadians(AngleUnit unit) {
    var z = Number();
    mpcToRadians(z.num, num, unit);
    return z;
  }

  Number bitwise(Number y, BitwiseFunc bitwiseOperator, int wordlen) {
    var text1 = toHexString();
    var text2 = y.toHexString();
    var offset1 = text1.length - 1;
    var offset2 = text2.length - 1;
    var offsetOut = wordlen ~/ 4 - 1;

    if (offsetOut < 0) {
      offsetOut = offset1 > offset2 ? offset1 : offset2;
    }

    if (offsetOut > 0 && (offsetOut < offset1 || offsetOut < offset2)) {
      error = 'Bitwise operation overflow. Try a bigger word length';
      return Number.fromInt(0);
    }

    // initialize a variable textOut to store the result of the bitwise operation
    List<String> textOut = List.filled(offsetOut + 2, '');

    for (textOut[offsetOut + 1] = ''; offsetOut >= 0; offsetOut--) {
      int v1 = 0, v2 = 0;
      const hexDigits = '0123456789ABCDEF';

      if (offset1 >= 0) {
        v1 = hexToInt(text1[offset1]);
        offset1--;
      }

      if (offset2 >= 0) {
        v2 = hexToInt(text2[offset2]);
        offset2--;
      }

      textOut[offsetOut] = hexDigits[bitwiseOperator(v1, v2)];
    }

    var z = mpSetFromString(textOut.join(), 16, false);

    if (z == null) {
      error = 'Invalid hexadecimal string';
      return Number.fromInt(0);
    } else {
      return z;
    }
  }

  // converts a single hexadecimal digit into its corresponding integer value
  int hexToInt(String digit) {
    int d = digit.codeUnitAt(0);

    if (d >= 48 && d <= 57) {
      return d - 48;
    } else if (d >= 65 && d <= 70) {
      return d - 65 + 10;
    } else if (d >= 97 && d <= 102) {
      return d - 97 + 10;
    } else {
      return 0;
    }
  }

  String toHexString() {
    var serializer = Serializer(DisplayFormat.fixed, 16, 0);
    return serializer.serialize(this);
  }

  // Return a string representation of the number
  @override
  String toString() {
    var serializer = Serializer(DisplayFormat.fixed, 10, 64);
    return serializer.serialize(this);
  }
}

int parseLiteralPrefix(String str, RefInt prefixLen) {
  var newBase = 0;

  if (str.length < 3 || str[0] != '0') {
    return newBase;
  }

  var prefix = str[1].toLowerCase();

  if (prefix == 'b') {
    newBase = 2;
  } else if (prefix == 'o') {
    newBase = 8;
  } else if (prefix == 'x') {
    newBase = 16;
  } else {
    return newBase;
  }

  if (newBase != 0) {
    prefixLen.value = 2;
  }

  return newBase;
}

// Returns a string representation in 'text'
Number? mpSetFromString(String str, [int defaultBase = 10, bool mayHavePrefix = true]) {
  if (str.isEmpty) {
    return null;
  }

  if (str.contains('°')) {
    return setFromSexagesimal(str);
  }

  const List<String> baseDigits = ['₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];
  int basePrefix = 0;

  int index = 0;
  String c;

  var rIndex = RefInt(0);
  var rChar = RefString('');
  while (str.getNextChar(rIndex, rChar)) {}
  index = rIndex.value;
  c = rChar.value;

  int end = index;
  int numberBase = 0;
  int literalBase = 0;
  int baseMultiplier = 1;

  while (str.getPrevChar(rIndex, rChar)) {
    index = rIndex.value;
    c = rChar.value;

    var value = -1;
    for (var i = 0; i < baseDigits.length; i++) {
      if (c == baseDigits[i]) {
        value = i;
        break;
      }
    }
    if (value < 0) {
      break;
    }

    end = index;
    numberBase += value * baseMultiplier;
    baseMultiplier *= 10;
  }
  index = rIndex.value;
  c = rChar.value;

  if (mayHavePrefix) {
    RefInt refBasePrefix = RefInt(basePrefix);
    literalBase = parseLiteralPrefix(str, refBasePrefix);
    basePrefix = refBasePrefix.value;
  }

  if (numberBase != 0 && literalBase != 0 && literalBase != numberBase) {
    return null;
  }

  if (numberBase == 0) {
    numberBase = literalBase != 0 ? literalBase : defaultBase;
  }

/* Check if this has a sign */
  var negate = false;
  index = basePrefix;
  rIndex.value = index;

  str.getNextChar(rIndex, rChar);
  index = rIndex.value;
  c = rChar.value;

  if (c == '+') {
    negate = false;
  } else if (c == '-' || c == '−') {
    negate = true;
  } else {
    str.getPrevChar(rIndex, rChar);
    index = rIndex.value;
    c = rChar.value;
  }

/* Convert integer part */
  var z = Number.fromInt(0);

  while (str.getNextChar(rIndex, rChar)) {
    index = rIndex.value;
    c = rChar.value;

    var i = charVal(c, numberBase);
    if (i > numberBase) {
      return null;
    }
    if (i < 0) {
      str.getPrevChar(rIndex, rChar);
      index = rIndex.value;
      c = rChar.value;
      break;
    }

    z = z.multiplyInteger(numberBase).add(Number.fromInt(i));
  }
  index = rIndex.value;
  c = rChar.value;

/* Look for fraction characters, e.g. ⅚ */
  const List<String> fractions = [
    '½',
    '⅓',
    '⅔',
    '¼',
    '¾',
    '⅕',
    '⅖',
    '⅗',
    '⅘',
    '⅙',
    '⅚',
    '⅛',
    '⅜',
    '⅝',
    '⅞'
  ];
  const List<int> numerators = [1, 1, 2, 1, 3, 1, 2, 3, 4, 1, 5, 1, 3, 5, 7];
  const List<int> denominators = [2, 3, 3, 4, 4, 5, 5, 5, 5, 6, 6, 8, 8, 8, 8];
  var hasFraction = false;

  if (str.getNextChar(rIndex, rChar)) {
    index = rIndex.value;
    c = rChar.value;

    for (var i = 0; i < fractions.length; i++) {
      if (c == fractions[i]) {
        var fraction = Number.fromFraction(numerators[i], denominators[i]);
        z = z.add(fraction);

/* Must end with fraction */
        if (!str.getNextChar(rIndex, rChar)) {
          index = rIndex.value;
          c = rChar.value;
          return z;
        }
        else {
          return null;
        }
      }
    }

/* Check for decimal point */
    if (c == '.') {
      hasFraction = true;
    }
    else {
      str.getPrevChar(rIndex, rChar);
      index = rIndex.value;
      c = rChar.value;
    }
  }
  index = rIndex.value;
  c = rChar.value;

/* Convert fractional part */
  if (hasFraction) {
    var numerator = Number.fromInt(0);
    var denominator = Number.fromInt(1);

    while (str.getNextChar(rIndex, rChar)) {
      index = rIndex.value;
      c = rChar.value;

      var i = charVal(c, numberBase);
      if (i < 0) {
        str.getPrevChar(rIndex, rChar);
        index = rIndex.value;
        c = rChar.value;
        break;
      }

      denominator = denominator.multiplyInteger(numberBase);
      numerator = numerator.multiplyInteger(numberBase);
      numerator = numerator.add(Number.fromInt(i));
    }
    index = rIndex.value;
    c = rChar.value;

    numerator = numerator.divide(denominator);
    z = z.add(numerator);
  }

  if (index != end) {
    return null;
  }

  if (negate) {
    z = z.invertSign();
  }

  return z;
}

int charVal(String c, int numberBase) {
  if (!isHexDigit(c)) {
    return -1;
  }

  int value = hexDigitValue(c);

  if (value >= numberBase) {
    return -1;
  }

  return value;
}

bool isHexDigit(String c) {
  return RegExp(r'^[0-9a-fA-F]$').hasMatch(c);
}

int hexDigitValue(String c) {
  if (c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
      c.codeUnitAt(0) <= '9'.codeUnitAt(0)) {
    return c.codeUnitAt(0) - '0'.codeUnitAt(0);
  } else if (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
      c.codeUnitAt(0) <= 'f'.codeUnitAt(0)) {
    return 10 + c.codeUnitAt(0) - 'a'.codeUnitAt(0);
  } else if (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
      c.codeUnitAt(0) <= 'F'.codeUnitAt(0)) {
    return 10 + c.codeUnitAt(0) - 'A'.codeUnitAt(0);
  } else {
    return -1;
  }
}

Number? setFromSexagesimal(String str) {
  var degreeIndex = str.indexOf('°');
  if (degreeIndex < 0) {
    return null;
  }

  var degrees = mpSetFromString(str.substring2(0, degreeIndex));
  if (degrees == null) {
    return null;
  }

  var minuteStart = degreeIndex;
  var rMinuteStart = RefInt(minuteStart);
  var rChar = RefString('');
  str.getNextChar(rMinuteStart, rChar);
  minuteStart = rMinuteStart.value;
  var c = rChar.value;

  if (str[minuteStart] == '0') {
    return degrees;
  }

  var minuteIndex = str.indexOf('\'', minuteStart);
  if (minuteIndex < 0) {
    return null;
  }

  var minutes =
      mpSetFromString(str.substring2(minuteStart, minuteIndex - minuteStart));
  if (minutes == null) {
    return null;
  }

  degrees = degrees.add(minutes.divideInteger(60));

  var secondStart = minuteIndex;
  var rSecondStart = RefInt(secondStart);
  str.getNextChar(rSecondStart, rChar);
  secondStart = rSecondStart.value;
  c = rChar.value;

  if (str[secondStart] == '0') {
    return degrees;
  }

  var secondIndex = str.indexOf('"', secondStart);
  if (secondIndex < 0) {
    return null;
  }

  var seconds =
      mpSetFromString(str.substring2(secondStart, secondIndex - secondStart));
  if (seconds == null) {
    return null;
  }

  degrees = degrees.add(seconds.divideInteger(3600));

  var rSecondIndex = RefInt(secondIndex);
  str.getNextChar(rSecondIndex, rChar);
  secondIndex = rSecondIndex.value;
  c = rChar.value;

/* Skip over second marker and expect no more characters */
  if (str[secondIndex] == '0') {
    return degrees;
  } else {
    return null;
  }
}

// Returns true if x is cannot be represented in a binary word of length 'wordlen'
bool mpIsOverflow(Number x, int wordlen) {
  var z = Number.fromInt(2).xpowyInteger(wordlen);
  return z.compare(x) > 0;
}

// Tests for the mpSetFromString function
void testSetFromString() {
  var testCases = [
    '-10',
    '-10.0',
    '-0',
    '-0.0',
    '0',
    '0.0',
    '+0',
    '+0.0',
    '10',
    '10.0',
    '+10',
    '+10.0',
    '-0.1',
    '-0.01',
    '-0.001',
    '-0.0001',
    '-0.00001',
    '-0.000001',
    '-0.0000001',
    '0.1',
    '0.01',
    '0.001',
    '0.0001',
    '0.00001',
    '0.000001',
    '0.0000001',
    '+0.1',
    '+0.01',
    '+0.001',
    '+0.0001',
    '+0.00001',
    '+0.000001',
    '+0.0000001',
    '-123456789123456789123456789123456789123456789123456789.123456789123456789123456789123456789123456789123456789',
    '123456789123456789123456789123456789123456789123456789.123456789123456789123456789123456789123456789123456789',
    '+123456789123456789123456789123456789123456789123456789.123456789123456789123456789123456789123456789123456789',
  ];

  for (var i = 0; i < testCases.length; i++) {
    var z = mpSetFromString(testCases[i]);
    print('Test case: ${testCases[i]}');
    print('Result: ${z.toString()}');
  }
}

// tests for operations on numbers
void testOperations() {
  var x = Number.fromInt(10);
  var y = Number.fromInt(3);

  var z = x.add(y);
  print('Addition: ${z.toString()}');

  z = x.subtract(y);
  print('Subtraction: ${z.toString()}');

  z = x.multiply(y);
  print('Multiplication: ${z.toString()}');

  z = x.divide(y);
  print('Division: ${z.toString()}');

  z = x.modulusDivide(y);
  print('Modulus Division: ${z.toString()}');

  z = x.modularExponentiation(y, Number.fromInt(33));
  print('Modular Exponentiation: ${z.toString()}');

  z = x.factorial();
  print('Factorial: ${z.toString()}');

  z = x.sin();
  print('Sine: ${z.toString()}');

  z = x.cos();
  print('Cosine: ${z.toString()}');

  z = x.tan();
  print('Tangent: ${z.toString()}');

  z = x.asin();
  print('Arc Sine: ${z.toString()}');

  z = x.acos();
  print('Arc Cosine: ${z.toString()}');

  z = x.atan();
  print('Arc Tangent: ${z.toString()}');

  z = x.sinh();
  print('Hyperbolic Sine: ${z.toString()}');

  z = x.cosh();
  print('Hyperbolic Cosine: ${z.toString()}');

  z = x.tanh();
  print('Hyperbolic Tangent: ${z.toString()}');

  z = x.asinh();
  print('Hyperbolic Arc Sine: ${z.toString()}');

  z = x.acosh();
  print('Hyperbolic Arc Cosine: ${z.toString()}');

  z = x.atanh();
  print('Hyperbolic Arc Tangent: ${z.toString()}');

  z = x.ln();
  print('Natural Logarithm: ${z.toString()}');

  z = x.logarithm(2);
  print('Logarithm base 2: ${z.toString()}');

  z = x.logarithm(10);
  print('Logarithm base 10: ${z.toString()}');

  z = x.sqrt();
  print('Square Root: ${z.toString()}');

  z = x.root(3);
  print('Cube Root: ${z.toString()}');

  z = x.xpowy(y);
  print('Power: ${z.toString()}');

  z = x.xpowyInteger(3);
  print('Power Integer: ${z.toString()}');

  z = x.reciprocal();
  print('Reciprocal: ${z.toString()}');

  z = x.invertSign();
  print('Invert Sign: ${z.toString()}');

  z = x.abs();
  print('Absolute Value: ${z.toString()}');

  z = x.floor();
  print('Floor: ${z.toString()}');

  z = x.ceiling();
  print('Ceiling: ${z.toString()}');

  z = x.round();
  print('Round: ${z.toString()}');
}


// main
void main() {
  // testSetFromString();
  // testOperations();

  Number n = Number.e();
  print(n.toString());
  n = Number.pi();
  print(n.toString());
}
