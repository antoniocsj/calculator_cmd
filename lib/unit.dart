import 'package:calculator/number.dart';

UnitManager? defaultUnitManager;

class UnitManager {
  List<UnitCategory> categories = [];

  UnitManager();

  static UnitManager getDefault() {
    if (defaultUnitManager == null) {
      defaultUnitManager = UnitManager();
      // Adicione as categorias e unidades aqui
      var volumeCategory = defaultUnitManager!.addCategory("volume", "Volume");
      volumeCategory.addUnit(Unit("gallon", "US Gallons", "%s gal", "3.785412x", "x/3.785412", "gallon,gallons,gal"));
      volumeCategory.addUnit(Unit("litre", "Liters", "%s L", "x", "x", "litre,litres,liter,liters,L"));
      volumeCategory.addUnit(Unit("quart", "US Quarts", "%s qt", "0.9463529x", "x/0.9463529", "quart,quarts,qt"));
      volumeCategory.addUnit(Unit("pint", "US Pints", "%s pt", "0.4731765x", "x/0.4731765", "pint,pints,pt"));
      volumeCategory.addUnit(Unit("cup", "Metric Cups", "%s cup", "0.25x", "4x", "cup,cups,cp"));
      volumeCategory.addUnit(Unit("millilitre", "Milliliters", "%s mL", "0.001x", "1000x", "millilitre,millilitres,milliliter,milliliters,mL,cm³"));
      volumeCategory.addUnit(Unit("microlitre", "Microliters", "%s μL", "0.000001x", "1000000x", "mm³,μL,uL"));
      // Adicione as outras categorias e unidades aqui
    }
    return defaultUnitManager!;
  }

  UnitCategory addCategory(String name, String displayName) {
    var category = UnitCategory(name, displayName);
    categories.add(category);
    return category;
  }

  List<UnitCategory> getCategories() {
    return categories;
  }

  UnitCategory? getCategory(String category) {
    for (var c in categories) {
      if (c.name == category) {
        return c;
      }
    }
    return null;
  }

  UnitCategory? getCategoryOfUnit(String name) {
    int count = 0;
    UnitCategory? returnCategory;
    for (var c in categories) {
      if (c.hasUnit(name)) {
        count++;
        returnCategory = c;
      }
    }
    if (count == 1) {
      return returnCategory;
    }
    return null;
  }

  Unit? getUnitByName(String name) {
    int count = 0;
    Unit? returnUnit;
    for (var c in categories) {
      var unit = c.getUnit(name);
      if (unit != null) {
        count++;
        returnUnit = unit;
      }
    }
    if (count == 1) {
      return returnUnit;
    }
    return null;
  }

  Unit? getUnitBySymbol(String symbol) {
    int count = 0;
    Unit? returnUnit;
    for (var c in categories) {
      var unit = c.getUnitBySymbol(symbol);
      if (unit != null) {
        count++;
        returnUnit = unit;
      }
    }
    if (count == 1) {
      return returnUnit;
    }
    return null;
  }

  bool unitIsDefined(String name) {
    var unit = getUnitBySymbol(name);
    return unit != null;
  }

  Number? convertBySymbol(Number x, String xSymbol, String zSymbol) {
    for (var c in categories) {
      var result = c.convertBySymbol(x, xSymbol, zSymbol);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}

class UnitCategory {
  String name;
  String displayName;
  List<Unit> units = [];

  UnitCategory(this.name, this.displayName);

  void addUnit(Unit unit) {
    units.add(unit);
  }

  bool hasUnit(String name) {
    return units.any((unit) => unit.name == name);
  }

  Unit? getUnit(String name) {
    return units.firstWhere((unit) => unit.name == name, orElse: () => null);
  }

  Unit? getUnitBySymbol(String symbol) {
    return units.firstWhere((unit) => unit.symbols.contains(symbol), orElse: () => null);
  }

  Number? convertBySymbol(Number x, String xSymbol, String zSymbol) {
    var fromUnit = getUnitBySymbol(xSymbol);
    var toUnit = getUnitBySymbol(zSymbol);
    if (fromUnit != null && toUnit != null) {
      return fromUnit.convertTo(x, toUnit);
    }
    return null;
  }
}

class Unit {
  String name;
  String displayName;
  String format;
  String toBase;
  String fromBase;
  List<String> symbols;

  Unit(this.name, this.displayName, this.format, this.toBase, this.fromBase, String symbols)
      : symbols = symbols.split(',');

  Number convertTo(Number x, Unit toUnit) {
    // Implementar a lógica de conversão aqui
    return x;
  }
}

class UnitSolveEquation extends Equation {
  Number x;

  UnitSolveEquation(String function, this.x) : super(function);

  @override
  bool variableIsDefined(String name) {
    return name == "x";
  }

  @override
  Number? getVariable(String name) {
    if (name == "x") {
      return x;
    }
    return null;
  }
}
