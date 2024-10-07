import 'package:calculator/currency.dart';
import 'package:calculator/number.dart';

abstract class CurrencyProvider {
  void updateRates({bool asyncLoad = true});
  void setRefreshInterval(int interval, {bool asyncLoad = true});
  void clear();
  bool isLoaded();
  String get attributionLink;
  String get providerName;
}

abstract class AbstractCurrencyProvider implements CurrencyProvider {
  @override
  String get attributionLink;

  @override
  String get providerName;

  String get rateFilepath;

  String get rateSourceUrl;

  String get sourceName;

  late int refreshInterval;

  @override
  void setRefreshInterval(int interval, {bool asyncLoad = true}) {
    loaded = false;
    updated();

    refreshInterval = interval;
    updateRates(asyncLoad: asyncLoad);
  }

  @override
  bool isLoaded() {
    return loaded;
  }

  late bool loading;
  late bool loaded;
  late List<Currency> currencies;
  late CurrencyManager currencyManager;

  @override
  void clear() {
    FileUtils.remove(rateFilepath);
  }

  Currency registerCurrency(String symbol, String source) {
    Currency currency = currencyManager.addCurrency(symbol, source);
    currencies.add(currency);
    return currency;
  }

  @override
  void updateRates({bool asyncLoad = true}) {
    print("Updating $sourceName rates");

    if (loading || loaded) return;

    if (refreshInterval == 0) return;

    print("Checking $sourceName rates");

    if (!fileNeedsUpdate(rateFilepath, refreshInterval)) {
      doLoadRates();
      return;
    }

    print("Loading $sourceName rates");

    loading = true;

    if (asyncLoad) {
      print("Downloading $sourceName rates async");
      downloadFileAsync(rateSourceUrl, rateFilepath, sourceName);
    } else {
      print("Downloading $sourceName rates sync");
      downloadFileSync(rateSourceUrl, rateFilepath, sourceName);
      doLoadRates();
    }
  }

  Currency? getCurrency(String name) {
    return currencyManager.getCurrency(name);
  }

  void doLoadRates() {
    print("Loaded $sourceName rates");
    loaded = true;
    updated();
  }

  bool fileNeedsUpdate(String filename, double maxAge) {
    if (maxAge == 0) return false;

    if (!FileUtils.test(filename, FileTest.IS_REGULAR)) return true;

    var buf = Posix.Stat();
    if (Posix.stat(filename, buf) == -1) return true;

    var modifyTime = buf.st_mtime;
    var now = time_t();
    if (now - modifyTime > maxAge) return true;

    return false;
  }

  void downloadFileSync(String uri, String filename, String source) {
    doLoadRates();
  }

  void downloadFileAsync(String uri, String filename, String source) {
    doLoadRates();
  }
}

class ImfCurrencyProvider extends AbstractCurrencyProvider {
  @override
  String get rateFilepath {
    return Path.buildFilename(
        Environment.getUserCacheDir(), "calculator", "rms_five.xls");
  }

  @override
  String get rateSourceUrl {
    return "https://www.imf.org/external/np/fin/data/rms_five.aspx?tsvflag=Y";
  }

  @override
  String get attributionLink {
    return "https://www.imf.org/external/np/fin/data/rms_five.aspx";
  }

  @override
  String get providerName {
    return "International Monetary Fund";
  }

  @override
  String get sourceName {
    return "IMF";
  }

  Map<String, String> getNameMap() {
    return {
      "Euro": "EUR",
      "Japanese yen": "JPY",
      "U.K. pound": "GBP",
      "U.S. dollar": "USD",
      "Algerian dinar": "DZD",
      "Australian dollar": "AUD",
      "Bahrain dinar": "BHD",
      "Bangladeshi taka": "BDT",
      "Botswana pula": "BWP",
      "Brazilian real": "BRL",
      "Brunei dollar": "BND",
      "Canadian dollar": "CAD",
      "Chilean peso": "CLP",
      "Chinese yuan": "CNY",
      "Colombian peso": "COP",
      "Czech koruna": "CZK",
      "Danish krone": "DKK",
      "Hungarian forint": "HUF",
      "Icelandic krona": "ISK",
      "Indian rupee": "INR",
      "Indonesian rupiah": "IDR",
      "Iranian rial": "IRR",
      "Israeli New Shekel": "ILS",
      "Kazakhstani tenge": "KZT",
      "Korean won": "KRW",
      "Kuwaiti dinar": "KWD",
      "Libyan dinar": "LYD",
      "Malaysian ringgit": "MYR",
      "Mauritian rupee": "MUR",
      "Mexican peso": "MXN",
      "Nepalese rupee": "NPR",
      "New Zealand dollar": "NZD",
      "Norwegian krone": "NOK",
      "Omani rial": "OMR",
      "Pakistani rupee": "PKR",
      "Peruvian sol": "PEN",
      "Philippine peso": "PHP",
      "Polish zloty": "PLN",
      "Qatari riyal": "QAR",
      "Russian ruble": "RUB",
      "Saudi Arabian riyal": "SAR",
      "Singapore dollar": "SGD",
      "South African rand": "ZAR",
      "Sri Lankan rupee": "LKR",
      "Swedish krona": "SEK",
      "Swiss franc": "CHF",
      "Thai baht": "THB",
      "Trinidadian dollar": "TTD",
      "Tunisian dinar": "TND",
      "U.A.E. dirham": "AED",
      "Uruguayan peso": "UYU",
    };
  }

