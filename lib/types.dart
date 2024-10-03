import 'package:calculator/enums.dart';

// this file contains all the types used in the project.

// class to store the reference of an integer
class RefInt {
  int value;
  RefInt(this.value);
}

// class to store the reference of a double
class RefDouble {
  double value;
  RefDouble(this.value);
}

// class to store the reference of a string
class RefString {
  String value;
  RefString(this.value);
}

// class to store the reference of a boolean
class RefBool {
  bool value;
  RefBool(this.value);
}

extension StringExtensions on String {
  bool isDigit() {
    if (length != 1) return false;
    return contains(RegExp(r'^[0-9]$'));
  }

  bool isHexDigit() {
    if (length != 1) return false;
    return contains(RegExp(r'^[0-9a-fA-F]$'));
  }

  bool isAlpha() {
    if (length != 1) return false;
    return contains(RegExp(r'^[a-zA-Z]$'));
  }

  int charCount([int max = -1]) {
    // Se max for -1, retorna o tamanho da string
    if (max == -1) {
      return runes.length;
    }

    // Converte a string em uma lista de runes
    List<int> runes_ = runes.toList();

    // Conta o número de runes até a posição especificada
    return runes_.sublist(0, max).length;
  }
}

extension StringBuilder on StringBuffer {
  void append(String object) {
    write(object);
  }

  void prepend(String str) {
    String result = str + toString();
    clear();
    write(result);
  }

  void assign(String object) {
    clear();
    write(object);
  }

  void truncate(int length) {
    if (length < 0) {
      throw RangeError.value(length);
    }
    if (length > length) {
      throw RangeError.value(length);
    }
    if (length == 0) {
      clear();
    } else {
      String truncated = toString().substring(0, length);
      clear();
      write(truncated);
    }
  }
}

class ParseResult {
  final int representationBase;
  final ErrorCode errorCode;
  final String? errorToken;
  final int errorStart;
  final int errorEnd;
  final bool result;

  ParseResult({
    required this.representationBase,
    required this.errorCode,
    required this.errorToken,
    required this.errorStart,
    required this.errorEnd,
    required this.result,
  });
}
