import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';
import 'package:calculator/number.dart';
import 'package:calculator/currency.dart';

abstract class CurrencyProvider {
  // Getter and setter for the updated stream
  Stream<void> get updated;
  set updated(Stream<void> value);

  Future<void> updateRates({bool asyncLoad = true});
  void setRefreshInterval(int interval, [bool asyncLoad = true]);
  void clear();
  bool isLoaded();
  String get attributionLink;
  String get providerName;
}

abstract class AbstractCurrencyProvider implements CurrencyProvider {
  final _updatedController = StreamController<void>.broadcast();
  String get rateFilepath;
  String get rateSourceUrl;
  String get sourceName;
  bool loading = false;
  bool loaded = false;
  int refreshInterval = 0;
  List<Currency> currencies = [];
  CurrencyManager currencyManager;

  AbstractCurrencyProvider(this.currencyManager);

  @override
  Stream<void> get updated => _updatedController.stream;

  @override
  set updated(Stream<void> value) {
    _updatedController.add(null);
  }

  @override
  void setRefreshInterval(int interval, [bool asyncLoad = true]) {
    loaded = false;
    _updatedController.add(null);
    refreshInterval = interval;
    updateRates(asyncLoad: asyncLoad);
  }

  @override
  bool isLoaded() => loaded;

  @override
  void clear() {
    File(rateFilepath).deleteSync();
  }

  Currency registerCurrency(String symbol, String source) {
    var currency = currencyManager.addCurrency(symbol, source);
    currencies.add(currency);
    return currency;
  }

  @override
  Future<void> updateRates({bool asyncLoad = true}) async {
    print("Updating $sourceName rates");
    print("Rate file filepath: $rateFilepath");

    if (loading || loaded || refreshInterval == 0) return;

    print("Checking $sourceName rates ");

    if (!fileNeedsUpdate(rateFilepath, refreshInterval as double)) {
      doLoadRates();
      return;
    }

    print("Loading $sourceName rates");

    loading = true;
    if (asyncLoad) {
      await downloadFileAsync(rateSourceUrl, rateFilepath, sourceName);
    }
    else {
      downloadFileSync(rateSourceUrl, rateFilepath, sourceName);
      doLoadRates();
    }
  }

  bool fileNeedsUpdate(String filename, double maxAge) {
    if (maxAge == 0) return false;
    var file = File(filename);
    if (!file.existsSync()) return true;
    var modifyTime = file.lastModifiedSync();
    var now = DateTime.now();
    return now.difference(modifyTime).inSeconds > maxAge;
  }

  void downloadFileSync(String uri, String filename, String source) {
    try {
      var directory = path.dirname(filename);
      Directory(directory).createSync(recursive: true);
      var dest = File(filename);
      var session = HttpClient();
      session.getUrl(Uri.parse(uri)).then((request) => request.close()).then((response) {
        response.pipe(dest.openWrite()).then((_) {
          loading = false;
          doLoadRates();
          print("$source rates updated");
        });
      }).catchError((e) {
        print("Couldn't download $source currency rate file: $e");
      });
    }
    catch (e) {
      print("Couldn't download $source currency rate file: $e");
    }

  }

  Future<void> downloadFileAsync(String uri, String filename, String source) async {
    var directory = path.dirname(filename);
    try {
      await Directory(directory).create(recursive: true);
      var dest = File(filename);
      var session = HttpClient();
      var request = await session.getUrl(Uri.parse(uri));
      var response = await request.close();
      await response.pipe(dest.openWrite());
      loading = false;
      doLoadRates();
      print("$source rates updated");
    } catch (e) {
      print("Couldn't download $source currency rate file: $e");
    }
  }

  void doLoadRates() {
    print("Loaded $sourceName rates");
    loaded = true;
    _updatedController.add(null);
  }
}

class ImfCurrencyProvider extends AbstractCurrencyProvider {
  ImfCurrencyProvider(super.currencyManager);

  @override
  String get rateFilepath => path.join(Directory.systemTemp.path, 'calculator', 'rms_five.xls');

  @override
  String get rateSourceUrl => 'https://www.imf.org/external/np/fin/data/rms_five.aspx?tsvflag=Y';

  @override
  String get attributionLink => 'https://www.imf.org/external/np/fin/data/rms_five.aspx';

  @override
  String get providerName => 'International Monetary Fund';

  @override
  String get sourceName => 'IMF';

