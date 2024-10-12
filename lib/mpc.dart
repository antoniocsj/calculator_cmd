import 'dart:math' as math;
import 'dart:ffi';
import 'package:calculator/mpfr_bindings.dart';
import 'package:calculator/mpc_bindings.dart';
import 'package:calculator/mpfr.dart';
import 'package:ffi/ffi.dart';

class MPCInexact {
  static int inexPos(int inex) {
    if (inex < 0) {
      return 2;
    } else if (inex == 0) {
      return 0;
    } else {
      return 1;
    }
  }

  static int inexNeg(int inex) {
    if (inex == 2) {
      return -1;
    } else if (inex == 0) {
      return 0;
    } else {
      return 1;
    }
  }

  static int inex(int inexRe, int inexIm) {
    return inexPos(inexRe) | (inexPos(inexIm) << 2);
  }

  static int inexRe(int inex) {
    return inexNeg(inex & 3);
  }

  static int inexIm(int inex) {
    return inexNeg(inex >> 2);
  }

  static int inex12(int inex1, int inex2) {
    return inex1 | (inex2 << 4);
  }

  static int inex1(int inex) {
    return inex & 15;
  }

  static int inex2(int inex) {
    return inex >> 4;
  }
}

final DynamicLibrary _mpc = DynamicLibrary.open('lib/external/libmpc.so');

var mpc = MPCNativeLib(_mpc);

void _mpcFinalizer(mpc_ptr ptr) {
  mpc.mpc_clear(ptr);
  calloc.free(ptr);
}

// classe Complex: Representa um número complexo com precisão arbitrária
class Complex implements Finalizable {
  // Finalizador
  // O finalizador é chamado quando o objeto é coletado pelo coletor de lixo
  static final _finalizer = Finalizer(_mpcFinalizer);
  
  late mpc_ptr _complex;

  // variável usada para prevenir o uso do número real após a chamada de dispose
  bool _disposed = false;

  // Retorna um ponteiro para a estrutura mpc_t
  mpc_ptr getPointer() {
    return _complex;
  }

  // Retorna um ponteiro para a parte real do número complexo
  mpfr_ptr getRealPointer() {
    return _complex.cast<mpfr_struct>()+0;
  }

  // Retorna um ponteiro para a parte imaginária do número complexo
  mpfr_ptr getImaginaryPointer() {
    return _complex.cast<mpfr_struct>()+1;
  }

  final int _precision; // Precisão do número complexo

  // Getter para acessar a precisão do número complexo
  int get precision => _precision;

  // Obter a precisão em dígitos decimais
  int get precisionInDigits => _calulatePrecisionInDigits;

  // calcular a precisão em dígitos decimais a partir da precisão em bits.
  // fórmula usada: n_digits = floor(n_bits * log10(2))
  int get _calulatePrecisionInDigits {
    return (_precision * math.log(2) / math.log(10)).floor();
  }

  // calcular a precisão em bits a partir da precisão em dígitos decimais.
  // fórmula usada: n_bits = ceil(n_digits * log2(10))
  // int get _calulatePrecisionInBits {
  //   return (precisionInDigits * math.log(10) / math.log(2)).ceil();
  // }

  // calcular o número de dígitos a partir do número de bits e da base
  int _calculateDigits(int bits, int base) {
    if (base <= 1) {
      throw ArgumentError('Base must be greater than 1');
    }
    return (bits * math.log(2) / math.log(base)).floor();
  }

  // calcular o número de bits a partir do número de dígitos e da base
  // int _calculateBits(int digits, int base) {
  //   if (base <= 1) {
  //     throw ArgumentError('Base must be greater than 1');
  //   }
  //   return (digits * math.log(base) / math.log(2)).ceil();
  // }

  // Setter para alterar o número complexo
  void setComplex(Complex complex) {
    mpc.mpc_set(_complex, complex.getPointer(), MPC_RNDNN);
  }

  Complex([this._precision = 256]) {
    _complex = calloc<mpc_struct>();
    mpc.mpc_init2(_complex, _precision);
    _finalizer.attach(this, _complex, detach: this);
  }

  // Construtor a partir de dois doubles
  Complex.fromDouble(double real, [double imaginary = 0, this._precision = 256]) {
    _complex = calloc<mpc_struct>();
    mpc.mpc_init2(_complex, _precision);
    setDouble(real, imaginary);
    _finalizer.attach(this, _complex, detach: this);
  }

