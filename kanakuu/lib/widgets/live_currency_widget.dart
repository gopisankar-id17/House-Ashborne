import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../services/currency_service.dart';

class LiveCurrencyWidget extends StatefulWidget {
  const LiveCurrencyWidget({Key? key}) : super(key: key);

  @override
  _LiveCurrencyWidgetState createState() => _LiveCurrencyWidgetState();
}

class _LiveCurrencyWidgetState extends State<LiveCurrencyWidget> {
  final CurrencyService _currencyService = CurrencyService();
  String _selectedCurrency = 'USD';
  String _currencySymbol = '\$';
  double _exchangeRate = 1.0;
  DateTime? _lastUpdate;
  bool _isLoading = true;
  bool _isRefreshing = false;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadCurrencyInfo();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Auto-refresh every 30 minutes
    _autoRefreshTimer = Timer.periodic(Duration(minutes: 30), (timer) {
      if (mounted) {
        _refreshRatesQuietly();
      }
    });
  }

  Future<void> _refreshRatesQuietly() async {
    try {
      await _currencyService.forceRefreshRates();
      await _loadCurrencyInfo();
    } catch (e) {
      print('Auto-refresh failed: $e');
    }
  }

  Future<void> _loadCurrencyInfo() async {
    try {
      final currency = await _currencyService.getSelectedCurrency();
      final symbol = await _currencyService.getCurrencySymbol();
      final rate = await _currencyService.getExchangeRate();
      final lastUpdate = await _currencyService.getLastUpdateTime();

      if (mounted) {
        setState(() {
          _selectedCurrency = currency;
          _currencySymbol = symbol;
          _exchangeRate = rate;
          _lastUpdate = lastUpdate;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading currency info: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshRates() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await _currencyService.forceRefreshRates();
      await _loadCurrencyInfo();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exchange rates updated'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update rates'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  String _formatLastUpdate() {
    if (_lastUpdate == null) return 'Never updated';
    
    final now = DateTime.now();
    final difference = now.difference(_lastUpdate!);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(_lastUpdate!);
    }
  }

  Color _getUpdateStatusColor() {
    if (_lastUpdate == null) return Colors.red;
    
    final now = DateTime.now();
    final difference = now.difference(_lastUpdate!);
    
    if (difference.inHours < 1) {
      return Colors.green;
    } else if (difference.inHours < 6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFF2A2D3A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Loading currency...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF2A2D3A),
            Color(0xFF34384A),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Currency flag and code
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CurrencyService.supportedCurrencies[_selectedCurrency]?['flag'] ?? '🌍',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 6),
                Text(
                  _selectedCurrency,
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 12),
          
          // Exchange rate info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      '1 USD = ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$_currencySymbol${_exchangeRate.toStringAsFixed(_selectedCurrency == 'JPY' ? 0 : 4)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _getUpdateStatusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      _formatLastUpdate(),
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Refresh button
          GestureDetector(
            onTap: _isRefreshing ? null : _refreshRates,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isRefreshing 
                    ? Colors.grey.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _isRefreshing
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    )
                  : Icon(
                      Icons.refresh,
                      color: Colors.orange,
                      size: 16,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}