  Map<String, String> getNameMap() {
    return {
      'Euro': 'EUR',
      'Japanese yen': 'JPY',
      'U.K. pound': 'GBP',
      'U.S. dollar': 'USD',
      'Algerian dinar': 'DZD',
      'Australian dollar': 'AUD',
      'Bahrain dinar': 'BHD',
      'Bangladeshi taka': 'BDT',
      'Botswana pula': 'BWP',
      'Brazilian real': 'BRL',
      'Brunei dollar': 'BND',
      'Canadian dollar': 'CAD',
      'Chilean peso': 'CLP',
      'Chinese yuan': 'CNY',
      'Colombian peso': 'COP',
      'Czech koruna': 'CZK',
      'Danish krone': 'DKK',
      'Hungarian forint': 'HUF',
      'Icelandic krona': 'ISK',
      'Indian rupee': 'INR',
      'Indonesian rupiah': 'IDR',
      'Iranian rial': 'IRR',
      'Israeli New Shekel': 'ILS',
      'Kazakhstani tenge': 'KZT',
      'Korean won': 'KRW',
      'Kuwaiti dinar': 'KWD',
      'Libyan dinar': 'LYD',
      'Malaysian ringgit': 'MYR',
      'Mauritian rupee': 'MUR',
      'Mexican peso': 'MXN',
      'Nepalese rupee': 'NPR',
      'New Zealand dollar': 'NZD',
      'Norwegian krone': 'NOK',
      'Omani rial': 'OMR',
      'Pakistani rupee': 'PKR',
      'Peruvian sol': 'PEN',
      'Philippine peso': 'PHP',
      'Polish zloty': 'PLN',
      'Qatari riyal': 'QAR',
      'Russian ruble': 'RUB',
      'Saudi Arabian riyal': 'SAR',
      'Singapore dollar': 'SGD',
      'South African rand': 'ZAR',
      'Sri Lankan rupee': 'LKR',
      'Swedish krona': 'SEK',
      'Swiss franc': 'CHF',
      'Thai baht': 'THB',
      'Trinidadian dollar': 'TTD',
      'Tunisian dinar': 'TND',
      'U.A.E. dirham': 'AED',
      'Uruguayan peso': 'UYU',
    };
  }

  @override
  void doLoadRates() {
    var nameMap = getNameMap();
    String data;

    try {
      data = File(rateFilepath).readAsStringSync();
    }
    catch (e) {
      print("Couldn't read IMF currency rate file: $e");
      return;
    }

    var lines = data.split('\n');
    var inData = false;

    for (var line in lines) {
      line = line.trim();

      // Start after first blank line, stop on next. Skip header line.
      if (line.isEmpty) {
        if (!inData) {
          inData = true;
          continue;
        }
        else {
          break;
        }
      }
      if (!inData) continue;

      var tokens = line.split('\t');
      if (tokens[0] != 'Currency') {
        var valueIndex = tokens.indexWhere((token) => token.trim().isNotEmpty, 1);
        if (valueIndex < tokens.length) {
          var symbol = nameMap[tokens[0]];
          if (symbol != null) {
            var currency = getCurrency(symbol);
            var value = mpSetFromString(tokens[valueIndex]);
            if (currency == null && value != null) {
              print("Using IMF rate of ${tokens[valueIndex]} for $symbol");
              currency = registerCurrency(symbol, sourceName);
              value = value.reciprocal();
              currency.setValue(value);
            }
          }
          else {
            print("Unknown currency '${tokens[0]}'");
          }
        }
      }
    }
    super.doLoadRates();
  }

  Currency? getCurrency(String name) {
    return currencyManager.getCurrency(name);
  }
}

class OfflineImfCurrencyProvider extends ImfCurrencyProvider {
  final String sourceFile;

  OfflineImfCurrencyProvider(super.currencyManager, this.sourceFile);

  @override
  void downloadFileSync(String uri, String filename, String source) {
    var directory = path.dirname(filename);
    Directory(directory).createSync(recursive: true);

    var dest = File(filename);
    var sourceFile = File(this.sourceFile);

    try {
      var bodyinput = sourceFile.readAsBytesSync();
      dest.writeAsBytesSync(bodyinput);
      loading = false;
      doLoadRates();
      print("$source rates updated");
    } catch (e) {
      print("Couldn't download $source currency rate file: $e");
    }
  }

  @override
  Future<void> downloadFileAsync(String uri, String filename, String source) async {
    var directory = path.dirname(filename);

    try {
      await Directory(directory).create(recursive: true);
      var dest = File(filename);
      var sourceFile = File(this.sourceFile);
      var bodyinput = await sourceFile.readAsBytes();
      await dest.writeAsBytes(bodyinput);
      loading = false;
      doLoadRates();
      print("$source rates updated");
    } catch (e) {
      print("Couldn't download $source currency rate file: $e");
    }
  }
}

class BCCurrencyProvider extends AbstractCurrencyProvider {
  final String currency;
  final String currencyFilename;

  BCCurrencyProvider(CurrencyManager currencyManager, this.currency, this.currencyFilename) : super(currencyManager) {
    currencyManager.addProvider(this);
  }

  @override
  String get rateFilepath => path.join(Directory.systemTemp.path, 'calculator', '$currencyFilename.xml');

