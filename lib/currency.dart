import 'package:calculator/number.dart';

CurrencyManager? defaultCurrencyManager;

class Currency {
  Number? value;

  final String _name;
  String get name => _name;

  final String _displayName;
  String get displayName => _displayName;

  final String _symbol;
  String get symbol => _symbol;

  late String source;

  Currency(this._name, this._displayName, this._symbol);

  void setValue(Number value) {
    this.value = value;
  }

  Number? getValue() {
    return value;
  }
}

class CurrencyManager {
  List<Currency> currencies = [];
  List<CurrencyProvider> providers = [];

  int _refreshInterval = 0;
  int get refreshInterval => _refreshInterval;
  set refreshInterval(int value) {
    _refreshInterval = value;
  }

  bool loaded = false;

  void Function()? updated;

  List<String> getProviderLinks() {
    List<String> links = [];
    for (var p in providers) {
      links.add('<a href="${p.attributionLink}">${p.providerName}</a>');
    }
    return links;
  }

  void addProvider(CurrencyProvider provider) {
    providers.add(provider);
  }

  void refreshSync() {
    loaded = false;
    for (var p in providers) {
      p.setRefreshInterval(_refreshInterval, false);
    }
  }

  void refreshAsync() {
    loaded = false;
    for (var p in providers) {
      p.setRefreshInterval(_refreshInterval, true);
    }
  }

  static CurrencyManager getDefault({bool asyncLoad = true, bool defaultProviders = true}) {
    if (defaultCurrencyManager != null) {
      return defaultCurrencyManager!;
    }

    defaultCurrencyManager = CurrencyManager();
    defaultCurrencyManager!.currencies.add(Currency("AED", "UAE Dirham", "إ.د"));
    defaultCurrencyManager!.currencies.add(Currency("ARS", "Argentine Peso", "\$"));
    defaultCurrencyManager!.currencies.add(Currency("AUD", "Australian Dollar", "\$"));
    defaultCurrencyManager!.currencies.add(Currency("BDT", "Bangladeshi Taka", "৳"));
    defaultCurrencyManager!.currencies.add(Currency("BGN", "Bulgarian Lev", "лв"));
    defaultCurrencyManager!.currencies.add(Currency("BHD", "Bahraini Dinar", ".ب.د"));
    defaultCurrencyManager!.currencies.add(Currency("BND", "Brunei Dollar", "\$"));
    defaultCurrencyManager!.currencies.add(Currency("BRL", "Brazilian Real", "R\$"));
    defaultCurrencyManager!.currencies.add(Currency("BWP", "Botswana Pula", "P"));
    defaultCurrencyManager!.currencies.add(Currency("CAD", "Canadian Dollar", "\$"));
    defaultCurrencyManager!.currencies.add(Currency("CFA", "CFA Franc", "Fr"));
    defaultCurrencyManager!.currencies.add(Currency("CHF", "Swiss Franc", "Fr"));
    defaultCurrencyManager!.currencies.add(Currency("CLP", "Chilean Peso", "\$"));
    defaultCurrencyManager!.currencies.add(Currency("CNY", "Chinese Yuan", "¥"));
    defaultCurrencyManager!.currencies.add(Currency("COP", "Colombian Peso", "\$"));
    defaultCurrencyManager!.currencies.add(Currency("CZK", "Czech Koruna", "Kč"));
    defaultCurrencyManager!.currencies.add(Currency("DKK", "Danish Krone", "kr"));
    defaultCurrencyManager!.currencies.add(Currency("DZD", "Algerian Dinar", "ج.د"));
    defaultCurrencyManager!.currencies.add(Currency("EEK", "Estonian Kroon", "KR"));
    defaultCurrencyManager!.currencies.add(Currency("EUR", "Euro", "€"));
    defaultCurrencyManager!.currencies.add(Currency("GBP", "British Pound Sterling", "£"));
    defaultCurrencyManager!.currencies.add(Currency("HKD", "Hong Kong Dollar", "\$"));
    defaultCurrencyManager!.currencies.add(Currency("HRK", "Croatian Kuna", "kn"));
    defaultCurrencyManager!.currencies.add(Currency("HUF", "Hungarian Forint", "Ft"));
    defaultCurrencyManager!.currencies.add(Currency("IDR", "Indonesian Rupiah", "Rp"));
    defaultCurrencyManager!.currencies.add(Currency("ILS", "Israeli New Shekel", "₪"));
    defaultCurrencyManager!.currencies.add(Currency("INR", "Indian Rupee", "₹"));
    defaultCurrencyManager!.currencies.add(Currency("IRR", "Iranian Rial", "﷼"));
    defaultCurrencyManager!.currencies.add(Currency("ISK", "Icelandic Krona", "kr"));
    defaultCurrencyManager!.currencies.add(Currency("JPY", "Japanese Yen", "¥"));
    defaultCurrencyManager!.currencies.add(Currency("JMD", "Jamaican Dollar", "\$"));
    defaultCurrencyManager!.currencies.add(Currency("KRW", "South Korean Won", "₩"));
    defaultCurrencyManager!.currencies.add(Currency("KWD", "Kuwaiti Dinar", "ك.د"));
    defaultCurrencyManager!.currencies.add(Currency("KZT", "Kazakhstani Tenge", "₸"));
    defaultCurrencyManager!.currencies.add(Currency("LKR", "Sri Lankan Rupee", "Rs"));
    defaultCurrencyManager!.currencies.add(Currency("LYD", "Libyan Dinar", "د.ل"));
    defaultCurrencyManager!.currencies.add(Currency("MUR", "Mauritian Rupee", "Rs"));
    defaultCurrencyManager!.currencies.add(Currency("MXN", "Mexican Peso", "\$"));
    defaultCurrencyManager!.currencies.add(Currency("MYR", "Malaysian Ringgit", "RM"));
    defaultCurrencyManager!.currencies.add(Currency("NGN", "Nigerian Naira", "₦"));
    defaultCurrencyManager!.currencies.add(Currency("NOK", "Norwegian Krone", "kr"));
    defaultCurrencyManager!.currencies.add(Currency("NPR", "Nepalese Rupee", "Rs"));
    defaultCurrencyManager!.currencies.add(Currency("NZD", "New Zealand Dollar", "\$"));
    defaultCurrencyManager!.currencies.add(Currency("OMR", "Omani Rial", "ع.ر."));
    defaultCurrencyManager!.currencies.add(Currency("PEN", "Peruvian Nuevo Sol", "S/."));
    defaultCurrencyManager!.currencies.add(Currency("PHP", "Philippine Peso", "₱"));
    defaultCurrencyManager!.currencies.add(Currency("PKR", "Pakistani Rupee", "Rs"));
    defaultCurrencyManager!.currencies.add(Currency("PLN", "Polish Zloty", "zł"));
    defaultCurrencyManager!.currencies.add(Currency("QAR", "Qatari Riyal", "ق.ر"));
    defaultCurrencyManager!.currencies.add(Currency("RON", "New Romanian Leu", "L"));
    defaultCurrencyManager!.currencies.add(Currency("RUB", "Russian Rouble", "руб."));
    defaultCurrencyManager!.currencies.add(Currency("SAR", "Saudi Riyal", "س.ر"));
    defaultCurrencyManager!.currencies.add(Currency("RSD", "Serbian Dinar", "дин"));
    defaultCurrencyManager!.currencies.add(Currency("SEK", "Swedish Krona", "kr"));
    defaultCurrencyManager!.currencies.add(Currency("SGD", "Singapore Dollar", "\$"));
    defaultCurrencyManager!.currencies.add(Currency("THB", "Thai Baht", "฿"));
    defaultCurrencyManager!.currencies.add(Currency("TND", "Tunisian Dinar", "ت.د"));
    defaultCurrencyManager!.currencies.add(Currency("TRY", "Turkish Lira", "₺"));
    defaultCurrencyManager!.currencies.add(Currency("TTD", "T&T Dollar (TTD)", "\$"));
    defaultCurrencyManager!.currencies.add(Currency("TWD", "New Taiwan Dollar", "NT\$"));
    defaultCurrencyManager!.currencies.add(Currency("UAH", "Ukrainian Hryvnia", "₴"));
    defaultCurrencyManager!.currencies.add(Currency("USD", "US Dollar", "\$"));
    defaultCurrencyManager!.currencies.add(Currency("UYU", "Uruguayan Peso", "\$"));
    defaultCurrencyManager!.currencies.add(Currency("VND", "Vietnamese Dong", "₫"));
    defaultCurrencyManager!.currencies.add(Currency("ZAR", "South African Rand", "R"));

    if (defaultProviders) {
      ImfCurrencyProvider(defaultCurrencyManager!);
      EcbCurrencyProvider(defaultCurrencyManager!);
      BCCurrencyProvider(defaultCurrencyManager!, "TWD", "fxtwdcad");
      UnCurrencyProvider(defaultCurrencyManager!);
      defaultCurrencyManager!.initializeProviders(asyncLoad);
    }

    return defaultCurrencyManager!;
  }

