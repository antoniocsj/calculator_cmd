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
  String get attributionLink;

  String get providerName;

  String get rateFilepath;

  String get rateSourceUrl;

  String get sourceName;

  int refreshInterval;

  void setRefreshInterval(int interval, {bool asyncLoad = true}) {
    loaded = false;
    updated();

    this.refreshInterval = interval;
    updateRates(asyncLoad: asyncLoad);
  }

  bool isLoaded() {
    return loaded;
  }

  bool loading;
  bool loaded;
  List<Currency> currencies;
  CurrencyManager currencyManager;

  void clear() {
    FileUtils.remove(rateFilepath);
  }

  Currency registerCurrency(String symbol, String source) {
    Currency currency = currencyManager.addCurrency(symbol, source);
    currencies.add(currency);
    return currency;
  }

  void updateRates({bool asyncLoad = true}) {
    debug("Updating ${sourceName} rates");

    if (loading || loaded) return;

    if (refreshInterval == 0) return;

    debug("Checking ${sourceName} rates");

    if (!fileNeedsUpdate(rateFilepath, refreshInterval)) {
      doLoadRates();
      return;
    }

    debug("Loading ${sourceName} rates");

    loading = true;

    if (asyncLoad) {
      debug("Downloading ${sourceName} rates async");
      downloadFileAsync(rateSourceUrl, rateFilepath, sourceName);
    } else {
      debug("Downloading ${sourceName} rates sync");
      downloadFileSync(rateSourceUrl, rateFilepath, sourceName);
      doLoadRates();
    }
  }

  Currency? getCurrency(String name) {
    return currencyManager.getCurrency(name);
  }

  void doLoadRates() {
    debug("Loaded ${sourceName} rates");
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
  String get rateFilepath {
    return Path.buildFilename(
        Environment.getUserCacheDir(), "calculator", "rms_five.xls");
  }

  String get rateSourceUrl {
    return "https://www.imf.org/external/np/fin/data/rms_five.aspx?tsvflag=Y";
  }

  String get attributionLink {
    return "https://www.imf.org/external/np/fin/data/rms_five.aspx";
  }

  String get providerName {
    return "International Monetary Fund";
  }

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

  void doLoadRates() {
    var nameMap = getNameMap();

    String data;
    try {
      FileUtils.getContents(rateFilepath, data);
    } catch (Error e) {
      warning("Failed to read exchange rates: ${e.message}");
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
              debug("Using IMF rate of ${tokens[valueIndex]} for ${symbol}");
              c = registerCurrency(symbol, sourceName);
              value = value.reciprocal();
              if (c != null) c.setValue(value);
            }
          } else {
            warning("Unknown currency '${tokens[0]}'");
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

// The following commented code is a Vala code for the definition of the OfflineImfCurrencyProvider class.
// public class OfflineImfCurrencyProvider : ImfCurrencyProvider {
// private string source_file;
//
// public OfflineImfCurrencyProvider (CurrencyManager _currency_manager, string source_file)
// {
//   base(_currency_manager);
//   this.source_file = source_file;
// }
//
// protected override void download_file_sync (string uri, string filename, string source)
// {
//
//   var directory = Path.get_dirname (filename);
//   DirUtils.create_with_parents (directory, 0755);
//
//   var dest = File.new_for_path (filename);
//   var source_file = File.new_for_path (source_file);
//   try
//   {
//     var bodyinput = source_file.read ();
//     var output = dest.replace (null, false, FileCreateFlags.REPLACE_DESTINATION);
//     output.splice (bodyinput, OutputStreamSpliceFlags.CLOSE_SOURCE | OutputStreamSpliceFlags.CLOSE_TARGET);
//     loading = false;
//     do_load_rates ();
//     debug ("%s rates updated", source);
//   }
//   catch (Error e)
//   {
//   warning ("Couldn't download %s currency rate file: %s", source, e.message);
//   }
// }
//
// protected override async void download_file_async (string uri, string filename, string source)
// {
//
//   var directory = Path.get_dirname (filename);
//   DirUtils.create_with_parents (directory, 0755);
//
//   var dest = File.new_for_path (filename);
//   var source_file = File.new_for_path (source_file);
//   try
//   {
//     var bodyinput = yield source_file.read_async ();
//     var output = yield dest.replace_async (null, false, FileCreateFlags.REPLACE_DESTINATION, Priority.DEFAULT);
//     yield output.splice_async (bodyinput,
//         OutputStreamSpliceFlags.CLOSE_SOURCE | OutputStreamSpliceFlags.CLOSE_TARGET,
//         Priority.DEFAULT);
//     loading = false;
//     do_load_rates ();
//     debug ("%s rates updated", source);
//   }
//   catch (Error e)
//   {
//   warning ("Couldn't download %s currency rate file: %s", source, e.message);
//   }
// }
// }
//
// The following commented code is a Vala code for the definition of the OfflineImfCurrencyProvider abstract class.
class OfflineImfCurrencyProvider extends ImfCurrencyProvider {
  String sourceFile;

  OfflineImfCurrencyProvider(CurrencyManager currencyManager, this.sourceFile)
      : super(currencyManager);

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
      debug("${source} rates updated");
    } catch (Error e) {
      warning("Couldn't download ${source} currency rate file: ${e.message}");
    }
  }

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
      debug("${source} rates updated");
    } catch (Error e) {
      warning("Couldn't download ${source} currency rate file: ${e.message}");
    }
  }
}