  @override
  void doLoadRates() {
    var nameMap = getNameMap();

    String data;
    try {
      FileUtils.getContents(rateFilepath, data);
    } catch (Error e) {
      print("Failed to read exchange rates: ${e.message}");
      return;
    }

    var lines = data.split("\n");

    var inData = false;
    for (var line in lines) {
      line = line.trim();

      if (line.isEmpty) {
        if (!inData) {
          inData = true;
          continue;
        } else {
          break;
        }
      }
      if (!inData) continue;

      var tokens = line.split("\t");
      if (tokens[0] != "Currency") {
        int valueIndex;
        for (valueIndex = 1; valueIndex < tokens.length; valueIndex++) {
          var value = tokens[valueIndex].trim();
          if (value.isNotEmpty) break;
        }

        if (valueIndex < tokens.length) {
          var symbol = nameMap[tokens[0]];
          if (symbol != null) {
            var c = getCurrency(symbol);
            var value = mpSetFromString(tokens[valueIndex]);
            if (c == null && value != null) {
              print("Using IMF rate of ${tokens[valueIndex]} for $symbol");
              c = registerCurrency(symbol, sourceName);
              value = value.reciprocal();
              if (c != null) c.setValue(value);
            }
          } else {
            print("Unknown currency '${tokens[0]}'");
          }
        }
      }
    }
    super.doLoadRates();
  }

  ImfCurrencyProvider(CurrencyManager currencyManager) {
    currencyManager.addProvider(this);
  }
}

class OfflineImfCurrencyProvider extends ImfCurrencyProvider {
  String sourceFile;

  OfflineImfCurrencyProvider(super.currencyManager, this.sourceFile);

  @override
  void downloadFileSync(String uri, String filename, String source) {
    var directory = Path.dirname(filename);
    FileUtils.createWithParents(directory, 0o755);

    var dest = File(filename);
    var sourceFile = File(sourceFile);
    try {
      var bodyinput = sourceFile.read();
      var output = dest.replace(null, false, FileCreateFlags.replaceDestination);
      output.splice(bodyinput, OutputStreamSpliceFlags.closeSource | OutputStreamSpliceFlags.closeTarget);
      loading = false;
      doLoadRates();
      print("$source rates updated");
    } catch (Error e) {
      print("Couldn't download $source currency rate file: ${e.message}");
    }
  }

  @override
  void downloadFileAsync(String uri, String filename, String source) {
    var directory = Path.dirname(filename);
    FileUtils.createWithParents(directory, 0o755);

    var dest = File(filename);
    var sourceFile = File(sourceFile);
    try {
      var bodyinput = sourceFile.readAsync();
      var output = dest.replaceAsync(null, false, FileCreateFlags.replaceDestination, Priority.default);
      output.spliceAsync(bodyinput, OutputStreamSpliceFlags.closeSource | OutputStreamSpliceFlags.closeTarget, Priority.default);
      loading = false;
      doLoadRates();
      print("$source rates updated");
    } catch (Error e) {
      print("Couldn't download $source currency rate file: ${e.message}");
    }
  }
}

class EcbCurrency extends AbstractCurrencyProvider {
  @override
  String get rateFilepath {
    return Path.buildFilename(Environment.getUserCacheDir(), "calculator", "eurofxref-daily.xml");
  }

  @override
  String get rateSourceUrl {
    return "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml";
  }

  @override
  String get attributionLink {
    return "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml";
  }

  @override
  String get providerName {
    return "European Central Bank";
  }

  @override
  String get sourceName {
    return "ECB";
  }

  @override
  void doLoadRates() {
    var eurRate = getCurrency("EUR");
    if (eurRate == null) {
      print("Cannot use ECB rates as don't have EUR rate");
      return;
    }

    setEcbFixedRate("BDT", "0.0099", eurRate);
    setEcbFixedRate("RSD", "0.0085", eurRate);
    setEcbFixedRate("EEK", "0.06391", eurRate);
    setEcbFixedRate("CFA", "0.00152449", eurRate);

    var document = XmlParser.readFromFile(rateFilepath);
    if (document == null) {
      print("Couldn't parse ECB rate file $rateFilepath");
      return;
    }

    var xpathCtx = Xml.XPath.Context(document);
    if (xpathCtx == null) {
      print("Couldn't create XPath context");
      return;
    }

    xpathCtx.registerNs("xref", "http://www.ecb.int/vocabulary/2002-08-01/eurofxref");
    var xpathObj = xpathCtx.evalExpression("//xref:Cube[@currency][@rate]");
    if (xpathObj == null) {
      print("Couldn't create XPath object");
      return;
    }

    var len = xpathObj.nodesetval != null ? xpathObj.nodesetval.length : 0;
    for (var i = 0; i < len; i++) {
      var node = xpathObj.nodesetval.item(i);

      if (node.type == Xml.ElementType.element) setEcbRate(node, eurRate);
    }

    super.doLoadRates();
  }