  void update() {
    loaded = false;
    for (var p in providers) {
      if (p.isLoaded()) {
        loaded = true;
        break;
      }
    }
    updated?.call();
  }

  void initializeProviders({bool asyncLoad = true}) {
    for (var p in providers) {
      p.updated = () {
        update();
      };
      p.updateRates(asyncLoad);
    }
  }

  List<Currency> getCurrencies() {
    List<Currency> r = [];
    for (var c in currencies) {
      r.add(c);
    }
    return r;
  }

  Currency? getCurrency(String name) {
    for (var c in currencies) {
      if (name == c.name) {
        var value = c.getValue();
        if (value == null || value.isNegative() || value.isZero()) {
          return null;
        } else {
          return c;
        }
      }
    }

    return null;
  }

  Number? getValue(String currency) {
    var c = getCurrency(currency);
    if (c != null) {
      return c.getValue();
    } else {
      return null;
    }
  }

  Currency addCurrency(String shortName, String source) {
    for (var c in currencies) {
      if (c.name == shortName) {
        c.source = source;
        return c;
      }
    }

    print("Currency $shortName is not in the currency table");
    var c = Currency(shortName, shortName, shortName);
    c.source = source;
    currencies.add(c);
    return c;
  }

  List<Currency> currenciesEligibleForAutocompletionForText(String displayText) {
    List<Currency> eligibleCurrencies = [];
    String displayTextCaseInsensitive = displayText.toUpperCase();
    for (var currency in currencies) {
      String currencyNameCaseInsensitive = currency.name.toUpperCase();
      if (currencyNameCaseInsensitive.startsWith(displayTextCaseInsensitive)) {
        eligibleCurrencies.add(currency);
      }
    }
    return eligibleCurrencies;
  }
}