// The following commented code is a Vala code for the definition of the EcbCurrencyProvider class.
// public class EcbCurrencyProvider : AbstractCurrencyProvider {
// public override string rate_filepath { owned get {
// return Path.build_filename (Environment.get_user_cache_dir (), "gnome-calculator", "eurofxref-daily.xml"); } }
//
// public override string rate_source_url { owned get {
// return "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"; } }
//
// public override string attribution_link { owned get {
// return "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"; } }
//
// public override string provider_name { get {
// return _("European Central Bank"); } }
//
// public override string source_name { owned get { return "ECB";} }
//
// protected override void do_load_rates ()
// {
// /* Scale rates to the EUR value */
// var eur_rate = get_currency ("EUR");
// if (eur_rate == null)
// {
// warning ("Cannot use ECB rates as don't have EUR rate");
// return;
// }
//
// /* Set some fixed rates */
// set_ecb_fixed_rate ("BDT", "0.0099", eur_rate);
// set_ecb_fixed_rate ("RSD", "0.0085", eur_rate);
// set_ecb_fixed_rate ("EEK", "0.06391", eur_rate);
// set_ecb_fixed_rate ("CFA", "0.00152449", eur_rate);
//
// Xml.Parser.init ();
// var document = Xml.Parser.read_file (rate_filepath);
// if (document == null)
// {
// warning ("Couldn't parse ECB rate file %s", rate_filepath);
// return;
// }
//
// var xpath_ctx = new Xml.XPath.Context (document);
// if (xpath_ctx == null)
// {
// warning ("Couldn't create XPath context");
// return;
// }
//
// xpath_ctx.register_ns ("xref", "http://www.ecb.int/vocabulary/2002-08-01/eurofxref");
// var xpath_obj = xpath_ctx.eval_expression ("//xref:Cube[@currency][@rate]");
// if (xpath_obj == null)
// {
// warning ("Couldn't create XPath object");
// return;
// }
// var len = (xpath_obj->nodesetval != null) ? xpath_obj->nodesetval->length () : 0;
// for (var i = 0; i < len; i++)
// {
// var node = xpath_obj->nodesetval->item (i);
//
// if (node->type == Xml.ElementType.ELEMENT_NODE)
// set_ecb_rate (node, eur_rate);
//
// /* Avoid accessing removed elements */
// if (node->type != Xml.ElementType.NAMESPACE_DECL)
// node = null;
// }
//
// base.do_load_rates ();
// }
//
// private void set_ecb_rate (Xml.Node node, Currency eur_rate)
// {
// string? name = null, value = null;
//
// for (var attribute = node.properties; attribute != null; attribute = attribute->next)
// {
// var n = (Xml.Node*) attribute;
// if (attribute->name == "currency")
// name = n->get_content ();
// else if (attribute->name == "rate")
// value = n->get_content ();
// }
//
// /* Use data if value and no rate currently defined */
// if (name != null && value != null && get_currency (name) == null)
// {
// debug ("Using ECB rate of %s for %s", value, name);
// var c = register_currency (name, source_name);
// var r = mp_set_from_string (value);
// var v = eur_rate.get_value ();
// v = v.multiply (r);
// c.set_value (v);
// }
// }
//
// private void set_ecb_fixed_rate (string name, string value, Currency eur_rate)
// {
// debug ("Using ECB fixed rate of %s for %s", value, name);
// var c = register_currency (name, source_name + "#fixed");
// var r = mp_set_from_string (value);
// var v = eur_rate.get_value ();
// v = v.divide (r);
// c.set_value (v);
// }
//
// public EcbCurrencyProvider (CurrencyManager _currency_manager)
// {
// Object(currency_manager: _currency_manager);
// _currency_manager.add_provider (this);
// }
// }
//
// The following commented code is a Vala code for the definition of the EcbCurrencyProvider abstract class.
class EcbCurrency extends AbstractCurrencyProvider {
  String get rateFilepath {
    return Path.buildFilename(Environment.getUserCacheDir(), "calculator", "eurofxref-daily.xml");
  }

