import 'dart:math' as math;
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:calculator/mpfr_bindings.dart';

final DynamicLibrary _mpfr = DynamicLibrary.open('external/libmpfr.so');

var mpfr = MPFRNativeLib(_mpfr);

void _realFinalizer(mpfr_ptr ptr) {
  mpfr.mpfr_clear(ptr);
  calloc.free(ptr);
}

// classe Real: Representa um número real com precisão arbitrária
class Real implements Finalizable {
  // Finalizador
  // O finalizador é chamado quando o objeto é coletado pelo coletor de lixo
  static final _finalizer = Finalizer(_realFinalizer);

  // Ponteiro para a estrutura mpfr_t
  late mpfr_ptr _number;

  // variável usada para prevenir o uso do número real após a chamada de dispose
  bool _disposed = false;

  // Retorna um ponteiro para a estrutura mpfr_t
  mpfr_ptr getPointer(){
    return _number;
  }

  final int _precision; // precisão em bits

  // Getter para a precisão
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

  // Construtor
  Real(this._precision) {
    _number = calloc<mpfr_struct>();
    mpfr.mpfr_init2(_number, _precision);
    // _finalizer.attach(this, _number.cast(), detach: this);
    _finalizer.attach(this, _number, detach: this);
  }

  // Construtor a partir de um double
  Real.fromDouble(double value, this._precision) {
    _number = calloc<mpfr_struct>();
    mpfr.mpfr_init2(_number, _precision);
    mpfr.mpfr_set_d(_number, value, mpfr_rnd_t.MPFR_RNDN);
    _finalizer.attach(this, _number, detach: this);
  }

  // Construtor a partir de um inteiro com sinal
  Real.fromInt(int value, this._precision)  {
    _number = calloc<mpfr_struct>();
    mpfr.mpfr_init2(_number, _precision);
    mpfr.mpfr_set_si(_number, value, mpfr_rnd_t.MPFR_RNDN);
    _finalizer.attach(this, _number, detach: this);
  }

  // Construtor a partir de um inteiro sem sinal
  Real.fromUInt(int value, this._precision) {
    _number = calloc<mpfr_struct>();
    mpfr.mpfr_init2(_number, _precision);
    mpfr.mpfr_set_ui(_number, value, mpfr_rnd_t.MPFR_RNDN);
    _finalizer.attach(this, _number, detach: this);
  }

  // Construtor a partir de uma string
  Real.fromString(String value, int base, this._precision) {
    _number = calloc<mpfr_struct>();
    mpfr.mpfr_init2(_number, _precision);
    mpfr.mpfr_set_str(_number, value.toNativeUtf8().cast<Utf8>(), base, mpfr_rnd_t.MPFR_RNDN);
    _finalizer.attach(this, _number, detach: this);
  }

  // Construtor a partir de outro número real
  Real.fromReal(Real value, this._precision) {
    _number = calloc<mpfr_struct>();
    mpfr.mpfr_init2(_number, value._precision);
    mpfr.mpfr_set(_number, value._number, mpfr_rnd_t.MPFR_RNDN);
    _finalizer.attach(this, _number, detach: this);
  }

  // Construtor do número de Euler e = exp(1) = 2.718281828...
  Real.e(this._precision) {
    _number = calloc<mpfr_struct>();
    var one = calloc<mpfr_struct>();

    mpfr.mpfr_init2(_number, _precision);
    mpfr.mpfr_init2(one, _precision);

    mpfr.mpfr_set_si(one, 1, mpfr_rnd_t.MPFR_RNDN);

    // Calcula o número de Euler (e) usando exp(1)
    mpfr.mpfr_exp(_number, one, mpfr_rnd_t.MPFR_RNDN);

    mpfr.mpfr_clear(one);
    calloc.free(one);

    _finalizer.attach(this, _number, detach: this);
  }

  // Construtor da constante de Euler-Mascheroni γ = 0.57721566...
  Real.em(this._precision) {
    _number = calloc<mpfr_struct>();
    mpfr.mpfr_init2(_number, _precision);
    mpfr.mpfr_const_euler(_number, mpfr_rnd_t.MPFR_RNDN);
    // _finalizer.attach(this, _number.cast(), detach: this);
    _finalizer.attach(this, _number, detach: this);
  }

  // Construtor da constante Pi
  Real.pi(this._precision) {
    _number = calloc<mpfr_struct>();
    mpfr.mpfr_init2(_number, _precision);
    mpfr.mpfr_const_pi(_number, mpfr_rnd_t.MPFR_RNDN);
    // _finalizer.attach(this, _number.cast(), detach: this);
    _finalizer.attach(this, _number, detach: this);
  }

