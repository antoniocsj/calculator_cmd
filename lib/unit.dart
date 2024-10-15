import 'package:calculator/number.dart';
import 'package:calculator/equation.dart';
import 'package:calculator/serializer.dart';
import 'package:calculator/enums.dart';

UnitManager? defaultUnitManager;

class UnitManager {
  late List<UnitCategory> categories;

  UnitManager() {
    categories = [];
  }

  static UnitManager getDefault() {
    if (defaultUnitManager != null) {
      return defaultUnitManager!;
    }

    defaultUnitManager = UnitManager();

    var angleCategory = defaultUnitManager!.addCategory("angle", "Angle");
    var lengthCategory = defaultUnitManager!.addCategory("length", "Length");
    var areaCategory = defaultUnitManager!.addCategory("area", "Area");
    var volumeCategory = defaultUnitManager!.addCategory("volume", "Volume");
    var weightCategory = defaultUnitManager!.addCategory("weight", "Weight");
    var speedCategory = defaultUnitManager!.addCategory("speed", "Speed");
    var durationCategory = defaultUnitManager!.addCategory("duration", "Duration");
    var frequencyCategory = defaultUnitManager!.addCategory("frequency", "Frequency");
    var temperatureCategory = defaultUnitManager!.addCategory("temperature", "Temperature");
    var energyCategory = defaultUnitManager!.addCategory("energy", "Energy");
    var digitalStorageCategory = defaultUnitManager!.addCategory("digitalstorage", "Digital Storage");

    /* FIXME: Approximations of 1/(units in a circle), therefore, 360 deg != 400 grads */
    angleCategory.addUnit(Unit('degree', 'Degrees', '%s degrees', 'π*x/180', '180*x/π', '°'));
    angleCategory.addUnit(Unit('radian', 'Radians', '%s rad', 'x', 'x', 'rad'));
    angleCategory.addUnit(Unit('gradian', 'Gradians', '%s grads', 'π*x/200', '200*x/π', 'grad'));
    lengthCategory.addUnit(Unit('parsec', 'Parsecs', '%s pc', '30857000000000000*x', 'x/30857000000000000', 'pc'));
    lengthCategory.addUnit(Unit('lightyear', 'Light Years', '%s ly', '9460730472580800*x', 'x/9460730472580800', 'ly'));
    lengthCategory.addUnit(Unit('astronomical-unit', 'Astronomical Units', '%s au', '149597870700*x', 'x/149597870700', 'au'));
    lengthCategory.addUnit(Unit('rack-unit', 'Rack Units', '%s U', 'x/22.49718785151856', '22.49718785151856*x', 'U'));
    lengthCategory.addUnit(Unit('nautical-mile', 'Nautical Miles', '%s nmi', '1852*x', 'x/1852', 'nmi'));
    lengthCategory.addUnit(Unit('mile', 'Miles', '%s mi', '1609.344*x', 'x/1609.344', 'mi'));
    lengthCategory.addUnit(Unit('kilometer', 'Kilometers', '%s km', '1000*x', 'x/1000', 'km'));
    lengthCategory.addUnit(Unit('cable', 'Cables', '%s cb', '219.456*x', 'x/219.456', 'cb'));
    lengthCategory.addUnit(Unit('fathom', 'Fathoms', '%s ftm', '1.8288*x', 'x/1.8288', 'ftm'));
    lengthCategory.addUnit(Unit('meter', 'Meters', '%s m', 'x', 'x', 'm'));
    lengthCategory.addUnit(Unit('yard', 'Yards', '%s yd', '0.9144*x', 'x/0.9144', 'yd'));
    lengthCategory.addUnit(Unit('foot', 'Feet', '%s ft', '0.3048*x', 'x/0.3048', 'ft'));
    lengthCategory.addUnit(Unit('inch', 'Inches', '%s in', '0.0254*x', 'x/0.0254', 'in'));
    lengthCategory.addUnit(Unit('centimeter', 'Centimeters', '%s cm', 'x/100', '100*x', 'cm'));
    lengthCategory.addUnit(Unit('millimeter', 'Millimeters', '%s mm', 'x/1000', '1000*x', 'mm'));
    lengthCategory.addUnit(Unit('micrometer', 'Micrometers', '%s μm', 'x/1000000', '1000000*x', 'μm'));
    lengthCategory.addUnit(Unit('nanometer', 'Nanometers', '%s nm', 'x/1000000000', '1000000000*x', 'nm'));
    lengthCategory.addUnit(Unit('point', 'Desktop Publishing Point', '%s pt', '0.000352777778*x', 'x/0.000352777778', 'pt'));
    speedCategory.addUnit(Unit('kilometers-hour', 'Kilometers per hour', '%s km/h', 'x/3.6', '3.6*x', 'km/h'));
    speedCategory.addUnit(Unit('miles-hour', 'Miles per hour', '%s miles/h', 'x/2.23693629', '2.23693629*x', 'miles/h'));
    speedCategory.addUnit(Unit('meters-second', 'Meters per second', '%s m/s', 'x', 'x', 'm/s'));
    speedCategory.addUnit(Unit('feet-second', 'Feet per second', '%s feet/s', 'x/3.28084', '3.28084*x', 'feet/s'));
    speedCategory.addUnit(Unit('knot', 'Knots', '%s kt', 'x/1.94384449', '1.94384449*x', 'kt'));
    areaCategory.addUnit(Unit('hectare', 'Hectares', '%s ha', '10000*x', 'x/10000', 'ha'));
    areaCategory.addUnit(Unit('acre', 'Acres', '%s acres', '4046.8564224*x', 'x/4046.8564224', 'acres'));
    areaCategory.addUnit(Unit('square-foot', 'Square Foot', '%s ft²', 'x/10.763910417', '10.763910417*x', 'ft²'));
    areaCategory.addUnit(Unit('square-meter', 'Square Meters', '%s m²', 'x', 'x', 'm²'));
    areaCategory.addUnit(Unit('square-centimeter', 'Square Centimeters', '%s cm²', '0.0001*x', '10000*x', 'cm²'));
    areaCategory.addUnit(Unit('square-millimeter', 'Square Millimeters', '%s mm²', '0.000001*x', '1000000*x', 'mm²'));
    volumeCategory.addUnit(Unit('cubic-meter', 'Cubic Meters', '%s m³', '1000*x', 'x/1000', 'm³'));
    volumeCategory.addUnit(Unit('gallon', 'US Gallons', '%s gal', '3.785412*x', 'x/3.785412', 'gal'));
    volumeCategory.addUnit(Unit('litre', 'Liters', '%s L', 'x', 'x', 'L'));
    volumeCategory.addUnit(Unit('quart', 'US Quarts', '%s qt', '0.9463529*x', 'x/0.9463529', 'qt'));
    volumeCategory.addUnit(Unit('pint', 'US Pints', '%s pt', '0.4731765*x', 'x/0.4731765', 'pt'));
    volumeCategory.addUnit(Unit('cup', 'Metric Cups', '%s cup', '0.25*x', '4*x', 'cup'));
    volumeCategory.addUnit(Unit('millilitre', 'Milliliters', '%s mL', '0.001*x', '1000*x', 'mL'));
    volumeCategory.addUnit(Unit('microlitre', 'Microliters', '%s μL', '0.000001*x', '1000000*x', 'μL'));
    weightCategory.addUnit(Unit('tonne', 'Tonnes', '%s T', '1000*x', 'x/1000', 'T'));
    weightCategory.addUnit(Unit('kilograms', 'Kilograms', '%s kg', 'x', 'x', 'kg'));
    weightCategory.addUnit(Unit('pound', 'Pounds', '%s lb', '0.45359237*x', 'x/0.45359237', 'lb'));
    weightCategory.addUnit(Unit('ounce', 'Ounces', '%s oz', '0.02834952*x', 'x/0.02834952', 'oz'));
    weightCategory.addUnit(Unit('troy-ounce', 'Troy Ounces', '%s ozt', '0.0311034768*x', 'x/0.0311034768', 'ozt'));
    weightCategory.addUnit(Unit('gram', 'Grams', '%s g', '0.001*x', '1000*x', 'g'));
    weightCategory.addUnit(Unit('stone', 'Stone', '%s st', '6.350293*x', 'x/6.350293', 'st'));
    durationCategory.addUnit(Unit('century', 'Centuries', '%s centuries', '3155760000*x', 'x/3155760000', 'centuries'));
    durationCategory.addUnit(Unit('decade', 'Decades', '%s decades', '315576000*x', 'x/315576000', 'decades'));
    durationCategory.addUnit(Unit('year', 'Years', '%s years', '31557600*x', 'x/31557600', 'years'));
    durationCategory.addUnit(Unit('month', 'Months', '%s months', '2629800*x', 'x/2629800', 'months'));
    durationCategory.addUnit(Unit('week', 'Weeks', '%s weeks', '604800*x', 'x/604800', 'weeks'));
    durationCategory.addUnit(Unit('day', 'Days', '%s days', '86400*x', 'x/86400', 'days'));
    durationCategory.addUnit(Unit('hour', 'Hours', '%s hours', '3600*x', 'x/3600', 'hours'));
    durationCategory.addUnit(Unit('minute', 'Minutes', '%s minutes', '60*x', 'x/60', 'minutes'));
    durationCategory.addUnit(Unit('second', 'Seconds', '%s s', 'x', 'x', 's'));
    durationCategory.addUnit(Unit('millisecond', 'Milliseconds', '%s ms', '0.001*x', '1000*x', 'ms'));
    durationCategory.addUnit(Unit('microsecond', 'Microseconds', '%s μs', '0.000001*x', '1000000*x', 'μs'));
    temperatureCategory.addUnit(Unit('degree-celsius', 'Celsius', '%s ˚C', 'x+273.15', 'x-273.15', '˚C'));
    temperatureCategory.addUnit(Unit('degree-fahrenheit', 'Fahrenheit', '%s ˚F', '(x+459.67)*5/9', 'x*9/5-459.67', '˚F'));
    temperatureCategory.addUnit(Unit('degree-kelvin', 'Kelvin', '%s K', 'x', 'x', 'K'));
    temperatureCategory.addUnit(Unit('degree-rankine', 'Rankine', '%s ˚R', 'x*5/9', 'x*9/5', '˚R'));
    /* We use IEC prefix for digital storage units. i.e. 1 kB = 1 KiloByte = 1000 bytes, and 1 KiB = 1 kibiByte = 1024 bytes */
    digitalStorageCategory.addUnit(Unit('bit', 'Bits', '%s b', 'x/8', '8*x', 'b'));
    digitalStorageCategory.addUnit(Unit('byte', 'Bytes', '%s B', 'x', 'x', 'B'));
    digitalStorageCategory.addUnit(Unit('nibble', 'Nibbles', '%s nibble', 'x/2', '2*x', 'nibble'));
    /* The SI symbol for kilo is k, however we also allow "KB" and "Kb", as they are widely used and accepted. */
    digitalStorageCategory.addUnit(Unit('kilobit', 'Kilobits', '%s kb', '1000*x/8', '8*x/1000', 'kb'));
    digitalStorageCategory.addUnit(Unit('kilobyte', 'Kilobytes', '%s kB', '1000*x', 'x/1000', 'kB'));
    digitalStorageCategory.addUnit(Unit('kibibit', 'Kibibits', '%s Kib', '1024*x/8', '8*x/1024', 'Kib'));
    digitalStorageCategory.addUnit(Unit('kibibyte', 'Kibibytes', '%s KiB', '1024*x', 'x/1024', 'KiB'));
    digitalStorageCategory.addUnit(Unit('megabit', 'Megabits', '%s Mb', '1000000*x/8', '8*x/1000000', 'Mb'));
    digitalStorageCategory.addUnit(Unit('megabyte', 'Megabytes', '%s MB', '1000000*x', 'x/1000000', 'MB'));
    digitalStorageCategory.addUnit(Unit('mebibit', 'Mebibits', '%s Mib', '1048576*x/8', '8*x/1048576', 'Mib'));
    digitalStorageCategory.addUnit(Unit('mebibyte', 'Mebibytes', '%s MiB', '1048576*x', 'x/1048576', 'MiB'));
    digitalStorageCategory.addUnit(Unit('gigabit', 'Gigabits', '%s Gb', '1000000000*x/8', '8*x/1000000000', 'Gb'));
    digitalStorageCategory.addUnit(Unit('gigabyte', 'Gigabytes', '%s GB', '1000000000*x', 'x/1000000000', 'GB'));
    digitalStorageCategory.addUnit(Unit('gibibit', 'Gibibits', '%s Gib', '1073741824*x/8', '8*x/1073741824', 'Gib'));
    digitalStorageCategory.addUnit(Unit('gibibyte', 'Gibibytes', '%s GiB', '1073741824*x', 'x/1073741824', 'GiB'));
    digitalStorageCategory.addUnit(Unit('terabit', 'Terabits', '%s Tb', '1000000000000*x/8', '8*x/1000000000000', 'Tb'));
    digitalStorageCategory.addUnit(Unit('terabyte', 'Terabytes', '%s TB', '1000000000000*x', 'x/1000000000000', 'TB'));
    digitalStorageCategory.addUnit(Unit('tebibit', 'Tebibits', '%s Tib', '1099511627776*x/8', '8*x/1099511627776', 'Tib'));
    digitalStorageCategory.addUnit(Unit('tebibyte', 'Tebibytes', '%s TiB', '1099511627776*x', 'x/1099511627776', 'TiB'));
    digitalStorageCategory.addUnit(Unit('petabit', 'Petabits', '%s Pb', '1000000000000000*x/8', '8*x/1000000000000000', 'Pb'));
    digitalStorageCategory.addUnit(Unit('petabyte', 'Petabytes', '%s PB', '1000000000000000*x', 'x/1000000000000000', 'PB'));
    digitalStorageCategory.addUnit(Unit('pebibit', 'Pebibits', '%s Pib', '1125899906842624*x/8', '8*x/1125899906842624', 'Pib'));
    digitalStorageCategory.addUnit(Unit('pebibyte', 'Pebibytes', '%s PiB', '1125899906842624*x', 'x/1125899906842624', 'PiB'));
    digitalStorageCategory.addUnit(Unit('exabit', 'Exabits', '%s Eb', '1000000000000000000*x/8', '8*x/1000000000000000000', 'Eb'));
    digitalStorageCategory.addUnit(Unit('exabyte', 'Exabytes', '%s EB', '1000000000000000000*x', 'x/1000000000000000000', 'EB'));
    digitalStorageCategory.addUnit(Unit('exbibit', 'Exbibits', '%s Eib', '1152921504606846976*x/8', '8*x/1152921504606846976', 'Eib'));
    digitalStorageCategory.addUnit(Unit('exbibyte', 'Exbibytes', '%s EiB', '1152921504606846976*x', 'x/1152921504606846976', 'EiB'));
    digitalStorageCategory.addUnit(Unit('zettabit', 'Zettabits', '%s Eb', '1000000000000000000000*x/8', '8*x/1000000000000000000000', 'Zb'));
    digitalStorageCategory.addUnit(Unit('zettabyte', 'Zettabytes', '%s EB', '1000000000000000000000*x', 'x/1000000000000000000000', 'ZB'));
    digitalStorageCategory.addUnit(Unit('zebibit', 'Zebibits', '%s Zib', '1180591620717411303424*x/8', '8*x/1180591620717411303424', 'Zib'));
    digitalStorageCategory.addUnit(Unit('zebibyte', 'Zebibytes', '%s ZiB', '1180591620717411303424*x', 'x/1180591620717411303424', 'ZiB'));
    digitalStorageCategory.addUnit(Unit('yottabit', 'Yottabits', '%s Yb', '1000000000000000000000000*x/8', '8*x/1000000000000000000000000', 'Yb'));
    digitalStorageCategory.addUnit(Unit('yottabyte', 'Yottabytes', '%s YB', '1000000000000000000000000*x', 'x/1000000000000000000000000', 'YB'));
    digitalStorageCategory.addUnit(Unit('yobibit', 'Yobibits', '%s Yib', '1208925819614629174706176*x/8', '8*x/1208925819614629174706176', 'Yib'));
    digitalStorageCategory.addUnit(Unit('yobibyte', 'Yobibytes', '%s YiB', '1208925819614629174706176*x', 'x/1208925819614629174706176', 'YiB'));
    frequencyCategory.addUnit(Unit('hertz', 'Hertz', '%s Hz', 'x', 'x', 'Hz'));
    frequencyCategory.addUnit(Unit('kilohertz', 'Kilohertz', '%s kHz', '1000*x', 'x/1000', 'kHz'));
    frequencyCategory.addUnit(Unit('megahertz', 'Megahertz', '%s MHz', '1000000*x', 'x/1000000', 'MHz'));
    frequencyCategory.addUnit(Unit('gigahertz', 'Gigahertz', '%s GHz', '1000000000*x', 'x/1000000000', 'GHz'));
    frequencyCategory.addUnit(Unit('terahertz', 'Terahertz', '%s THz', '1000000000000*x', 'x/1000000000000', 'THz'));
    energyCategory.addUnit(Unit('joule', 'Joule', '%s J', 'x', 'x', 'J'));
    energyCategory.addUnit(Unit('kilojoule', 'Kilojoules', '%s KJ', '1000*x', 'x/1000', 'KJ'));
    energyCategory.addUnit(Unit('megajoule', 'Megajoules', '%s MJ', '1000000*x', 'x/1000000', 'MJ'));
    energyCategory.addUnit(Unit('kilowatthour', 'KilowattHour', '%s kWh', '360000*x', 'x/360000', 'kWh'));
    energyCategory.addUnit(Unit('btu', 'BTU', '%s BTU', 'x*1054.350264489', 'x/1054.350264489', 'BTU'));
    energyCategory.addUnit(Unit('calorie', 'Calorie', '%s cal', 'x*4.184', 'x/4.184', 'cal'));
    energyCategory.addUnit(Unit('erg', 'Erg', '%s erg', 'x/10000000', 'x*10000000', 'erg'));
    energyCategory.addUnit(Unit('ev', 'eV', '%s ev', 'x*1.602176634/10000000000000000000', 'x*1.602176634*10000000000000000000', 'ev'));
    energyCategory.addUnit(Unit('ftlb', 'Ft-lb', '%s ft-lb', 'x*1.3558179483314004', 'x/1.3558179483314004', 'ft-lb'));

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
      var unit = c.getUnitByName(name);
      if (unit != null) {
        count++;
        returnCategory = c;
      }
    }