  String get rateSourceUrl {
    return "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml";
  }

  String get attributionLink {
    return "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml";
  }

  String get providerName {
    return "European Central Bank";
  }

  String get sourceName {
    return "ECB";
  }

  void doLoadRates() {
    var eurRate = getCurrency("EUR");
    if (eurRate == null) {
      warning("Cannot use ECB rates as don't have EUR rate");
      return;
    }

    setEcbFixedRate("BDT", "0.0099", eurRate);
    setEcbFixedRate("RSD", "0.0085", eurRate);
    setEcbFixedRate("EEK", "0.06391", eurRate);
    setEcbFixedRate("CFA", "0.00152449", eurRate);

    var document = XmlParser.readFromFile(rateFilepath);
    if (document == null) {
      warning("Couldn't parse ECB rate file ${rateFilepath}");
      return;
    }

    var xpathCtx = Xml.XPath.Context(document);
    if (xpathCtx == null) {
      warning("Couldn't create XPath context");
      return;
    }

    xpathCtx.registerNs("xref", "http://www.ecb.int/vocabulary/2002-08-01/eurofxref");
    var xpathObj = xpathCtx.evalExpression("//xref:Cube[@currency][@rate]");
    if (xpathObj == null) {
      warning("Couldn't create XPath object");
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
      debug("Using ECB rate of ${value} for ${name}");
      var c = registerCurrency(name, sourceName);
      var r = mpSetFromString(value);
      var v = eurRate.getValue();
      v = v.multiply(r);
      if (c != null) c.setValue(v);
    }
  }

  void setEcbFixedRate(String name, String value, Currency eurRate) {
    debug("Using ECB fixed rate of ${value} for ${name}");
    var c = registerCurrency(name, "${sourceName}#fixed");
    var r = mpSetFromString(value);
    var v = eurRate.getValue();
    v = v.divide(r);
    if (c != null) c.setValue(v);
  }

  EcbCurrency(CurrencyManager currencyManager) {
    currencyManager.addProvider(this);
  }
}

