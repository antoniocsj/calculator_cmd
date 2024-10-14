import 'dart:async';
import 'package:calculator/number.dart';
import 'package:calculator/currency_provider.dart';

CurrencyManager? defaultCurrencyManager;

class Currency {
  final String name;
  final String displayName;
  final String symbol;
  Number? value;
  String source;

  Currency(this.name, this.displayName, this.symbol, {this.source = ''});

  void setValue(Number value) {
    this.value = value;
  }

  Number? getValue() {
    return value;
  }
}

class CurrencyManager {
  final List<Currency> currencies = [];
  final List<CurrencyProvider> providers = [];
  final StreamController<void> _updatedController = StreamController<void>.broadcast();
  bool loaded = false;
  int refreshInterval = 60;

  // Vala code:
  // public signal void updated ();
  // equivalent Dart code:
  Stream<void> get updated => _updatedController.stream;

  void addProvider(CurrencyProvider provider) {
    providers.add(provider);
  }

  void refreshSync() {
    loaded = false;
    for (var provider in providers) {
      provider.setRefreshInterval(refreshInterval, false);
    }
  }

  void refreshAsync() {
    loaded = false;
    for (var provider in providers) {
      provider.setRefreshInterval(refreshInterval, true);
    }
  }

  static CurrencyManager getDefault({bool asyncLoad = false, bool defaultProviders = true}) {
    if (defaultCurrencyManager != null) {
      return defaultCurrencyManager!;
    }

    defaultCurrencyManager = CurrencyManager();
    defaultCurrencyManager!._initializeDefaultCurrencies();

    if (defaultProviders) {
      defaultCurrencyManager!._initializeDefaultProviders(asyncLoad);
    }

    return defaultCurrencyManager!;
  }

  void _initializeDefaultCurrencies() {
    defaultCurrencyManager?.currencies.addAll([
      Currency('AED', 'UAE Dirham', 'إ.د'),
      Currency('ARS', 'Argentine Peso', '\$'),
      Currency('AUD', 'Australian Dollar', '\$'),
      Currency('BDT', 'Bangladeshi Taka', '৳'),
      Currency('BGN', 'Bulgarian Lev', 'лв'),
      Currency('BHD', 'Bahraini Dinar', '.ب.د'),
      Currency('BND', 'Brunei Dollar', '\$'),
      Currency('BRL', 'Brazilian Real', 'R\$'),
      Currency('BWP', 'Botswana Pula', 'P'),
      Currency('CAD', 'Canadian Dollar', '\$'),
      Currency('CFA', 'CFA Franc', 'Fr'),
      Currency('CHF', 'Swiss Franc', 'Fr'),
      Currency('CLP', 'Chilean Peso', '\$'),
      Currency('CNY', 'Chinese Yuan', '¥'),
      Currency('COP', 'Colombian Peso', '\$'),
      Currency('CZK', 'Czech Koruna', 'Kč'),
      Currency('DKK', 'Danish Krone', 'kr'),
      Currency('DZD', 'Algerian Dinar', 'ج.د'),
      Currency('EEK', 'Estonian Kroon', 'KR'),
      Currency('EUR', 'Euro', '€'),
      Currency('GBP', 'British Pound Sterling', '£'),
      Currency('HKD', 'Hong Kong Dollar', '\$'),
      Currency('HRK', 'Croatian Kuna', 'kn'),
      Currency('HUF', 'Hungarian Forint', 'Ft'),
      Currency('IDR', 'Indonesian Rupiah', 'Rp'),
      Currency('ILS', 'Israeli New Shekel', '₪'),
      Currency('INR', 'Indian Rupee', '₹'),
      Currency('IRR', 'Iranian Rial', '﷼'),
      Currency('ISK', 'Icelandic Krona', 'kr'),
      Currency('JPY', 'Japanese Yen', '¥'),
      Currency('JMD', 'Jamaican Dollar', '\$'),
      Currency('KRW', 'South Korean Won', '₩'),
      Currency('KWD', 'Kuwaiti Dinar', 'ك.د'),
      Currency('KZT', 'Kazakhstani Tenge', '₸'),
      Currency('LKR', 'Sri Lankan Rupee', 'Rs'),
      Currency('LYD', 'Libyan Dinar', 'د.ل'),
      Currency('MUR', 'Mauritian Rupee', 'Rs'),
      Currency('MXN', 'Mexican Peso', '\$'),
      Currency('MYR', 'Malaysian Ringgit', 'RM'),
      Currency('NGN', 'Nigerian Naira', '₦'),
      Currency('NOK', 'Norwegian Krone', 'kr'),
      Currency('NPR', 'Nepalese Rupee', 'Rs'),
      Currency('NZD', 'New Zealand Dollar', '\$'),
      Currency('OMR', 'Omani Rial', 'ع.ر.'),
      Currency('PEN', 'Peruvian Nuevo Sol', 'S/.'),
      Currency('PHP', 'Philippine Peso', '₱'),
      Currency('PKR', 'Pakistani Rupee', 'Rs'),
      Currency('PLN', 'Polish Zloty', 'zł'),
      Currency('QAR', 'Qatari Riyal', 'ق.ر'),
      Currency('RON', 'New Romanian Leu', 'L'),
      Currency('RUB', 'Russian Rouble', 'руб.'),
      Currency('SAR', 'Saudi Riyal', 'س.ر'),
      Currency('RSD', 'Serbian Dinar', 'дин'),
      Currency('SEK', 'Swedish Krona', 'kr'),
      Currency('SGD', 'Singapore Dollar', '\$'),
      Currency('THB', 'Thai Baht', '฿'),
      Currency('TND', 'Tunisian Dinar', 'ت.د'),
      Currency('TRY', 'Turkish Lira', '₺'),
      Currency('TTD', 'T&T Dollar (TTD)', '\$'),
      Currency('TWD', 'New Taiwan Dollar', 'NT\$'),
      Currency('UAH', 'Ukrainian Hryvnia', '₴'),
      Currency('USD', 'US Dollar', '\$'),
      Currency('UYU', 'Uruguayan Peso', '\$'),
      Currency('VND', 'Vietnamese Dong', '₫'),
      Currency('ZAR', 'South African Rand', 'R'),
    ]);
  }

