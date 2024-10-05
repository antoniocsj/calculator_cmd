import 'package:calculator/number.dart';

UnitManager? defaultUnitManager;

class UnitManager {
  late List<UnitCategory> categories;

  UnitManager() {
    categories = [];
  }

  static UnitManager getDefault() {
    // Vala code:
    // if (default_unit_manager != null)
    //             return default_unit_manager;
    //
    //         default_unit_manager = new UnitManager ();
    //
    //         var angle_category = default_unit_manager.add_category ("angle", _("Angle"));
    //         var length_category = default_unit_manager.add_category ("length", _("Length"));
    //         var area_category = default_unit_manager.add_category ("area", _("Area"));
    //         var volume_category = default_unit_manager.add_category ("volume", _("Volume"));
    //         var weight_category = default_unit_manager.add_category ("weight", _("Mass"));
    //         var speed_category = default_unit_manager.add_category ("speed", _("Speed"));
    //         var duration_category = default_unit_manager.add_category ("duration", _("Duration"));
    //         var frequency_category = default_unit_manager.add_category ("frequency", _("Frequency"));
    //         var temperature_category = default_unit_manager.add_category ("temperature", _("Temperature"));
    //         var energy_category = default_unit_manager.add_category("energy",_("Energy"));
    //         var digitalstorage_category = default_unit_manager.add_category ("digitalstorage", _("Digital Storage"));
    //
    //         /* FIXME: Approximations of 1/(units in a circle), therefore, 360 deg != 400 grads */
    //         angle_category.add_unit (new Unit ("degree", _("Degrees"), dpgettext2 (null, "unit-format", "%s degrees"), "π*x/180", "180x/π", dpgettext2 (null, "unit-symbols", "degree,degrees,deg")));
    //         angle_category.add_unit (new Unit ("radian", _("Radians"), dpgettext2 (null, "unit-format", "%s radians"), "x", "x", dpgettext2 (null, "unit-symbols", "radian,radians,rad")));
    //         angle_category.add_unit (new Unit ("gradian", _("Gradians"), dpgettext2 (null, "unit-format", "%s gradians"), "π*x/200", "200x/π", dpgettext2 (null, "unit-symbols", "gradian,gradians,grad")));
    //         length_category.add_unit (new Unit ("parsec", _("Parsecs"), dpgettext2 (null, "unit-format", "%s pc"), "30857000000000000x", "x/30857000000000000", dpgettext2 (null, "unit-symbols", "parsec,parsecs,pc")));
    //         length_category.add_unit (new Unit ("lightyear", _("Light Years"), dpgettext2 (null, "unit-format", "%s ly"), "9460730472580800x", "x/9460730472580800", dpgettext2 (null, "unit-symbols", "lightyear,lightyears,ly")));
    //         length_category.add_unit (new Unit ("astronomical-unit", _("Astronomical Units"), dpgettext2 (null, "unit-format", "%s au"), "149597870700x", "x/149597870700", dpgettext2 (null, "unit-symbols", "au")));
    //         length_category.add_unit (new Unit ("rack-unit", _("Rack Units"), dpgettext2 (null, "unit-format", "%sU"), "x/22.49718785151856", "22.49718785151856x", dpgettext2 (null, "unit-symbols", "U")));
    //         length_category.add_unit (new Unit ("nautical-mile", _("Nautical Miles"), dpgettext2 (null, "unit-format", "%s nmi"), "1852x", "x/1852", dpgettext2 (null, "unit-symbols", "nmi")));
    //         length_category.add_unit (new Unit ("mile", _("Miles"), dpgettext2 (null, "unit-format", "%s mi"), "1609.344x", "x/1609.344", dpgettext2 (null, "unit-symbols", "mile,miles,mi")));
    //         length_category.add_unit (new Unit ("kilometer", _("Kilometers"), dpgettext2 (null, "unit-format", "%s km"), "1000x", "x/1000", dpgettext2 (null, "unit-symbols", "kilometer,kilometers,km,kms")));
    //         length_category.add_unit (new Unit ("cable", _("Cables"), dpgettext2 (null, "unit-format", "%s cb"), "219.456x", "x/219.456", dpgettext2 (null, "unit-symbols", "cable,cables,cb")));
    //         length_category.add_unit (new Unit ("fathom", _("Fathoms"), dpgettext2 (null, "unit-format", "%s ftm"), "1.8288x", "x/1.8288", dpgettext2 (null, "unit-symbols", "fathom,fathoms,ftm")));
    //         length_category.add_unit (new Unit ("meter", _("Meters"), dpgettext2 (null, "unit-format", "%s m"), "x", "x", dpgettext2 (null, "unit-symbols", "meter,meters,m")));
    //         length_category.add_unit (new Unit ("yard", _("Yards"), dpgettext2 (null, "unit-format", "%s yd"), "0.9144x", "x/0.9144", dpgettext2 (null, "unit-symbols", "yard,yards,yd")));
    //         length_category.add_unit (new Unit ("foot", _("Feet"), dpgettext2 (null, "unit-format", "%s ft"), "0.3048x", "x/0.3048", dpgettext2 (null, "unit-symbols", "foot,feet,ft")));
    //         length_category.add_unit (new Unit ("inch", _("Inches"), dpgettext2 (null, "unit-format", "%s in"), "0.0254x", "x/0.0254", dpgettext2 (null, "unit-symbols", "inch,inches,in")));
    //         length_category.add_unit (new Unit ("centimeter", _("Centimeters"), dpgettext2 (null, "unit-format", "%s cm"), "x/100", "100x", dpgettext2 (null, "unit-symbols", "centimeter,centimeters,cm,cms")));
    //         length_category.add_unit (new Unit ("millimeter", _("Millimeters"), dpgettext2 (null, "unit-format", "%s mm"), "x/1000", "1000x", dpgettext2 (null, "unit-symbols", "millimeter,millimeters,mm")));
    //         length_category.add_unit (new Unit ("micrometer", _("Micrometers"), dpgettext2 (null, "unit-format", "%s μm"), "x/1000000", "1000000x", dpgettext2 (null, "unit-symbols", "micrometer,micrometers,um")));
    //         length_category.add_unit (new Unit ("nanometer", _("Nanometers"), dpgettext2 (null, "unit-format", "%s nm"), "x/1000000000", "1000000000x", dpgettext2 (null, "unit-symbols", "nanometer,nanometers,nm")));
    //         length_category.add_unit (new Unit ("point", _("Desktop Publishing Point"), dpgettext2 (null, "unit-format", "%s pt"), "0.000352777778x", "x/0.000352777778", dpgettext2 (null, "unit-symbols", "point,pt,points,pts")));
    //         speed_category.add_unit (new Unit ("kilometers-hour", _("Kilometers per hour"), dpgettext2 (null, "unit-format", "%s km/h"), "x/3.6", "3.6x", dpgettext2 (null, "unit-symbols", "kilometers per hour,kmph,kmh,kph")));
    //         speed_category.add_unit (new Unit ("miles-hour", _("Miles per hour"), dpgettext2 (null, "unit-format", "%s miles/h"), "x/2.23693629", "2.23693629x", dpgettext2 (null, "unit-symbols", "milesph,miles per hour,mi/h,miph,mph")));
    //         speed_category.add_unit (new Unit ("meters-second", _("Meters per second"), dpgettext2 (null, "unit-format", "%s m/s"), "x", "x", dpgettext2 (null, "unit-symbols", "meters per second,mps")));
    //         speed_category.add_unit (new Unit ("feet-second", _("Feet per second"), dpgettext2 (null, "unit-format", "%s feet/s"), "x/3.28084", "3.28084x", dpgettext2 (null, "unit-symbols", "fps,feet per second,feetps")));
    //         speed_category.add_unit (new Unit ("knot", _("Knots"), dpgettext2 (null, "unit-format", "%s kt"), "x/1.94384449", "1.94384449x", dpgettext2 (null, "unit-symbols", "kt,kn,nd,knot,knots")));
    //         area_category.add_unit (new Unit ("hectare", _("Hectares"), dpgettext2 (null, "unit-format", "%s ha"), "10000x", "x/10000", dpgettext2 (null, "unit-symbols", "hectare,hectares,ha")));
    //         area_category.add_unit (new Unit ("acre", _("Acres"), dpgettext2 (null, "unit-format", "%s acres"), "4046.8564224x", "x/4046.8564224", dpgettext2 (null, "unit-symbols", "acre,acres")));
    //         area_category.add_unit (new Unit ("square-foot", _("Square Foot"), dpgettext2 (null, "unit-format", "%s ft²"), "x/10.763910417", "10.763910417x", dpgettext2 (null, "unit-symbols", "ft²")));
    //         area_category.add_unit (new Unit ("square-meter", _("Square Meters"), dpgettext2 (null, "unit-format", "%s m²"), "x", "x", dpgettext2 (null, "unit-symbols", "m²")));
    //         area_category.add_unit (new Unit ("square-centimeter", _("Square Centimeters"), dpgettext2 (null, "unit-format", "%s cm²"), "0.0001x", "10000x", dpgettext2 (null, "unit-symbols", "cm²")));
    //         area_category.add_unit (new Unit ("square-millimeter", _("Square Millimeters"), dpgettext2 (null, "unit-format", "%s mm²"), "0.000001x", "1000000x", dpgettext2 (null, "unit-symbols", "mm²")));
    //         volume_category.add_unit (new Unit ("cubic-meter", _("Cubic Meters"), dpgettext2 (null, "unit-format", "%s m³"), "1000x", "x/1000", dpgettext2 (null, "unit-symbols", "m³")));
    //         volume_category.add_unit (new Unit ("gallon", _("US Gallons"), dpgettext2 (null, "unit-format", "%s gal"), "3.785412x", "x/3.785412", dpgettext2 (null, "unit-symbols", "gallon,gallons,gal")));
    //         volume_category.add_unit (new Unit ("litre", _("Liters"), dpgettext2 (null, "unit-format", "%s L"), "x", "x", dpgettext2 (null, "unit-symbols", "litre,litres,liter,liters,L")));
    //         volume_category.add_unit (new Unit ("quart", _("US Quarts"), dpgettext2 (null, "unit-format", "%s qt"), "0.9463529x", "x/0.9463529", dpgettext2 (null, "unit-symbols", "quart,quarts,qt")));
    //         volume_category.add_unit (new Unit ("pint", _("US Pints"), dpgettext2 (null, "unit-format", "%s pt"), "0.4731765x", "x/0.4731765", dpgettext2 (null, "unit-symbols", "pint,pints,pt")));
    //         volume_category.add_unit (new Unit ("cup", _("Metric Cups"), dpgettext2 (null, "unit-format", "%s cup"), "0.25x", "4x", dpgettext2 (null, "unit-symbols", "cup,cups,cp")));
    //         volume_category.add_unit (new Unit ("millilitre", _("Milliliters"), dpgettext2 (null, "unit-format", "%s mL"), "0.001x", "1000x", dpgettext2 (null, "unit-symbols", "millilitre,millilitres,milliliter,milliliters,mL,cm³")));
    //         volume_category.add_unit (new Unit ("microlitre", _("Microliters"), dpgettext2 (null, "unit-format", "%s μL"), "0.000001x", "1000000x", dpgettext2 (null, "unit-symbols", "mm³,μL,uL")));
    //         weight_category.add_unit (new Unit ("tonne", _("Tonnes"), dpgettext2 (null, "unit-format", "%s T"), "1000x", "x/1000", dpgettext2 (null, "unit-symbols", "tonne,tonnes")));
    //         weight_category.add_unit (new Unit ("kilograms", _("Kilograms"), dpgettext2 (null, "unit-format", "%s kg"), "x", "x", dpgettext2 (null, "unit-symbols", "kilogram,kilograms,kilogramme,kilogrammes,kg,kgs")));
    //         weight_category.add_unit (new Unit ("pound", _("Pounds"), dpgettext2 (null, "unit-format", "%s lb"), "0.45359237x", "x/0.45359237", dpgettext2 (null, "unit-symbols", "pound,pounds,lb,lbs")));
    //         weight_category.add_unit (new Unit ("ounce", _("Ounces"), dpgettext2 (null, "unit-format", "%s oz"), "0.02834952x", "x/0.02834952", dpgettext2 (null, "unit-symbols", "ounce,ounces,oz")));
    //         weight_category.add_unit (new Unit ("troy-ounce", _("Troy Ounces"), dpgettext2 (null, "unit-format", "%s ozt"), "0.0311034768x", "x/0.0311034768", dpgettext2 (null, "unit-symbols", "Troy ounce,Troy ounces,ozt")));
    //         weight_category.add_unit (new Unit ("gram", _("Grams"), dpgettext2 (null, "unit-format", "%s g"), "0.001x", "1000x", dpgettext2 (null, "unit-symbols", "gram,grams,gramme,grammes,g")));
    //         weight_category.add_unit (new Unit ("stone", _("Stone"), dpgettext2 (null, "unit-format", "%s st"), "6.350293x", "x/6.350293", dpgettext2 (null, "unit-symbols", "stone,st,stones")));
    //         duration_category.add_unit (new Unit ("century", _("Centuries"), dpgettext2 (null, "unit-format", "%s centuries"), "3155760000x", "x/3155760000", dpgettext2 (null, "unit-symbols", "century,centuries")));
    //         duration_category.add_unit (new Unit ("decade", _("Decades"), dpgettext2 (null, "unit-format", "%s decades"), "315576000x", "x/315576000", dpgettext2 (null, "unit-symbols", "decade,decades")));
    //         duration_category.add_unit (new Unit ("year", _("Years"), dpgettext2 (null, "unit-format", "%s years"), "31557600x", "x/31557600", dpgettext2 (null, "unit-symbols", "year,years")));
    //         duration_category.add_unit (new Unit ("month", _("Months"), dpgettext2 (null, "unit-format", "%s months"), "2629800x", "x/2629800", dpgettext2 (null, "unit-symbols", "month,months")));
    //         duration_category.add_unit (new Unit ("week", _("Weeks"), dpgettext2 (null, "unit-format", "%s weeks"), "604800x", "x/604800", dpgettext2 (null, "unit-symbols", "week,weeks")));
    //         duration_category.add_unit (new Unit ("day", _("Days"), dpgettext2 (null, "unit-format", "%s days"), "86400x", "x/86400", dpgettext2 (null, "unit-symbols", "day,days")));
    //         duration_category.add_unit (new Unit ("hour", _("Hours"), dpgettext2 (null, "unit-format", "%s hours"), "3600x", "x/3600", dpgettext2 (null, "unit-symbols", "hour,hours")));
    //         duration_category.add_unit (new Unit ("minute", _("Minutes"), dpgettext2 (null, "unit-format", "%s minutes"), "60x", "x/60", dpgettext2 (null, "unit-symbols", "minute,minutes")));
    //         duration_category.add_unit (new Unit ("second", _("Seconds"), dpgettext2 (null, "unit-format", "%s s"), "x", "x", dpgettext2 (null, "unit-symbols", "second,seconds,s")));
    //         duration_category.add_unit (new Unit ("millisecond", _("Milliseconds"), dpgettext2 (null, "unit-format", "%s ms"), "0.001x", "1000x", dpgettext2 (null, "unit-symbols", "millisecond,milliseconds,ms")));
    //         duration_category.add_unit (new Unit ("microsecond", _("Microseconds"), dpgettext2 (null, "unit-format", "%s μs"), "0.000001x", "1000000x", dpgettext2 (null, "unit-symbols", "microsecond,microseconds,us,μs")));
    //         temperature_category.add_unit (new Unit ("degree-celsius", _("Celsius"), dpgettext2 (null, "unit-format", "%s ˚C"), "x+273.15", "x-273.15", dpgettext2 (null, "unit-symbols", "degC,˚C,C,c,Celsius,celsius")));
    //         temperature_category.add_unit (new Unit ("degree-fahrenheit", _("Fahrenheit"), dpgettext2 (null, "unit-format", "%s ˚F"), "(x+459.67)*5/9", "x*9/5-459.67", dpgettext2 (null, "unit-symbols", "degF,˚F,F,f,Fahrenheit,fahrenheit")));
    //         temperature_category.add_unit (new Unit ("degree-kelvin", _("Kelvin"), dpgettext2 (null, "unit-format", "%s K"), "x", "x", dpgettext2 (null, "unit-symbols", "k,K,Kelvin,kelvin")));
    //         temperature_category.add_unit (new Unit ("degree-rankine", _("Rankine"), dpgettext2 (null, "unit-format", "%s ˚R"), "x*5/9", "x*9/5", dpgettext2 (null, "unit-symbols", "degR,˚R,˚Ra,r,R,Rankine,rankine")));
    //         /* We use IEC prefix for digital storage units. i.e. 1 kB = 1 KiloByte = 1000 bytes, and 1 KiB = 1 kibiByte = 1024 bytes */
    //         digitalstorage_category.add_unit (new Unit ("bit", _("Bits"), dpgettext2 (null, "unit-format", "%s b"), "x/8", "8x", dpgettext2 (null, "unit-symbols", "bit,bits,b")));
    //         digitalstorage_category.add_unit (new Unit ("byte", _("Bytes"), dpgettext2 (null, "unit-format", "%s B"), "x", "x", dpgettext2 (null, "unit-symbols", "byte,bytes,B")));
    //         digitalstorage_category.add_unit (new Unit ("nibble", _("Nibbles"), dpgettext2 (null, "unit-format", "%s nibble"), "x/2", "2x", dpgettext2 (null, "unit-symbols", "nibble,nibbles")));
    //         /* The SI symbol for kilo is k, however we also allow "KB" and "Kb", as they are widely used and accepted. */
    //         digitalstorage_category.add_unit (new Unit ("kilobit", _("Kilobits"), dpgettext2 (null, "unit-format", "%s kb"), "1000x/8", "8x/1000", dpgettext2 (null, "unit-symbols", "kilobit,kilobits,kb,Kb")));
    //         digitalstorage_category.add_unit (new Unit ("kilobyte", _("Kilobytes"), dpgettext2 (null, "unit-format", "%s kB"), "1000x", "x/1000", dpgettext2 (null, "unit-symbols", "kilobyte,kilobytes,kB,KB")));
    //         digitalstorage_category.add_unit (new Unit ("kibibit", _("Kibibits"), dpgettext2 (null, "unit-format", "%s Kib"), "1024x/8", "8x/1024", dpgettext2 (null, "unit-symbols", "kibibit,kibibits,Kib")));
    //         digitalstorage_category.add_unit (new Unit ("kibibyte", _("Kibibytes"), dpgettext2 (null, "unit-format", "%s KiB"), "1024x", "x/1024", dpgettext2 (null, "unit-symbols", "kibibyte,kibibytes,KiB")));
    //         digitalstorage_category.add_unit (new Unit ("megabit", _("Megabits"), dpgettext2 (null, "unit-format", "%s Mb"), "1000000x/8", "8x/1000000", dpgettext2 (null, "unit-symbols", "megabit,megabits,Mb")));
    //         digitalstorage_category.add_unit (new Unit ("megabyte", _("Megabytes"), dpgettext2 (null, "unit-format", "%s MB"), "1000000x", "x/1000000", dpgettext2 (null, "unit-symbols", "megabyte,megabytes,MB")));
    //         digitalstorage_category.add_unit (new Unit ("mebibit", _("Mebibits"), dpgettext2 (null, "unit-format", "%s Mib"), "1048576x/8", "8x/1048576", dpgettext2 (null, "unit-symbols", "mebibit,mebibits,Mib")));
    //         digitalstorage_category.add_unit (new Unit ("mebibyte", _("Mebibytes"), dpgettext2 (null, "unit-format", "%s MiB"), "1048576x", "x/1048576", dpgettext2 (null, "unit-symbols", "mebibyte,mebibytes,MiB")));
    //         digitalstorage_category.add_unit (new Unit ("gigabit", _("Gigabits"), dpgettext2 (null, "unit-format", "%s Gb"), "1000000000x/8", "8x/1000000000", dpgettext2 (null, "unit-symbols", "gigabit,gigabits,Gb")));
    //         digitalstorage_category.add_unit (new Unit ("gigabyte", _("Gigabytes"), dpgettext2 (null, "unit-format", "%s GB"), "1000000000x", "x/1000000000", dpgettext2 (null, "unit-symbols", "gigabyte,gigabytes,GB")));
    //         digitalstorage_category.add_unit (new Unit ("gibibit", _("Gibibits"), dpgettext2 (null, "unit-format", "%s Gib"), "1073741824x/8", "8x/1073741824", dpgettext2 (null, "unit-symbols", "gibibit,gibibits,Gib")));
    //         digitalstorage_category.add_unit (new Unit ("gibibyte", _("Gibibytes"), dpgettext2 (null, "unit-format", "%s GiB"), "1073741824x", "x/1073741824", dpgettext2 (null, "unit-symbols", "gibibyte,gibibytes,GiB")));
    //         digitalstorage_category.add_unit (new Unit ("terabit", _("Terabits"), dpgettext2 (null, "unit-format", "%s Tb"), "1000000000000x/8", "8x/1000000000000", dpgettext2 (null, "unit-symbols", "terabit,terabits,Tb")));
    //         digitalstorage_category.add_unit (new Unit ("terabyte", _("Terabytes"), dpgettext2 (null, "unit-format", "%s TB"), "1000000000000x", "x/1000000000000", dpgettext2 (null, "unit-symbols", "terabyte,terabytes,TB")));
    //         digitalstorage_category.add_unit (new Unit ("tebibit", _("Tebibits"), dpgettext2 (null, "unit-format", "%s Tib"), "1099511627776x/8", "8x/1099511627776", dpgettext2 (null, "unit-symbols", "tebibit,tebibits,Tib")));
    //         digitalstorage_category.add_unit (new Unit ("tebibyte", _("Tebibytes"), dpgettext2 (null, "unit-format", "%s TiB"), "1099511627776x", "x/1099511627776", dpgettext2 (null, "unit-symbols", "tebibyte,tebibytes,TiB")));
    //         digitalstorage_category.add_unit (new Unit ("petabit", _("Petabits"), dpgettext2 (null, "unit-format", "%s Pb"), "1000000000000000x/8", "8x/1000000000000000", dpgettext2 (null, "unit-symbols", "petabit,petabits,Pb")));
    //         digitalstorage_category.add_unit (new Unit ("petabyte", _("Petabytes"), dpgettext2 (null, "unit-format", "%s PB"), "1000000000000000x", "x/1000000000000000", dpgettext2 (null, "unit-symbols", "petabyte,petabytes,PB")));
    //         digitalstorage_category.add_unit (new Unit ("pebibit", _("Pebibits"), dpgettext2 (null, "unit-format", "%s Pib"), "1125899906842624x/8", "8x/1125899906842624", dpgettext2 (null, "unit-symbols", "pebibit,pebibits,Pib")));
    //         digitalstorage_category.add_unit (new Unit ("pebibyte", _("Pebibytes"), dpgettext2 (null, "unit-format", "%s PiB"), "1125899906842624x", "x/1125899906842624", dpgettext2 (null, "unit-symbols", "pebibyte,pebibytes,PiB")));
    //         digitalstorage_category.add_unit (new Unit ("exabit", _("Exabits"), dpgettext2 (null, "unit-format", "%s Eb"), "1000000000000000000x/8", "8x/1000000000000000000", dpgettext2 (null, "unit-symbols", "exabit,exabits,Eb")));
    //         digitalstorage_category.add_unit (new Unit ("exabyte", _("Exabytes"), dpgettext2 (null, "unit-format", "%s EB"), "1000000000000000000x", "x/1000000000000000000", dpgettext2 (null, "unit-symbols", "exabyte,exabytes,EB")));
    //         digitalstorage_category.add_unit (new Unit ("exbibit", _("Exbibits"), dpgettext2 (null, "unit-format", "%s Eib"), "1152921504606846976x/8", "8x/1152921504606846976", dpgettext2 (null, "unit-symbols", "exbibit,exbibits,Eib")));
    //         digitalstorage_category.add_unit (new Unit ("exbibyte", _("Exbibytes"), dpgettext2 (null, "unit-format", "%s EiB"), "1152921504606846976x", "x/1152921504606846976", dpgettext2 (null, "unit-symbols", "exbibyte,exbibytes,EiB")));
    //         digitalstorage_category.add_unit (new Unit ("zettabit", _("Zettabits"), dpgettext2 (null, "unit-format", "%s Eb"), "1000000000000000000000x/8", "8x/1000000000000000000000", dpgettext2 (null, "unit-symbols", "zettabit,zettabits,Zb")));
    //         digitalstorage_category.add_unit (new Unit ("zettabyte", _("Zettabytes"), dpgettext2 (null, "unit-format", "%s EB"), "1000000000000000000000x", "x/1000000000000000000000", dpgettext2 (null, "unit-symbols", "zettabyte,zettabytes,ZB")));
    //         digitalstorage_category.add_unit (new Unit ("zebibit", _("Zebibits"), dpgettext2 (null, "unit-format", "%s Zib"), "1180591620717411303424x/8", "8x/1180591620717411303424", dpgettext2 (null, "unit-symbols", "zebibit,zebibits,Zib")));
    //         digitalstorage_category.add_unit (new Unit ("zebibyte", _("Zebibytes"), dpgettext2 (null, "unit-format", "%s ZiB"), "1180591620717411303424x", "x/1180591620717411303424", dpgettext2 (null, "unit-symbols", "zebibyte,zebibytes,ZiB")));
    //         digitalstorage_category.add_unit (new Unit ("yottabit", _("Yottabits"), dpgettext2 (null, "unit-format", "%s Yb"), "1000000000000000000000000x/8", "8x/1000000000000000000000000", dpgettext2 (null, "unit-symbols", "yottabit,yottabits,Yb")));
    //         digitalstorage_category.add_unit (new Unit ("yottabyte", _("Yottabytes"), dpgettext2 (null, "unit-format", "%s YB"), "1000000000000000000000000x", "x/1000000000000000000000000", dpgettext2 (null, "unit-symbols", "yottabyte,yottabytes,YB")));
    //         digitalstorage_category.add_unit (new Unit ("yobibit", _("Yobibits"), dpgettext2 (null, "unit-format", "%s Yib"), "1208925819614629174706176x/8", "8x/1208925819614629174706176", dpgettext2 (null, "unit-symbols", "yobibit,yobibits,Yib")));
    //         digitalstorage_category.add_unit (new Unit ("yobibyte", _("Yobibytes"), dpgettext2 (null, "unit-format", "%s YiB"), "1208925819614629174706176x", "x/1208925819614629174706176", dpgettext2 (null, "unit-symbols", "yobibyte,yobibytes,YiB")));
    //         frequency_category.add_unit (new Unit ("hertz", _("Hertz"), dpgettext2 (null, "unit-format", "%s Hz"), "x", "x", dpgettext2 (null, "unit-symbols", "hertz,Hz")));
    //         frequency_category.add_unit (new Unit ("kilohertz", _("Kilohertz"), dpgettext2 (null, "unit-format", "%s kHz"), "1000x", "x/1000", dpgettext2 (null, "unit-symbols", "kilohertz,kHz")));
    //         frequency_category.add_unit (new Unit ("megahertz", _("Megahertz"), dpgettext2 (null, "unit-format", "%s MHz"), "1000000x", "x/1000000", dpgettext2 (null, "unit-symbols", "megahertz,MHz")));
    //         frequency_category.add_unit (new Unit ("gigahertz", _("Gigahertz"), dpgettext2 (null, "unit-format", "%s GHz"), "1000000000x", "x/1000000000", dpgettext2 (null, "unit-symbols", "gigahertz,GHz")));
    //         frequency_category.add_unit (new Unit ("terahertz", _("Terahertz"), dpgettext2 (null, "unit-format", "%s THz"), "1000000000000x", "x/1000000000000" ,dpgettext2 (null, "unit-symbols", "terahertz,THz")));
    //         energy_category.add_unit (new Unit ("joule", _("Joule"), dpgettext2 (null, "unit-format", "%s J"), "x", "x" ,dpgettext2 (null, "unit-symbols", "Joule,J,joule,joules")));
    //         energy_category.add_unit (new Unit ("kilojoule", _("Kilojoules"), dpgettext2 (null, "unit-format", "%s KJ"), "1000x", "x/1000" ,dpgettext2 (null, "unit-symbols", "KJ,kilojoules,kilojoule")));
    //         energy_category.add_unit (new Unit ("megajoule", _("Megajoules"), dpgettext2 (null, "unit-format", "%s MJ"), "100000x", "x/100000" ,dpgettext2 (null, "unit-symbols", "MJ,megajoules,megajoule")));
    //         energy_category.add_unit (new Unit ("kilowatthour", _("KilowattHour"), dpgettext2 (null, "unit-format", "%s kWh"), "360000x", "x/360000" ,dpgettext2 (null, "unit-symbols", "kwh,kWh,kilowatt-hour,kilowatthour")));
    //         energy_category.add_unit (new Unit ("btu", _("BTU"), dpgettext2 (null, "unit-format", "%s BTU"), "x*1054.350264489", "x/1054.350264489" ,dpgettext2 (null, "unit-symbols", "btu,BTU")));
    //         energy_category.add_unit(new Unit ("calorie", _("Calorie"), dpgettext2 (null, "unit-format", "%s cal"), "x*4.184", "x/4.184", dpgettext2 (null, "unit-symbols", "calories,calorie,cal")));
    //         energy_category.add_unit(new Unit ("erg", _("Erg"), dpgettext2 (null, "unit-format", "%s erg"), "x/10000000", "x*10000000", dpgettext2 (null, "unit-symbols", "ergs,erg")));
    //         energy_category.add_unit(new Unit ("ev", _("eV"), dpgettext2 (null, "unit-format", "%s ev"), "x*1.602176634/10000000000000000000", "x*1.602176634*10000000000000000000", dpgettext2 (null, "unit-symbols", "electronvolt,electronvolts,ev")));
    //         energy_category.add_unit(new Unit ("ftlb", _("Ft-lb"), dpgettext2 (null, "unit-format", "%s ft-lb"), "x*1.3558179483314004", "x/1.3558179483314004", dpgettext2 (null, "unit-symbols", "foot-pound,foot-pounds,ft-lb,ft-lbs")));
    //
    //         var currency_category = default_unit_manager.add_category ("currency", _("Currency"));
    //         var currencies = CurrencyManager.get_default ().get_currencies ();
    //         currencies.sort ((a, b) => { return a.display_name.collate (b.display_name); });
    //         foreach (var currency in currencies)
    //         {
    //             /* Translators: result of currency conversion, %s is the symbol, %%s is the placeholder for amount, i.e.: USD100 */
    //             var format = _("%s%%s").printf (currency.symbol);
    //             var unit = new Unit (currency.name, currency.display_name, format, null, null, currency.name);
    //             currency_category.add_unit ( unit);
    //         }
    //
    //         return default_unit_manager;
    //
    // this following is the equivalent Dart code for the commented code above:
    //
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
