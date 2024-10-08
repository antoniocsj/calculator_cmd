import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
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