    if (count > 1) {
      return null;
    } else if (count == 1) {
      return returnCategory;
    }

    for (var c in categories) {
      var unit = c.getUnitByName(name);
      if (unit != null) {
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
      var unit = c.getUnitByName(name);
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
      var xUnits = c.getUnitBySymbol(xSymbol);
      xUnits ??= c.getUnitByName(xSymbol, caseSensitive: false);

      var zUnits = c.getUnitBySymbol(zSymbol);
      zUnits ??= c.getUnitByName(zSymbol, caseSensitive: false);

      if (xUnits != null && zUnits != null) {
        return c.convert(x, xUnits, zUnits);
      }
    }

    return null;
  }
}

class UnitCategory {
  late final List<Unit> units;

  late final String _name;
  String get name => _name;

  late final String _displayName;
  String get displayName => _displayName;

  UnitCategory(this._name, this._displayName) {
    units = [];
  }

  void addUnit(Unit unit) {
    units.add(unit);
  }

  Unit? getUnitByName(String name, {bool caseSensitive = true}) {
    int count = 0;
    Unit? returnUnit;

    for (var unit in units) {
      if ((caseSensitive && unit.name == name) || (!caseSensitive && unit.name.toLowerCase() == name.toLowerCase())) {
        count++;
        returnUnit = unit;
      }
    }

    if (count == 1) {
      return returnUnit;
    }

    return null;
  }

