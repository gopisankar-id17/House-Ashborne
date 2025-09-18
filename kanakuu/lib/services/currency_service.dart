// currency_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exchange_rate_service.dart';

class CurrencyService {
  static const String _currencyKey = 'selected_currency';
  final ExchangeRateService _exchangeRateService = ExchangeRateService();
  
  // Supported currencies with their symbols and names
  static const Map<String, Map<String, dynamic>> supportedCurrencies = {
    'USD': {
      'symbol': '\$',
      'name': 'US Dollar',
      'code': 'USD',
      'flag': '🇺🇸',
    },
    'EUR': {
      'symbol': '€',
      'name': 'Euro',
      'code': 'EUR',
      'flag': '🇪🇺',
    },
    'GBP': {
      'symbol': '£',
      'name': 'British Pound',
      'code': 'GBP',
      'flag': '🇬🇧',
    },
    'INR': {
      'symbol': '₹',
      'name': 'Indian Rupee',
      'code': 'INR',
      'flag': '🇮🇳',
    },
    'JPY': {
      'symbol': '¥',
      'name': 'Japanese Yen',
      'code': 'JPY',
      'flag': '🇯🇵',
    },
    'CAD': {
      'symbol': 'C\$',
      'name': 'Canadian Dollar',
      'code': 'CAD',
      'flag': '🇨🇦',
    },
    'AUD': {
      'symbol': 'A\$',
      'name': 'Australian Dollar',
      'code': 'AUD',
      'flag': '🇦🇺',
    },
    'CHF': {
      'symbol': 'CHF',
      'name': 'Swiss Franc',
      'code': 'CHF',
      'flag': '🇨🇭',
    },
    'CNY': {
      'symbol': '¥',
      'name': 'Chinese Yuan',
      'code': 'CNY',
      'flag': '🇨🇳',
    },
    'BRL': {
      'symbol': 'R\$',
      'name': 'Brazilian Real',
      'code': 'BRL',
      'flag': '🇧🇷',
    },
  };

  // Exchange rates (you can integrate with a real API later)
  static const Map<String, double> exchangeRates = {
    'USD': 1.0,      // Base currency
    'EUR': 0.85,
    'GBP': 0.73,
    'INR': 83.12,
    'JPY': 110.0,
    'CAD': 1.25,
    'AUD': 1.35,
    'CHF': 0.92,
    'CNY': 6.45,
    'BRL': 5.20,
  };

  // Save selected currency
  Future<void> saveCurrency(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currencyCode);
  }

  // Get selected currency (default to USD)
  Future<String> getSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? 'USD';
  }

  // Get currency symbol
  Future<String> getCurrencySymbol() async {
    final currency = await getSelectedCurrency();
    return supportedCurrencies[currency]?['symbol'] ?? '\$';
  }

  // Get currency info
  Future<Map<String, dynamic>> getCurrencyInfo() async {
    final currency = await getSelectedCurrency();
    return supportedCurrencies[currency] ?? supportedCurrencies['USD']!;
  }

  // Convert amount from USD to selected currency
  Future<double> convertFromUSD(double usdAmount) async {
    final currency = await getSelectedCurrency();
    final rate = await _exchangeRateService.getExchangeRate(currency);
    return usdAmount * rate;
  }

  // Convert amount to USD from selected currency
  Future<double> convertToUSD(double amount) async {
    final currency = await getSelectedCurrency();
    final rate = await _exchangeRateService.getExchangeRate(currency);
    return amount / rate;
  }

  // Format amount with currency symbol
  Future<String> formatAmount(double amount) async {
    final symbol = await getCurrencySymbol();
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  // Get exchange rate for selected currency
  Future<double> getExchangeRate() async {
    final currency = await getSelectedCurrency();
    return await _exchangeRateService.getExchangeRate(currency);
  }

  // Get current exchange rates
  Future<Map<String, double>> getCurrentRates() async {
    return await _exchangeRateService.getCurrentRates();
  }

  // Get last update time for exchange rates
  Future<DateTime?> getLastUpdateTime() async {
    return await _exchangeRateService.getLastUpdateTime();
  }

  // Force refresh exchange rates
  Future<void> forceRefreshRates() async {
    await _exchangeRateService.forceRefresh();
  }

  // Convert between any two currencies
  Future<double> convertBetweenCurrencies(double amount, String fromCurrency, String toCurrency) async {
    return await _exchangeRateService.convertCurrency(amount, fromCurrency, toCurrency);
  }
}

// Currency Selection Dialog Widget

class CurrencySelectionDialog extends StatefulWidget {
  final String currentCurrency;
  final Function(String) onCurrencySelected;

  const CurrencySelectionDialog({
    Key? key,
    required this.currentCurrency,
    required this.onCurrencySelected,
  }) : super(key: key);

  @override
  _CurrencySelectionDialogState createState() => _CurrencySelectionDialogState();
}

class _CurrencySelectionDialogState extends State<CurrencySelectionDialog> {
  String selectedCurrency = '';

  @override
  void initState() {
    super.initState();
    selectedCurrency = widget.currentCurrency;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF2A2D3A),
      title: Text(
        'Select Currency',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: CurrencyService.supportedCurrencies.length,
          itemBuilder: (context, index) {
            final currencyCode = CurrencyService.supportedCurrencies.keys.elementAt(index);
            final currencyData = CurrencyService.supportedCurrencies[currencyCode]!;
            final isSelected = selectedCurrency == currencyCode;

            return Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFFFF6B35).withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? Border.all(color: Color(0xFFFF6B35), width: 1) : null,
              ),
              child: ListTile(
                leading: Text(
                  currencyData['flag'],
                  style: TextStyle(fontSize: 24),
                ),
                title: Text(
                  currencyData['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  '${currencyData['code']} (${currencyData['symbol']})',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: Color(0xFFFF6B35),
                      )
                    : null,
                onTap: () {
                  setState(() {
                    selectedCurrency = currencyCode;
                  });
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF9CA3AF)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onCurrencySelected(selectedCurrency);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF6B35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Select',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}