// The following commented code is a Vala code for the definition of the BCCurrencyProvider class.
// public class BCCurrencyProvider : AbstractCurrencyProvider {
// private string currency { get; private set; }
// private string currency_filename { get; private set; }
//
// public override string rate_filepath { owned get {
// return Path.build_filename (Environment.get_user_cache_dir (), "gnome-calculator", "%s.xml".printf (currency_filename)); } }
//
// public override string rate_source_url { owned get {
// return "https://www.bankofcanada.ca/valet/observations/%s/xml?recent=1".printf (currency_filename); } }
//
// public override string attribution_link { owned get {
// return "https://www.bankofcanada.ca/valet/observations/%s/xml?recent=1".printf (currency_filename); } }
//
// public override string provider_name { get {
// return _("Bank of Canada"); } }
//
// public override string source_name { owned get { return "BC-%s".printf (currency);} }
//
// protected override void do_load_rates ()
// {
// Xml.Parser.init ();
// var document = Xml.Parser.read_file (rate_filepath);
// if (document == null)
// {
// warning ("Couldn't parse rate file %s", rate_filepath);
// return;
// }
//
// var xpath_ctx = new Xml.XPath.Context (document);
// if (xpath_ctx == null)
// {
// warning ("Couldn't create XPath context");
// return;
// }
//
// var xpath_obj = xpath_ctx.eval_expression ("//observations/o[last()]/v");
// if (xpath_obj == null)
// {
// warning ("Couldn't create XPath object");
// return;
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
// }
//
// private void set_rate (string name, string value, Currency cad_rate)
// {
// debug ("Using BC rate of %s for %s", value, name);
// var c = register_currency (name, source_name);
// var r = mp_set_from_string (value);
// var v = cad_rate.get_value ();
// v = v.divide (r);
// c.set_value (v);
// }
//
// public BCCurrencyProvider (CurrencyManager _currency_manager, string currency, string currency_filename)
// {
// Object(currency_manager: _currency_manager);
// this.currency = currency;
// this.currency_filename = currency_filename;
// _currency_manager.add_provider (this);
// }
// }
//
// The following commented code is a Vala code for the definition of the BCCurrencyProvider abstract class.
class BcCurrencyProvider extends AbstractCurrencyProvider {
  String currency;
  String currencyFilename;

  String get rateFilepath {
    return Path.buildFilename(Environment.getUserCacheDir(), "calculator", "${currencyFilename}.xml");
  }

  String get rateSourceUrl {
    return "https://www.bankofcanada.ca/valet/observations/${currencyFilename}/xml?recent=1";
  }

  String get attributionLink {
    return "https://www.bankofcanada.ca/valet/observations/${currencyFilename}/xml?recent=1";
  }

  String get providerName {
    return "Bank of Canada";
  }

  String get sourceName {
    return "BC-${currency}";
  }

  void doLoadRates() {
    var document = XmlParser.readFromFile(rateFilepath);
    if (document == null) {
      warning("Couldn't parse rate file ${rateFilepath}");
      return;
    }

    var xpathCtx = Xml.XPath.Context(document);
    if (xpathCtx == null) {
      warning("Couldn't create XPath context");
      return;
    }

    var xpathObj = xpathCtx.evalExpression("//observations/o[last()]/v");
    if (xpathObj == null) {
      warning("Couldn't create XPath object");
      return;
    }

    var node = xpathObj.nodesetval.item(0);
    var rate = node.content;

    var cadRate = getCurrency("CAD");
    if (cadRate == null) {
      warning("Cannot use BC rates as don't have CAD rate");
      return;
    }

    setRate(currency, rate, cadRate);

    super.doLoadRates();
  }

  void setRate(String name, String value, Currency cadRate) {
    debug("Using BC rate of ${value} for ${name}");
    var c = registerCurrency(name, sourceName);
    var r = mpSetFromString(value);
    var v = cadRate.getValue();
    v = v.divide(r);
    if (c != null) c.setValue(v);
  }

  BcCurrencyProvider(CurrencyManager currencyManager, this.currency, this.currencyFilename) {
    currencyManager.addProvider(this);
  }
}

