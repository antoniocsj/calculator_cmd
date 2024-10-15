import 'package:calculator/enums.dart';
import 'package:calculator/number.dart';

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

// class to store the reference of an ErrorCode
class RefErrorCode {
  ErrorCode value;
  RefErrorCode(this.value);
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

  bool getNextChar(RefInt index, RefString outChar) {
    if (index.value < 0 || index.value >= length) {
      outChar.value = '';
      return false;
    }

    int charCode = codeUnitAt(index.value);
    if (charCode >= 0xD800 && charCode <= 0xDBFF && index.value + 1 < length) {
      // Handle surrogate pairs for Unicode characters outside the BMP
      int nextCharCode = codeUnitAt(index.value + 1);
      if (nextCharCode >= 0xDC00 && nextCharCode <= 0xDFFF) {
        outChar.value = String.fromCharCodes([charCode, nextCharCode]);
        index.value += 2;
        return true;
      }
    }

    outChar.value = String.fromCharCode(charCode);
    index.value += 1;
    return true;
  }

  bool getPrevChar(RefInt index, RefString outChar) {
    if (index.value <= 0 || index.value > length) {
      outChar.value = '';
      return false;
    }

    int charCode = codeUnitAt(index.value - 1);
    if (charCode >= 0xDC00 && charCode <= 0xDFFF && index.value - 2 >= 0) {
      // Handle surrogate pairs for Unicode characters outside the BMP
      int prevCharCode = codeUnitAt(index.value - 2);
      if (prevCharCode >= 0xD800 && prevCharCode <= 0xDBFF) {
        outChar.value = String.fromCharCodes([prevCharCode, charCode]);
        index.value -= 2;
        return true;
      }
    }

    outChar.value = String.fromCharCode(charCode);
    index.value -= 1;
    return true;
  }

  String substring2(int offset, [int len = -1]) {
    int stringLength = length;

    // Calcula o comprimento da string se offset e len são positivos
    if (offset >= 0 && len >= 0) {
      stringLength = offset + len <= stringLength ? offset + len : stringLength;
    }

    // Ajusta o offset se for negativo
    if (offset < 0) {
      offset = stringLength + offset;
      if (offset < 0) {
        throw ArgumentError("Offset out of range");
      }
    } else if (offset > stringLength) {
      throw ArgumentError("Offset out of range");
    }

    // Ajusta o comprimento se for negativo
    if (len < 0) {
      len = stringLength - offset;
    }

    // Verifica se o comprimento está dentro dos limites
    if (offset + len > stringLength) {
      throw ArgumentError("Length out of range");
    }

    return substring(offset, offset + len);
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

class CreateParseTreeResult {
  final int representationBase;
  final ErrorCode errorCode;
  final String? errorToken;
  final int errorStart;
  final int errorEnd;
  final bool result;

  CreateParseTreeResult({
    required this.representationBase,
    required this.errorCode,
    required this.errorToken,
    required this.errorStart,
    required this.errorEnd,
    required this.result,
  });
}

class ParseResult {
  int representationBase;
  ErrorCode errorCode;
  String? errorToken;
  int errorStart;
  int errorEnd;
  Number? number;

  ParseResult({
    required this.representationBase,
    required this.errorCode,
    required this.errorToken,
    required this.errorStart,
    required this.errorEnd,
    required this.number,
  });
}

// Tests for getNextChar and getPrevChar.
// It iterates over a string and prints the next and previous characters.
void test_1() {
  // String str = 'a𝄞b';
  String str = 'abcde';
  RefInt index = RefInt(0);
  RefString outChar = RefString('');

  while (str.getNextChar(index, outChar)) {
    print('Index: ${index.value}, char: ${outChar.value}');
  }

  while (str.getNextChar(index, outChar)) {
    print('Index: ${index.value}, char: ${outChar.value}');
  }

  while (str.getPrevChar(index, outChar)) {
    print('Index: ${index.value}, char: ${outChar.value}');
  }

  while (str.getPrevChar(index, outChar)) {
    print('Index: ${index.value}, char: ${outChar.value}');
  }
}

void test_2() {
  String str = "Hello, World!";

  // Testando a função substring
  String sub1 = str.substring2(7, 5); // "World"
  print(sub1); // Output: World

  String sub2 = str.substring2(-6, 5); // "World"
  print(sub2); // Output: World

  String sub3 = str.substring2(7); // "World!"
  print(sub3); // Output: World!
}


// main
void main() {
  // test_1();
  test_2();
}