  void setEcbRate(Xml.Node node, Currency eurRate) {
    String? name;
    String? value;

    for (var attribute in node.properties) {
      if (attribute.name == "currency") {
        name = attribute.content;
      } else if (attribute.name == "rate") {
        value = attribute.content;
      }
    }

    if (name != null && value != null && getCurrency(name) == null) {
      print("Using ECB rate of $value for $name");
      var c = registerCurrency(name, sourceName);
      var r = mpSetFromString(value);
      var v = eurRate.getValue();
      v = v?.multiply(r!);
      c.setValue(v!);
    }
  }

  void setEcbFixedRate(String name, String value, Currency eurRate) {
    print("Using ECB fixed rate of $value for $name");
    var c = registerCurrency(name, "$sourceName#fixed");
    var r = mpSetFromString(value);
    var v = eurRate.getValue();
    v = v?.divide(r!);
    c.setValue(v!);
  }

  EcbCurrency(CurrencyManager currencyManager) {
    currencyManager.addProvider(this);
  }
}

class BcCurrencyProvider extends AbstractCurrencyProvider {
  String currency;
  String currencyFilename;

  @override
  String get rateFilepath {
    return Path.buildFilename(Environment.getUserCacheDir(), "calculator", "$currencyFilename.xml");
  }

  @override
  String get rateSourceUrl {
    return "https://www.bankofcanada.ca/valet/observations/$currencyFilename/xml?recent=1";
  }

  @override
  String get attributionLink {
    return "https://www.bankofcanada.ca/valet/observations/$currencyFilename/xml?recent=1";
  }

  @override
  String get providerName {
    return "Bank of Canada";
  }

  @override
  String get sourceName {
    return "BC-$currency";
  }

  @override
  void doLoadRates() {
    var document = XmlParser.readFromFile(rateFilepath);
    if (document == null) {
      print("Couldn't parse rate file $rateFilepath");
      return;
    }

    var xpathCtx = Xml.XPath.Context(document);
    if (xpathCtx == null) {
      print("Couldn't create XPath context");
      return;
    }

    var xpathObj = xpathCtx.evalExpression("//observations/o[last()]/v");
    if (xpathObj == null) {
      print("Couldn't create XPath object");
      return;
    }

    var node = xpathObj.nodesetval.item(0);
    var rate = node.content;

    var cadRate = getCurrency("CAD");
    if (cadRate == null) {
      print("Cannot use BC rates as don't have CAD rate");
      return;
    }

    setRate(currency, rate, cadRate);

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

  BcCurrencyProvider(CurrencyManager currencyManager, this.currency, this.currencyFilename) {
    currencyManager.addProvider(this);
  }
}

class UnCurrencyProvider extends AbstractCurrencyProvider {
  @override
  String get rateFilepath {
    return Path.buildFilename(Environment.getUserCacheDir(), "calculator", "un-daily.xls");
  }

  @override
  String get rateSourceUrl {
    return "https://treasury.un.org/operationalrates/xsql2CSV.php";
  }

  @override
  String get attributionLink {
    return "https://treasury.un.org/operationalrates/OperationalRates.php";
  }

  @override
  String get providerName {
    return "United Nations Treasury";
  }

  @override
  String get sourceName {
    return "UNT";
  }

  Map<String, String> getCurrencyMap() {
    return {
      "JMD": "Jamaican Dollar",
      "ARS": "Argentine Peso",
      "UAH": "Ukrainian Hryvnia",
      "NGN": "Nigerian Naira",
      "VND": "Vietnamese Dong",
    };
  }

  @override
  void doLoadRates() {
    var currencyMap = getCurrencyMap();
    String data;
    try {
      FileUtils.getContents(rateFilepath, data);
    } catch (Error e) {
      print("Failed to read exchange rates: ${e.message}");
      return;
    }

    var lines = data.split("\r\n");

    var inData = false;
    var usdRate = getCurrency("USD");
    if (usdRate == null) {
      print("Cannot use UN rates as don't have USD rate");
      return;
    }
    for (var line in lines) {
      line = line.trim();

      if (line.isEmpty) {
        if (!inData) {
          inData = true;
          continue;
        } else {
          break;
        }
      }
      if (!inData) continue;

      var tokens = line.split("\t");
      int valueIndex = 4;
      int symbolIndex = 2;
      if (valueIndex <= tokens.length && symbolIndex <= tokens.length) {
        var name = tokens[symbolIndex];
        var value = tokens[valueIndex].trim();
        if (name != null && value != null && getCurrency(name) == null && currencyMap[name] != null) {
          var c = registerCurrency(name, sourceName);
          var r = mpSetFromString(value);
          print("Registering $name with value '$value'");
          var v = usdRate.getValue();
          v = v?.multiply(r!);
          c.setValue(v!);
        }
      }
    }

    super.doLoadRates();
  }

  UnCurrencyProvider(CurrencyManager currencyManager) {
    currencyManager.addProvider(this);
  }
}