  Unit? getUnitBySymbol(String symbol, {bool caseSensitive = true}) {
    int count = 0;
    Unit? returnUnit;

    for (var unit in units) {
      if (unit.matchesSymbol(symbol)) {
        count++;
        returnUnit = unit;
      }
    }

    if (count > 1) {
      return null;
    }
    else if (count == 1) {
      return returnUnit;
    }

    for (var unit in units) {
      if (unit.matchesSymbol(symbol, caseSensitive: false)) {
        count++;
        returnUnit = unit;
      }
    }

    if (count == 1) {
      return returnUnit;
    }

    return null;
  }

  List<Unit> getUnits() {
    return units;
  }

  Number? convert(Number x, Unit xUnits, Unit zUnits) {
    var t = xUnits.convertFrom(x);

    if (t == null) {
      return null;
    }

    return zUnits.convertTo(t);
  }
}

class Unit {
  late final String _name;
  String get name => _name;

  late final String _displayName;
  String get displayName => _displayName;

  late final String _format;
  late List<String> _symbols;
  String? fromFunction;
  String? toFunction;
  late Serializer serializer;

  Unit(this._name, this._displayName, this._format, this.fromFunction, this.toFunction, String symbols) {
    serializer = Serializer(DisplayFormat.automatic, 10, 4);
    serializer.setLeadingDigits(6);
    serializer.setShowThousandsSeparators(true);

    _symbols = [];
    var symbolNames = symbols.split(",");
    for (var symbolName in symbolNames) {
      _symbols.add(symbolName);
    }
  }

