import 'package:calculator/mpfr.dart';
import 'package:calculator/mpc.dart';
import 'dart:async';

import 'package:calculator/number.dart';


void test_1() {
  Complex x = Complex.fromDouble(-3.6, 2.0);

  print('precision: ${x.precision}');

  Real realPart = x.getReal();
  print('real: ${realPart.getDouble()}');
  realPart.dispose();

  Real imaginaryPart = x.getImaginary();
  print('imag: ${imaginaryPart.getDouble()}');
  imaginaryPart.dispose();

  print('complex: ${x.getString()}');

  print('real: ${x.getRealDouble()}');
  print('imag: ${x.getImaginaryDouble()}');

  x.dispose();
}

void runFor({int n = 1000, int precision = 1000, int delay = 1, bool dispose = true}) async {
  for (int i = 0; i < n; i++) {
    // Real x = Real.fromDouble(3.6, 1000);
    Real x = Real.fromString('3.6', 10, precision);
    print('x: ${x.getDouble()}');
    // print('x: ${x.getString1()}');
    if (delay > 0) {
      await Future.delayed(Duration(milliseconds: delay));
    }
    if (dispose) {
      print('disposing x...');
      x.dispose();
    }
  }
}

void test_2() async {
  while (true) {
    // Real x = Real.fromDouble(3.6, 1000);
    Real x = Real.fromString('3.6', 10, 100000);
    Complex y = Complex.fromDouble(1.8, 2.0, 100000);
    await Future.delayed(const Duration(milliseconds: 100));
    // x.dispose();
  }

  // Real x = Real.fromDouble(3.6, 64);
  // print('x: ${x.getDouble()}');
  // // x.dispose();
}

void test_3() {
  for (int i=0; i<1000; i++) {
    // Real x = Real.fromDouble(3.6, 1000);
    Real x = Real.fromString('3.6', 10, 10);
    // print('x: ${x.getDouble()}');
    // print('x: ${x.getString1()}');
    // x.dispose();
  }

  // Real x = Real.fromDouble(3.6, 64);
  // print('x: ${x.getDouble()}');
  // // x.dispose();
}

void test_4a([int n = 1000]) {
  Real x = Real.fromDouble(3.6, n);
  Real y = Real.fromDouble(1.8, n);
  Real z = Real.fromDouble(0.0, n);

  z.add(x, y);

  // pŕint x, y, and z
  print('x: ${x.getDouble()}, ${x.getString1()}');
  print('y: ${y.getDouble()}, ${y.getString1()}');
  print('z: ${z.getDouble()}, ${z.getString1()}');

  Complex a = Complex.fromDouble(3.6, 1.8, n);
  Complex b = Complex.fromDouble(1.8, 3.6, n);
  Complex c = Complex.fromDouble(0.0, 0.0, n);

  c.add(a, b);

  // pŕint a, b, and c
  print('a: ${a.getString()}, ${a.getString1()}');
  print('b: ${b.getString()}, ${b.getString1()}');
  print('c: ${c.getString()}, ${c.getString1()}');

  Number d = Number.fromDouble(3.6, 1.8);
  Number e = Number.fromDouble(1.8, 3.6);
  Number f = Number.fromDouble(0.0, 0.0);

  f = d.add(e);

  // pŕint d, e, and f
  print('d: ${d.num.getString()}, ${d.num.getString1()}');
  print('e: ${e.num.getString()}, ${e.num.getString1()}');
  print('f: ${f.num.getString()}, ${f.num.getString1()}');

  var h = Number().mpSetFromString('3.60000000000000000000000000000000000000000');
  if (h == null) {
    print('h is null');
  } else {
    print('h: ${h.num.getString()}');
    print('h: ${h.num.getString1()}');
    print('h: ${h.toString()}');
  }
}

void test_4b([int n = 1000]) {
  Number a = Number.fromDouble(3.6, 0.0);
  Number b = Number.fromDouble(1.8, 0.0);
  Number c = Number.fromDouble(0.0, 0.0);

  c = a.add(b);

  // pŕint a, b, and c
  print('a: ${a.num.getString()}, ${a.num.getString1()}');
  print('b: ${b.num.getString()}, ${b.num.getString1()}');
  print('c: ${c.num.getString()}, ${c.num.getString1()}');

  var d = Number().mpSetFromString('3.6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001002003');
  var e = Number().mpSetFromString('1.8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002003004');
  var f = Number().mpSetFromString('0.0');

  if (d == null || e == null || f == null) {
    print('d, e, or f is null');
  } else {
    print('d: ${d.num.getString()}, ${d.num.getString1()}');
    print('e: ${e.num.getString()}, ${e.num.getString1()}');
    print('f: ${f.num.getString()}, ${f.num.getString1()}');

    f = d.add(e);

    print('f: ${f.num.getString()}, ${f.num.getString1()}');
  }
}

void test_5() {
  runFor(n: 100, precision: 1000, delay: 1, dispose: false);

  // wait for 10 seconds doing nothing
  // print('waiting for 10 seconds...');
  // Future.delayed(const Duration(seconds: 10));
}

void main() {
  test_4b();
}