  // Construtor a partir de dois complexos
  Complex.fromComplex(Complex re, Complex imag, [this._precision = 256]) {
    _complex = calloc<mpc_struct>();
    mpc.mpc_init2(_complex, _precision);
    setReal(re.getReal(), imag.getReal());
    _finalizer.attach(this, _complex, detach: this);
  }

  // Construtor a partir de dois inteiros com sinal
  Complex.fromInt(int real, int imaginary, [this._precision = 256]) {
    _complex = calloc<mpc_struct>();
    mpc.mpc_init2(_complex, _precision);
    mpc.mpc_set_si_si(_complex, real, imaginary, MPC_RNDNN);
    _finalizer.attach(this, _complex, detach: this);
  }

  // Construtor a partir de dois inteiros sem sinal
  Complex.fromUInt(int real, int imaginary, [this._precision = 256]) {
    _complex = calloc<mpc_struct>();
    mpc.mpc_init2(_complex, _precision);
    mpc.mpc_set_ui_ui(_complex, real, imaginary, MPC_RNDNN);
    _finalizer.attach(this, _complex, detach: this);
  }

  // Construtor a partir de dois objetos Real
  Complex.fromReal(Real real, Real? imaginary, [this._precision = 256]) {
    _complex = calloc<mpc_struct>();
    mpc.mpc_init2(_complex, _precision);
    setReal(real, imaginary);
    _finalizer.attach(this, _complex, detach: this);
  }

  // Construtor do número de Euler: 2.718281828
  Complex.e([this._precision = 256]) {
    _complex = calloc<mpc_struct>();
    mpc.mpc_init2(_complex, _precision);
    setInt(0, 0);
    var rePtr = getRealPointer();

    var one = calloc<mpfr_struct>();
    mpfr.mpfr_init2(one, _precision);
    mpfr.mpfr_set_si(one, 1, mpfr_rnd_t.MPFR_RNDN);

    // Calcula o número de Euler (e) usando exp(1)
    mpfr.mpfr_exp(rePtr, one, mpfr_rnd_t.MPFR_RNDN);

    mpfr.mpfr_clear(one);
    calloc.free(one);

    _finalizer.attach(this, _complex, detach: this);
  }

  // Construtor da constante de Euler-Mascheroni: 0.577215665
  Complex.em([this._precision = 256]) {
    _complex = calloc<mpc_struct>();
    mpc.mpc_init2(_complex, _precision);
    setInt(0, 0);
    var rePtr = getRealPointer();
    mpfr.mpfr_const_euler(rePtr, mpfr_rnd_t.MPFR_RNDN);
    _finalizer.attach(this, _complex, detach: this);
  }

  // Construtor da constante Pi
  Complex.pi([this._precision = 256]) {
    _complex = calloc<mpc_struct>();
    mpc.mpc_init2(_complex, _precision);
    setInt(0, 0);
    var rePtr = getRealPointer();
    mpfr.mpfr_const_pi(rePtr, mpfr_rnd_t.MPFR_RNDN);
    _finalizer.attach(this, _complex, detach: this);
  }

  // Construtor da constante Tau (2*Pi)
  Complex.tau([this._precision = 256]) {
    _complex = calloc<mpc_struct>();
    mpc.mpc_init2(_complex, _precision);
    setInt(0, 0);
    var rePtr = getRealPointer();
    mpfr.mpfr_const_pi(rePtr, mpfr_rnd_t.MPFR_RNDN);
    mpfr.mpfr_mul_si(rePtr, rePtr, 2, mpfr_rnd_t.MPFR_RNDN);
    _finalizer.attach(this, _complex, detach: this);
  }