// The following commented code is a Vala code for the definition of the UnCurrencyProvider class.
// public class UnCurrencyProvider : AbstractCurrencyProvider {
// public override string rate_filepath { owned get {
// return Path.build_filename (Environment.get_user_cache_dir (), "gnome-calculator", "un-daily.xls"); } }
//
// public override string rate_source_url { owned get {
// return "https://treasury.un.org/operationalrates/xsql2CSV.php"; } }
//
// public override string attribution_link { owned get {
// return "https://treasury.un.org/operationalrates/OperationalRates.php"; } }
//
// public override string provider_name { get {
// return _("United Nations Treasury"); } }
//
// public override string source_name { owned get { return "UNT";} }
//
// private HashTable <string, string> get_currency_map () {
// HashTable <string, string> name_map = new HashTable <string, string> (str_hash, str_equal);
// name_map.insert ("JMD", "Jamaican Dollar");
// name_map.insert ("ARS", "Argentine Peso");
// name_map.insert ("UAH", "Ukrainian Hryvnia");
// name_map.insert ("NGN", "Nigerian Naira");
// name_map.insert ("VND", "Vietnamese Dong");
// return name_map;
// }
//
// protected override void do_load_rates ()
// {
// var currency_map = get_currency_map ();
// string data;
// try
// {
// FileUtils.get_contents (rate_filepath, out data);
// }
// catch (Error e)
// {
// warning ("Failed to read exchange rates: %s", e.message);
// return;
// }
//
// var lines = data.split ("\r\n", 0);
//
// var in_data = false;
// var usd_rate = get_currency ("USD");
// if (usd_rate == null)
// {
// warning ("Cannot use UN rates as don't have USD rate");
// return;
// }
// foreach (var line in lines)
// {
// line = line.chug ();
//
// /* Start after first blank line, stop on next */
// if (line == "")
// {
// if (!in_data)
// {
// in_data = true;
// continue;
// }
// else
// break;
// }
// if (!in_data)
// continue;
//
// var tokens = line.split ("\t", 0);
// int value_index = 4;
// int symbol_index = 2;
// if (value_index <= tokens.length && symbol_index <= tokens.length)
// {
// var name = tokens [symbol_index];
// var value = tokens [value_index].chug ();
// if (name != null && value != null && get_currency (name) == null && currency_map.lookup (name) != null) {
// var c = register_currency (name, source_name);
// var r = mp_set_from_string (value);
// debug ("Registering %s with value '%s'\r\n", name, value);
// var v = usd_rate.get_value ();
// v = v.multiply (r);
// c.set_value (v);
// }
// }
// }
// base.do_load_rates ();
// }
//
// public UnCurrencyProvider (CurrencyManager _currency_manager)
// {
// Object(currency_manager: _currency_manager);
// _currency_manager.add_provider (this);
// }
// }
//
// The following commented code is a Vala code for the definition of the UnCurrencyProvider abstract class.
class UnCurrencyProvider extends AbstractCurrencyProvider {
  String get rateFilepath {
    return Path.buildFilename(Environment.getUserCacheDir(), "calculator", "un-daily.xls");
  }

  String get rateSourceUrl {
    return "https://treasury.un.org/operationalrates/xsql2CSV.php";
  }

  String get attributionLink {
    return "https://treasury.un.org/operationalrates/OperationalRates.php";
  }

  String get providerName {
    return "United Nations Treasury";
  }

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

  void doLoadRates() {
    var currencyMap = getCurrencyMap();
    String data;
    try {
      FileUtils.getContents(rateFilepath, data);
    } catch (Error e) {
      warning("Failed to read exchange rates: ${e.message}");
      return;
    }

    var lines = data.split("\r\n");

    var inData = false;
    var usdRate = getCurrency("USD");
    if (usdRate == null) {
      warning("Cannot use UN rates as don't have USD rate");
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
          debug("Registering ${name} with value '${value}'");
          var v = usdRate.getValue();
          v = v.multiply(r);
          c.setValue(v);
        }
      }
    }

    super.doLoadRates();
  }

  UnCurrencyProvider(CurrencyManager currencyManager) {
    currencyManager.addProvider(this);
  }
}