  // Construtor da constante Tau (2*Pi)
  Real.tau(this._precision) {
    _number = calloc<mpfr_struct>();
    mpfr.mpfr_init2(_number, _precision);
    mpfr.mpfr_const_pi(_number, mpfr_rnd_t.MPFR_RNDN);
    mpfr.mpfr_mul_si(_number, _number, 2, mpfr_rnd_t.MPFR_RNDN);
    // _finalizer.attach(this, _number.cast(), detach: this);
    _finalizer.attach(this, _number, detach: this);
  }

  // Libera a memória alocada para o número real
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _finalizer.detach(this);
    mpfr.mpfr_clear(_number);
    calloc.free(_number);
  }

  // Atribui um valor double ao número real
  void setDouble(double value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_set_d(_number, value, round);
  }

  // Atribui um valor float ao número real
  void setFloat(double value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_set_flt(_number, value, round);
  }

  // Atribui um valor inteiro com sinal ao número real
  void setInt(int value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_set_si(_number, value, round);
  }

  // Atribui um valor inteiro sem sinal ao número real
  void setUInt(int value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_set_ui(_number, value, round);
  }

  // Atribui um valor string ao número real
  void setString(String value, {int base = 10, mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN}) {
    mpfr.mpfr_set_str(_number, value.toNativeUtf8().cast<Utf8>(), base, round);
  }

  // Atribui um valor real ao número real
  void setReal(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_set(_number, value._number, round);
  }

  // Atribui o valor zero ao número real
  void setZero([int sign = 1]) {
    mpfr.mpfr_set_zero(_number, sign);
  }

  // Atribui o valor pi ao número real
  void setPi([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_const_pi(_number, round);
  }

  // Atribui o valor log2 ao número real
  void setLog2([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_const_log2(_number, round);
  }

  // Atribui o valor euler ao número real
  void setEuler([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_const_euler(_number, round);
  }

  // Atribui o valor catalan ao número real
  void setCatalan([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_const_catalan(_number, round);
  }

  // Atribui o valor tau ao número real
  void setTau([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_const_pi(_number, round);
    mpfr.mpfr_mul_si(_number, _number, 2, round);
  }

  // Retorna o valor do número real como double
  double getDouble([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    return mpfr.mpfr_get_d(_number, round);
  }

  // Retorna o valor do número real como float
  double getFloat([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    return mpfr.mpfr_get_flt(_number, round);
  }

  // Retorna o valor do número real como inteiro com sinal
  int getInt([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    return mpfr.mpfr_get_si(_number, round);
  }

  // Retorna o valor do número real como inteiro sem sinal
  int getUInt([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    return mpfr.mpfr_get_ui(_number, round);
  }

  // Retorna o valor do número real como string
  // usa a função mpfr_get_str para obter a string
  String getString1({int base = 10, int numDigits = 0, mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN}) {
    Pointer<Long> exp = calloc.allocate<Long>(1);
    Pointer<Utf8> str;
    str = mpfr.mpfr_get_str(nullptr, exp, base, numDigits, _number, round);

    String result = str.toDartString();
    mpfr.mpfr_free_str(str);
    calloc.free(exp);

    return result;
  }

  // Retorna o valor do número real como string.
  // usa a função mpfr_asprintf para obter a string
  String getString2({int numDigits = 0, mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN}) {
    Pointer<Pointer<Utf8>> str = calloc.allocate<Pointer<Utf8>>(1);
    int nDigits; // número de dígitos decimais efetivos
    int maxNumDigits = _calculateDigits(_precision, 10);

    if (numDigits <= 0) {
      nDigits = 0;
    } else {
      // print('Number of digits: $numDigits');
      nDigits = math.min(numDigits, maxNumDigits);
      // print('Number of digits (effective): $nDigits');
    }

    Pointer<Utf8> template = '%.${nDigits}Rf'.toNativeUtf8(allocator: calloc);
    mpfr.mpfr_asprintf(str, template);
    String result = str.value.toDartString();
    calloc.free(str);
    calloc.free(template);

    return result;
  }

  String getString([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    return getDouble(round).toString();
  }

  // Retorna true se o número real for zero
  bool isZero() {
    return mpfr.mpfr_zero_p(_number) != 0;
  }

  // Retorna o sinal do número real
  int getSign() {
    return mpfr.mpfr_sgn(_number);
  }

  // Retorna true se o número real for um inteiro
  bool isInteger() {
    return mpfr.mpfr_integer_p(_number) != 0;
  }

  // Retorna true se o número real for um número regular
  bool isRegular() {
    return mpfr.mpfr_regular_p(_number) != 0;
  }

  // Retorna true se o número real for um número finito
  bool isFinite() {
    return mpfr.mpfr_number_p(_number) != 0;
  }

  // Retorna true se o número real for um número infinito
  bool isInfinity() {
    return mpfr.mpfr_inf_p(_number) != 0;
  }

  // Retorna true se o número real for um número NaN
  bool isNaN() {
    return mpfr.mpfr_nan_p(_number) != 0;
  }

  // Retorna true se o número real for um número normal
  bool isNormal() {
    return mpfr.mpfr_number_p(_number) != 0;
  }

  // Testa se o número real é igual a outro número real
  bool isEqual(Real value) {
    return mpfr.mpfr_equal_p(_number, value._number) != 0;
  }

  // Compara o número real com outro número real
  int cmp(Real value) {
    return mpfr.mpfr_cmp(_number, value._number);
  }

  // Compara o número real com um inteiro sem sinal
  int cmpUInt(int value) {
    return mpfr.mpfr_cmp_ui(_number, value);
  }

  // Compara o número real com um inteiro com sinal
  int cmpInt(int value) {
    return mpfr.mpfr_cmp_si(_number, value);
  }

  // Compara o número real com um double
  int cmpDouble(double value) {
    return mpfr.mpfr_cmp_d(_number, value);
  }

  // Calcula a soma de dois números reais
  void add(Real value1, Real value2, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_add(_number, value1._number, value2._number, round);
  }

  // Calcula a soma de um número real com um inteiro com sinal
  void addInt(Real value, int num, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_add_si(_number, value._number, num, round);
  }

  // Calcula a soma de um número real com um inteiro sem sinal
  void addUInt(Real value, int num, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_add_ui(_number, value._number, num, round);
  }

  // Calcula a soma de um número real com um double
  void addDouble(Real value, double num, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_add_d(_number, value._number, num, round);
  }

  // Calcula a subtração de dois números reais
  void sub(Real value1, Real value2, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_sub(_number, value1._number, value2._number, round);
  }

  // Calcula a subtração de um número real com um inteiro com sinal
  void subInt(Real value, int num, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_sub_si(_number, value._number, num, round);
  }

  // Calcula a subtração de um número real com um inteiro sem sinal
  void subUInt(Real value, int num, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_sub_ui(_number, value._number, num, round);
  }

  // Calcula a subtração de um número real com um double
  void subDouble(Real value, double num, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_sub_d(_number, value._number, num, round);
  }

  // Calcula a subtração de um inteiro com sinal com um número real
  void intSub(int num, Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_si_sub(_number, num, value._number, round);
  }

  // Calcula a subtração de um inteiro sem sinal com um número real
  void uintSub(int num, Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_ui_sub(_number, num, value._number, round);
  }

  // Calcula a subtração de um double com um número real
  void doubleSub(double num, Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_d_sub(_number, num, value._number, round);
  }

  // Calcula a multiplicação de dois números reais
  void mul(Real value1, Real value2, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_mul(_number, value1._number, value2._number, round);
  }

  // Calcula a multiplicação de um número real com um inteiro com sinal
  void mulInt(Real value, int num, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_mul_si(_number, value._number, num, round);
  }

  // Calcula a multiplicação de um número real com um inteiro sem sinal
  void mulUInt(Real value, int num, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_mul_ui(_number, value._number, num, round);
  }

  // Calcula a multiplicação de um número real com um double
  void mulDouble(Real value, double num, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_mul_d(_number, value._number, num, round);
  }

  // Calcula a divisão de dois números reais
  void div(Real value1, Real value2, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_div(_number, value1._number, value2._number, round);
  }

  // Calcula a divisão de um número real com um inteiro com sinal
  void divInt(Real value, int num, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_div_si(_number, value._number, num, round);
  }

  // Calcula a divisão de um número real com um inteiro sem sinal
  void divUInt(Real value, int num, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_div_ui(_number, value._number, num, round);
  }

  // Calcula a divisão de um número real com um double
  void divDouble(Real value, double num, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_div_d(_number, value._number, num, round);
  }

  // Calcula a divisão de um inteiro com sinal com um número real
  void intDiv(int num, Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_si_div(_number, num, value._number, round);
  }

  // Calcula a divisão de um inteiro sem sinal com um número real
  void uintDiv(int num, Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_ui_div(_number, num, value._number, round);
  }

  // Calcula a divisão de um double com um número real
  void doubleDiv(double num, Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_d_div(_number, num, value._number, round);
  }

  // Calcula o resto da divisão de dois números reais
  void mod(Real value1, Real value2, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_fmod(_number, value1._number, value2._number, round);
  }

  // Atribui o oposto de um número ao número real
  void neg(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_neg(_number, value._number, round);
  }

  // Calcula a potência de um número real com outro número real
  void pow(Real value, Real exp, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_pow(_number, value._number, exp._number, round);
  }

  // Calcula a potência de um número real com um inteiro com sinal
  void powInt(Real value, int exp, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_pow_si(_number, value._number, exp, round);
  }

  // Calcula a potência de um número real com um inteiro sem sinal
  void powUInt(Real value, int exp, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_pow_ui(_number, value._number, exp, round);
  }

  // Calcula a exponencial de um número real
  void exp(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_exp(_number, value._number, round);
  }

  // Calcula a exponencial de base 2 de um número real
  void exp2(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_exp2(_number, value._number, round);
  }

  // Calcula a exponencial de base 10 de um número real
  void exp10(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_exp10(_number, value._number, round);
  }

  // Calcula a raiz quadrada de um número real
  void sqrt(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_sqrt(_number, value._number, round);
  }

  // Calcula a raiz quadrada de um inteiro sem sinal
  void sqrtUInt(int value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_sqrt_ui(_number, value, round);
  }

  // Calcula o valor absoluto de um número real
  void abs(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_abs(_number, value._number, round);
  }

  // Calcula o valor do seno de um número real
  void sin(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_sin(_number, value._number, round);
  }

  // Calcula o valor do cosseno de um número real
  void cos(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_cos(_number, value._number, round);
  }

  // Calcula o valor da tangente de um número real
  void tan(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_tan(_number, value._number, round);
  }

  // Calcula o valor da secante de um número real
  void sec(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_sec(_number, value._number, round);
  }

  // Calcula o valor da cossecante de um número real
  void csc(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_csc(_number, value._number, round);
  }

  // Calcula o valor da cotangente de um número real
  void cot(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_cot(_number, value._number, round);
  }

  // Calcula o valor do arco seno de um número real
  void asin(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_asin(_number, value._number, round);
  }

  // Calcula o valor do arco cosseno de um número real
  void acos(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_acos(_number, value._number, round);
  }

  // Calcula o valor do arco tangente de um número real
  void atan(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_atan(_number, value._number, round);
  }

  // Calcula o valor da seno hiperbólico de um número real
  void sinh(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_sinh(_number, value._number, round);
  }

  // Calcula o valor do cosseno hiperbólico de um número real
  void cosh(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_cosh(_number, value._number, round);
  }

  // Calcula o valor da tangente hiperbólica de um número real
  void tanh(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_tanh(_number, value._number, round);
  }

  // Calcula o valor do arco seno hiperbólico de um número real
  void asinh(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_asinh(_number, value._number, round);
  }

  // Calcula o valor do arco cosseno hiperbólico de um número real
  void acosh(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_acosh(_number, value._number, round);
  }

  // Calcula o valor do arco tangente hiperbólico de um número real
  void atanh(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_atanh(_number, value._number, round);
  }

  // Calcula o valor do logaritmo natural de um número real
  void log(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_log(_number, value._number, round);
  }

  // Calcula o valor do logaritmo de base 2 de um número real
  void log2(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_log2(_number, value._number, round);
  }

  // Calcula o valor do logaritmo de base 10 de um número real
  void log10(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_log10(_number, value._number, round);
  }

  // Calcula o valor do fatorial de um número real
  void gamma(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_gamma(_number, value._number, round);
  }

  // Calcula o valor do fatorial de um número real. Aceita mpfr_ptr como argumento.
  void gammaPtr(mpfr_ptr value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_gamma(_number, value, round);
  }

  // Calcula a raiz de um número real
  void root(Real value, int n, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_root(_number, value._number, n, round);
  }

  // Calcula a raiz de um número real
  void rootUInt(Real value, int n, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_rootn_ui(_number, value._number, n, round);
  }

  // Calcula a raiz de um número real
  void rootInt(Real value, int n, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_rootn_si(_number, value._number, n, round);
  }

  // Arredonda o número real para cima
  void ceil([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_ceil(_number, _number);
  }

  // Arredonda o número real para baixo
  void floor([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_floor(_number, _number);
  }

  // Trunca o número real
  void trunc([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_trunc(_number, _number);
  }

  // Arredonda o número real
  void round([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_round(_number, _number);
  }

  // Arredonda o número real para o inteiro mais próximo
  void rint([mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_rint(_number, _number, round);
  }

  // Calcula a parte fracionária de um número real
  void frac(Real value, [mpfr_rnd_t round = mpfr_rnd_t.MPFR_RNDN]) {
    mpfr.mpfr_frac(_number, value._number, round);
  }

  // Retorna true se houver divisão por zero
  bool isDivByZero() {
    return mpfr.mpfr_divby0_p() != 0;
  }

  // Retorna true se houver overflow
  bool isOverflow() {
    return mpfr.mpfr_overflow_p() != 0;
  }

  // Retorna true se houver underflow
  bool isUnderflow() {
    return mpfr.mpfr_underflow_p() != 0;
  }

}

// Teste da classe Real
void main() {
  Real r = Real.e(256);
  print(r.getString());
  r.dispose();
}