  String getSymbolFromFormat() {
    return _symbols.first;
  }

  bool matchesSymbol(String symbol, {bool caseSensitive = true}) {
    for (var s in _symbols) {
      if ((caseSensitive && s == symbol) || (!caseSensitive && s.toLowerCase() == symbol.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  List<String> getSymbols() {
    return _symbols;
  }

  Number? convertFrom(Number x) {
    if (fromFunction != null) {
      return solveFunction(fromFunction!, x);
    }
    else {
      return x;
    }
  }

  Number? convertTo(Number x) {
    if (toFunction != null) {
      return solveFunction(toFunction!, x);
    }
    else {
      return x;
    }
  }

  String format(Number x) {
    var numberText = serializer.serialize(x);
    return _format.replaceAll("%s", numberText);
  }

  Number? solveFunction(String function, Number x) {
    var equation = UnitSolveEquation(function, x);
    equation.base = 10;
    equation.wordlen = 32;
    var z = equation.parse();
    if (z == null) {
      print("Failed to convert value: $function");
    }
    return z;
  }

}

class UnitSolveEquation extends Equation {
  Number x;

  UnitSolveEquation(super.function, this.x);

  @override
  bool variableIsDefined(String name) {
    return true;
  }

  @override
  Number? getVariable(String name) {
    return x;
  }
}