  // Libera a memória alocada para o número complexo
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _finalizer.detach(this);
    mpc.mpc_clear(_complex);
    calloc.free(_complex);
  }

  // Retorna a parte real do número complexo como um objeto Real
  Real getReal() {
    mpfr_ptr mpfrRealPtr = getRealPointer();
    Real temp = Real(precision);

    mpfr_ptr mpfrPtr = temp.getPointer();
    mpfr.mpfr_set(mpfrPtr, mpfrRealPtr, mpfr_rnd_t.MPFR_RNDN);

    return temp;
  }

  // Retorna a parte imaginária do número complexo como um objeto Real
  Real getImaginary() {
    mpfr_ptr mpfrRealPtr = getImaginaryPointer();
    Real temp = Real(precision);

    mpfr_ptr mpfrPtr = temp.getPointer();
    mpfr.mpfr_set(mpfrPtr, mpfrRealPtr, mpfr_rnd_t.MPFR_RNDN);

    return temp;
  }

  // Retorna a parte real do número complexo como um double
  double getRealDouble() {
    mpfr_ptr mpfrRealPtr = getRealPointer();
    return mpfr.mpfr_get_d(mpfrRealPtr, mpfr_rnd_t.MPFR_RNDN);
  }

  // Retorna a parte imaginária do número complexo como um double
  double getImaginaryDouble() {
    mpfr_ptr mpfrImagPtr = getImaginaryPointer();
    return mpfr.mpfr_get_d(mpfrImagPtr, mpfr_rnd_t.MPFR_RNDN);
  }

  // Retorna o valor do número complexo como string
  // usa a função mpc_get_str para obter a string
  String getString1({int base = 10, int numDigits = 0, mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN}) {
    int base = 10;
    Pointer<Utf8> str = mpc.mpc_get_str(base, numDigits, _complex, MPC_RNDNN);
    return str.toDartString();
  }

  // Retorna o valor do número complexo como string no formato (a, b),
  // onde a é a parte real e b é a parte imaginária
  String getString([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    Real real = getReal();
    Real imag = getImaginary();

    String strReal = real.getString(round);
    String strImag = imag.getString(round);

    return '($strReal, $strImag)';
  }

  int setReal(Real real, [Real? imag, mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    if (imag == null) {
      return mpc.mpc_set_fr(_complex, real.getPointer(), round.value);
    } else {
      return mpc.mpc_set_fr_fr(_complex, real.getPointer(), imag.getPointer(), round.value);
    }
  }

  int setMPReal(mpfr_ptr real, [mpfr_ptr? imag, mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    if (imag == null) {
      return mpc.mpc_set_fr(_complex, real, round.value);
    } else {
      return mpc.mpc_set_fr_fr(_complex, real, imag, round.value);
    }
  }

  int setDouble(double real, [double imag = 0.0, mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    return mpc.mpc_set_d_d(_complex, real, imag, round.value);
  }

  int setInt(int real, [int imag = 0, mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    return mpc.mpc_set_si_si(_complex, real, imag, round.value);
  }

  int setUInt(int real, [int imag = 0, mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    return mpc.mpc_set_ui_ui(_complex, real, imag, round.value);
  }

  bool isZero() {
    int res = mpc.mpc_cmp_si_si(_complex, 0, 0);
    return MPCInexact.inexRe(res) == 0 && MPCInexact.inexIm(res) == 0;
  }

  bool isEqual(Complex other) {
    int res = mpc.mpc_cmp(_complex, other.getPointer());
    return MPCInexact.inexRe(res) == 0 && MPCInexact.inexIm(res) == 0;
  }

  int cmp(Complex other) {
    return mpc.mpc_cmp(_complex, other.getPointer());
  }

  int cmpIntInt(int real, int imag) {
    return mpc.mpc_cmp_si_si(_complex, real, imag);
  }

  int add(Complex a, Complex b) {
    return mpc.mpc_add(_complex, a.getPointer(), b.getPointer(), MPC_RNDNN);
  }

  int subtract(Complex a, Complex b) {
    return mpc.mpc_sub(_complex, a.getPointer(), b.getPointer(), MPC_RNDNN);
  }

  int multiply(Complex a, Complex b) {
    return mpc.mpc_mul(_complex, a.getPointer(), b.getPointer(), MPC_RNDNN);
  }

  int multiplyInt(Complex a, int b) {
    return mpc.mpc_mul_si(_complex, a.getPointer(), b, MPC_RNDNN);
  }

  int multiplyReal(Complex a, Real b) {
    return mpc.mpc_mul_fr(_complex, a.getPointer(), b.getPointer(), MPC_RNDNN);
  }

  int divide(Complex a, Complex b) {
    return mpc.mpc_div(_complex, a.getPointer(), b.getPointer(), MPC_RNDNN);
  }

  int divideUInt(Complex a, int b) {
    return mpc.mpc_div_ui(_complex, a.getPointer(), b, MPC_RNDNN);
  }

  int uIntDivide(int a, Complex b) {
    return mpc.mpc_ui_div(_complex, a, b.getPointer(), MPC_RNDNN);
  }

  int divideReal(Complex a, Real b) {
    return mpc.mpc_div_fr(_complex, a.getPointer(), b.getPointer(), MPC_RNDNN);
  }

  int realDivide(Real a, Complex b) {
    return mpc.mpc_fr_div(_complex, a.getPointer(), b.getPointer(), MPC_RNDNN);
  }

  int mpRealDivide(mpfr_ptr a, mpc_ptr b) {
    return mpc.mpc_fr_div(_complex, a, b, MPC_RNDNN);
  }

  int negate(Complex a) {
    return mpc.mpc_neg(_complex, a.getPointer(), MPC_RNDNN);
  }

  int power(Complex a, Complex b) {
    return mpc.mpc_pow(_complex, a.getPointer(), b.getPointer(), MPC_RNDNN);
  }

  int powerInt(Complex a, int b) {
    return mpc.mpc_pow_si(_complex, a.getPointer(), b, MPC_RNDNN);
  }

  int powerUInt(Complex a, int b) {
    return mpc.mpc_pow_ui(_complex, a.getPointer(), b, MPC_RNDNN);
  }

  int powerReal(Complex a, Real b) {
    return mpc.mpc_pow_fr(_complex, a.getPointer(), b.getPointer(), MPC_RNDNN);
  }

  int powerDouble(Complex a, double b) {
    return mpc.mpc_pow_d(_complex, a.getPointer(), b, MPC_RNDNN);
  }

  int sqrt(Complex a) {
    return mpc.mpc_sqrt(_complex, a.getPointer(), MPC_RNDNN);
  }

  int exp(Complex a) {
    return mpc.mpc_exp(_complex, a.getPointer(), MPC_RNDNN);
  }

  int log(Complex a) {
    return mpc.mpc_log(_complex, a.getPointer(), MPC_RNDNN);
  }

  int log10(Complex a) {
    return mpc.mpc_log10(_complex, a.getPointer(), MPC_RNDNN);
  }

  int sin(Complex a) {
    return mpc.mpc_sin(_complex, a.getPointer(), MPC_RNDNN);
  }

  int cos(Complex a) {
    return mpc.mpc_cos(_complex, a.getPointer(), MPC_RNDNN);
  }

  int tan(Complex a) {
    return mpc.mpc_tan(_complex, a.getPointer(), MPC_RNDNN);
  }

  int sinh(Complex a) {
    return mpc.mpc_sinh(_complex, a.getPointer(), MPC_RNDNN);
  }

  int cosh(Complex a) {
    return mpc.mpc_cosh(_complex, a.getPointer(), MPC_RNDNN);
  }

  int tanh(Complex a) {
    return mpc.mpc_tanh(_complex, a.getPointer(), MPC_RNDNN);
  }

  int asin(Complex a) {
    return mpc.mpc_asin(_complex, a.getPointer(), MPC_RNDNN);
  }

  int acos(Complex a) {
    return mpc.mpc_acos(_complex, a.getPointer(), MPC_RNDNN);
  }

  int atan(Complex a) {
    return mpc.mpc_atan(_complex, a.getPointer(), MPC_RNDNN);
  }

  int asinh(Complex a) {
    return mpc.mpc_asinh(_complex, a.getPointer(), MPC_RNDNN);
  }

  int acosh(Complex a) {
    return mpc.mpc_acosh(_complex, a.getPointer(), MPC_RNDNN);
  }

  int atanh(Complex a) {
    return mpc.mpc_atanh(_complex, a.getPointer(), MPC_RNDNN);
  }

  int conj(Complex a) {
    return mpc.mpc_conj(_complex, a.getPointer(), MPC_RNDNN);
  }

  double getRealAsDouble() {
    return mpfr.mpfr_get_d(getRealPointer(), mpfr_rnd_t.MPFR_RNDN);
  }

  double getImaginaryAsDouble() {
    return mpfr.mpfr_get_d(getImaginaryPointer(), mpfr_rnd_t.MPFR_RNDN);
  }
}


// Teste da classe Complex
void main() {
  // Cria um número complexo com precisão de 256 bits
  Complex c = Complex.e();

  // Imprime o número complexo
  print(c.getString());

  // Libera a memória alocada para o número complexo
  c.dispose();
}
