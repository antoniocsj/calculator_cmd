import 'dart:convert';
import 'dart:io';
import 'package:calculator/number.dart';

class MathVariables {
  Map<String, Number?> registers = {};
  String fileName = 'variables.json';

  // Construtor
  MathVariables() {
    loadFromFile(fileName);
  }

  // Adiciona uma variável
  void addVariable(String name, Number? value) {
    registers[name] = value;
  }

  // Remove uma variável
  void removeVariable(String name) {
    registers.remove(name);
  }

  // Obtém uma variável
  Number? getVariable(String name) {
    return registers[name];
  }

  // Salva as variáveis em um arquivo
  Future<void> saveToFile(String filePath) async {
    final file = File(filePath);
    final json = jsonEncode(registers.map((key, value) => MapEntry(key, value?.toString())));
    await file.writeAsString(json);
  }

  // Carrega as variáveis de um arquivo
  Future<void> loadFromFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final json = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(json);
      registers = data.map((key, value) => MapEntry(key, _parseNumber(value)));
    }
  }

  // Converte uma string para Number
  Number? _parseNumber(String? value) {
    if (value == null) return null;
    return mpSetFromString(value);
  }
}

// testes da classe MathVariables
void main() async {
  final mathVariables = MathVariables();
  mathVariables.addVariable('x', Number.fromInt(10));
  mathVariables.addVariable('y', Number.fromDouble(20.5));
  mathVariables.addVariable('z', mpSetFromString('3.5'));
  print(mathVariables.registers);
  await mathVariables.saveToFile('variables.json');
  mathVariables.registers.clear();
  print(mathVariables.registers);
  await mathVariables.loadFromFile('variables.json');
  print(mathVariables.registers);
}