  void _initializeDefaultProviders(bool asyncLoad) {
    defaultCurrencyManager?.addProvider(ImfCurrencyProvider(defaultCurrencyManager!));
    // addProvider(EcbCurrencyProvider(defaultCurrencyManager!));
    // addProvider(BCCurrencyProvider(defaultCurrencyManager!, 'TWD', 'fxtwdcad'));
    // addProvider(UnCurrencyProvider(defaultCurrencyManager!));
    defaultCurrencyManager?.initializeProviders(asyncLoad);
  }

  void update() {
    loaded = false;
    for (var provider in providers) {
      if (provider.isLoaded()) {
        loaded = true;
        break;
      }
    }
    // Vala code:
    // updated(); // a call to the signal updated
    // equivalent Dart code:
    _updatedController.add(null);
  }

  void initializeProviders([bool asyncLoad = false]) {
    for (var provider in providers) {
      // Vala code:
      // p.updated.connect ( () => { update (); });
      // equivalent Dart code:
      // provider.updated.listen((_) {
      //   update();
      // });
      // provider.updateRates(asyncLoad: asyncLoad);
      provider.updateRates2();
    }
  }

  List<Currency> getCurrencies() {
    return List.from(currencies);
  }

  Currency? getCurrency(String name) {
    for (var currency in currencies) {
      if (name == currency.name) {
        var value = currency.getValue();
        if (value == null || value.isNegative() || value.isZero()) {
          return null;
        } else {
          return currency;
        }
      }
    }
    return null;
  }

  Number? getValue(String currency) {
    var c = getCurrency(currency);
    return c?.getValue();
  }

  Currency addCurrency(String shortName, String source) {
    for (var currency in currencies) {
      if (currency.name == shortName) {
        currency.source = source;
        return currency;
      }
    }
    print('Currency $shortName is not in the currency table');
    var currency = Currency(shortName, shortName, shortName, source: source);
    currencies.add(currency);
    return currency;
  }

  List<Currency> currenciesEligibleForAutocompletionForText(String displayText) {
    var displayTextCaseInsensitive = displayText.toUpperCase();
    return currencies.where((currency) {
      var currencyNameCaseInsensitive = currency.name.toUpperCase();
      return currencyNameCaseInsensitive.startsWith(displayTextCaseInsensitive);
    }).toList();
  }
}