  @override
  String get rateSourceUrl => 'https://www.bankofcanada.ca/valet/observations/$currencyFilename/xml?recent=1';

  @override
  String get attributionLink => 'https://www.bankofcanada.ca/valet/observations/$currencyFilename/xml?recent=1';

  @override
  String get providerName => 'Bank of Canada';

  @override
  String get sourceName => 'BC-$currency';

  @override
  void doLoadRates() {
    // Vala code:
    // Xml.Parser.init ();
    // var document = Xml.Parser.read_file (rate_filepath);
    // if (document == null)
    // {
    //   warning ("Couldn't parse rate file %s", rate_filepath);
    //   return;
    // }
    //
    // var xpath_ctx = new Xml.XPath.Context (document);
    // if (xpath_ctx == null)
    // {
    //   warning ("Couldn't create XPath context");
    //   return;
    // }
    //
    // var xpath_obj = xpath_ctx.eval_expression ("//observations/o[last()]/v");
    // if (xpath_obj == null)
    // {
    //   warning ("Couldn't create XPath object");
    //   return;
    // }
    // var node = xpath_obj->nodesetval->item (0);
    // var rate = node->get_content ();
    //
    // var cad_rate = get_currency ("CAD");
    // if (cad_rate == null)
    // {
    // warning ("Cannot use BC rates as don't have CAD rate");
    // return;
    // }
    //
    // set_rate (currency, rate, cad_rate);
    //
    // base.do_load_rates ();
    //
    // The equivalent Dart code (that uses the package xml) is as follows:
    final document = XmlDocument.parse(File(rateFilepath).readAsStringSync());
    final xpathExpr = "//observations/o[last()]/v";
    final nodes = document.findAllElements('v');

    if (nodes.isEmpty) {
      print("XPath expression $xpathExpr did not return any results");
      return;
    }

    final rate = nodes.last.value;
    final cadRate = getCurrency('CAD');

    if (cadRate == null) {
      print("Cannot use BC rates as don't have CAD rate");
      return;
    }

    setRate(currency, rate!, cadRate);

    super.doLoadRates();
  }

  void setRate(String name, String value, Currency cadRate) {
    print("Using BC rate of $value for $name");
    var c = registerCurrency(name, sourceName);
    var r = mpSetFromString(value);
    var v = cadRate.getValue();
    v = v?.divide(r!);
    c.setValue(v!);
  }

  Currency? getCurrency(String name) {
    return currencyManager.getCurrency(name);
  }
}

class UnCurrencyProvider extends AbstractCurrencyProvider {
  UnCurrencyProvider(CurrencyManager currencyManager) : super(currencyManager) {
    currencyManager.addProvider(this);
  }

  @override
  String get rateFilepath =>
      path.join(Directory.systemTemp.path, 'calculator', 'un-daily.xls');

  @override
  String get rateSourceUrl =>
      'https://treasury.un.org/operationalrates/xsql2CSV.php';

  @override
  String get attributionLink =>
      'https://treasury.un.org/operationalrates/OperationalRates.php';

  @override
  String get providerName => 'United Nations Treasury';

  @override
  String get sourceName => 'UNT';

  Map<String, String> getCurrencyMap() {
    return {
      'JMD': 'Jamaican Dollar',
      'ARS': 'Argentine Peso',
      'UAH': 'Ukrainian Hryvnia',
      'NGN': 'Nigerian Naira',
      'VND': 'Vietnamese Dong',
    };
  }

  @override
  void doLoadRates() {
    var currencyMap = getCurrencyMap();
    String data;

    try {
      data = File(rateFilepath).readAsStringSync();
    }
    catch (e) {
      print("Failed to read exchange rates: $e");
      return;
    }

    var lines = data.split('\r\n');
    var inData = false;
    var usdRate = getCurrency('USD');

    if (usdRate == null) {
      print("Cannot use UN rates as don't have USD rate");
      return;
    }

    for (var line in lines) {
      line = line.trim();

      // Start after first blank line, stop on next
      if (line.isEmpty) {
        if (!inData) {
          inData = true;
          continue;
        }
        else {
          break;
        }
      }
      if (!inData) continue;

      var tokens = line.split('\t');
      var valueIndex = 4;
      var symbolIndex = 2;

      if (valueIndex < tokens.length && symbolIndex < tokens.length) {
        var name = tokens[symbolIndex];
        var value = tokens[valueIndex].trim();

        if (getCurrency(name) == null &&
            currencyMap[name] != null) {
          var c = registerCurrency(name, sourceName);
          var r = mpSetFromString(value);
          print("Registering $name with value '$value'");
          var v = usdRate.getValue();
          v = v!.multiply(r!);
          c.setValue(v);
        }
      }
    }

    super.doLoadRates();
  }

  Currency? getCurrency(String name) {
    return currencyManager.getCurrency(name);
  }
}
