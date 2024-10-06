import 'package:calculator/number.dart';
import 'package:calculator/enums.dart';
import 'package:calculator/serializer.dart';

class MathVariables {
  String fileName;
  Map<String, Number?> registers;
  Serializer serializer;

  MathVariables()
      : fileName = 'gnome-calculator/registers',
        registers = {},
        serializer = Serializer(DisplayFormat.scientific, 10, 50) {
    serializer.setRadix('.');
    registersLoad();
  }

  void registersLoad() {
    String data;
    try {
      // FileUtils.getContents(file_name, out data);
    } catch (e) {
      return;
    }

    registers.clear();

    var lines = data.split('\n');
    for (var line in lines) {
      var i = line.indexOf('=');
      if (i < 0) {
        continue;
      }

      var name = line.substring(0, i).trim();
      var value = line.substring(i + 1).trim();

      var t = Number.from(value);
      if (t != null) {
        registers[name] = t;
      }
    }
  }

  void save() {
    var data = '';
    registers.forEach((name, value) {
      var number = serializer.toString(value);
      data += '$name=$number\n';
    });

    var dir = fileName;
    // DirUtils.createWithParents(dir, 0700);
    try {
      // FileUtils.setContents(file_name, data);
    } catch (e) {
      // ignore
    }
  }

  List<String> arraySortString(List<String> array) {
    bool swapped = true;
    int j = (array[array.length - 1] == null ? 1 : 0);
    String tmp;

    while (swapped) {
      swapped = false;
      j++;
      for (int i = 0; i < array.length - j; i++) {
        if (array[i].compareTo(array[i + 1]) < 0) {
          tmp = array[i];
          array[i] = array[i + 1];
          array[i + 1] = tmp;
          swapped = true;
        }
      }
    }
    return array;
  }

  List<String> getNames() {
    var names = <String>[];

    registers.forEach((name, value) {
      names.add(name);
    });

    return arraySortString(names);
  }

  List<String> variablesEligibleForAutocompletion(String text) {
    var eligibleVariables = <String>[];
    if (text.isEmpty) {
      return eligibleVariables;
    }

    var variables = getNames();
    for (var variable in variables) {
      if (variable.startsWith(text)) {
        eligibleVariables.add(variable);
      }
    }

    return eligibleVariables;
  }

  void set(String name, Number value) {
    bool editing = registers.containsKey(name);
    registers[name] = value;
    save();
    if (editing) {
      // variable_edited(name, value);
    } else {
      // variable_added(name, value);
    }
  }

  Number? get(String name) {
    return registers[name];
  }

  void delete(String name) {
    registers.remove(name);
    save();
    // variable_deleted(name);
  }
}
