import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRateService {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest/USD';
  static const String _ratesKey = 'exchange_rates';
  static const String _lastUpdateKey = 'rates_last_update';
  static const Duration _cacheValidityDuration = Duration(hours: 1);

  // Fallback rates in case API is not available
  static const Map<String, double> _fallbackRates = {
    'USD': 1.0,
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

  /// Fetch current exchange rates from API
  Future<Map<String, double>> fetchCurrentRates() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = Map<String, double>.from(data['rates']);
        
        // Add USD as base currency
        rates['USD'] = 1.0;
        
        // Cache the rates
        await _cacheRates(rates);
        
        return rates;
      } else {
        print('API Error: ${response.statusCode}');
        return await _getCachedRates();
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
      return await _getCachedRates();
    }
  }

  /// Get cached rates or fallback rates
  Future<Map<String, double>> _getCachedRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedRatesString = prefs.getString(_ratesKey);
      final lastUpdateString = prefs.getString(_lastUpdateKey);

      if (cachedRatesString != null && lastUpdateString != null) {
        final lastUpdate = DateTime.parse(lastUpdateString);
        final now = DateTime.now();

        // Check if cached data is still valid (less than 1 hour old)
        if (now.difference(lastUpdate) < _cacheValidityDuration) {
          final cachedRates = Map<String, double>.from(json.decode(cachedRatesString));
          return cachedRates;
        }
      }
    } catch (e) {
      print('Error getting cached rates: $e');
    }

    // Return fallback rates if no valid cache
    return Map<String, double>.from(_fallbackRates);
  }

  /// Cache exchange rates locally
  Future<void> _cacheRates(Map<String, double> rates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_ratesKey, json.encode(rates));
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching rates: $e');
    }
  }

  /// Get exchange rate for a specific currency
  Future<double> getExchangeRate(String currencyCode) async {
    final rates = await getCurrentRates();
    return rates[currencyCode] ?? 1.0;
  }

  /// Get current rates (cached or fresh)
  Future<Map<String, double>> getCurrentRates() async {
    final cachedRates = await _getCachedRates();
    final lastUpdateString = (await SharedPreferences.getInstance()).getString(_lastUpdateKey);
    
    if (lastUpdateString != null) {
      final lastUpdate = DateTime.parse(lastUpdateString);
      final now = DateTime.now();
      
      // If cache is older than 1 hour, try to fetch new rates in background
      if (now.difference(lastUpdate) >= _cacheValidityDuration) {
        _fetchAndUpdateRatesInBackground();
      }
    }
    
    return cachedRates;
  }

  /// Fetch rates in background without blocking UI
  void _fetchAndUpdateRatesInBackground() {
    fetchCurrentRates().then((rates) {
      print('Background update: Exchange rates refreshed');
    }).catchError((error) {
      print('Background update failed: $error');
    });
  }

  /// Convert amount from one currency to another
  Future<double> convertCurrency(double amount, String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return amount;
    
    final rates = await getCurrentRates();
    final fromRate = rates[fromCurrency] ?? 1.0;
    final toRate = rates[toCurrency] ?? 1.0;
    
    // Convert to USD first, then to target currency
    final usdAmount = amount / fromRate;
    return usdAmount * toRate;
  }

  /// Get the last update time of exchange rates
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateString = prefs.getString(_lastUpdateKey);
      if (lastUpdateString != null) {
        return DateTime.parse(lastUpdateString);
      }
    } catch (e) {
      print('Error getting last update time: $e');
    }
    return null;
  }

  /// Check if rates need update
  Future<bool> needsUpdate() async {
    final lastUpdate = await getLastUpdateTime();
    if (lastUpdate == null) return true;
    
    final now = DateTime.now();
    return now.difference(lastUpdate) >= _cacheValidityDuration;
  }

  /// Force refresh rates
  Future<Map<String, double>> forceRefresh() async {
    return await fetchCurrentRates();
  }
}