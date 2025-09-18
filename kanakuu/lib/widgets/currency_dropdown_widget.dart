import 'package:flutter/material.dart';
import '../services/currency_service.dart';

class CurrencyDropdownWidget extends StatefulWidget {
  final Function(String)? onCurrencyChanged;
  
  const CurrencyDropdownWidget({
    Key? key,
    this.onCurrencyChanged,
  }) : super(key: key);

  @override
  _CurrencyDropdownWidgetState createState() => _CurrencyDropdownWidgetState();
}

class _CurrencyDropdownWidgetState extends State<CurrencyDropdownWidget> {
  final CurrencyService _currencyService = CurrencyService();
  String _selectedCurrency = 'USD';
  
  @override
  void initState() {
    super.initState();
    _loadSelectedCurrency();
  }

  Future<void> _loadSelectedCurrency() async {
    final currency = await _currencyService.getSelectedCurrency();
    if (mounted) {
      setState(() {
        _selectedCurrency = currency;
      });
    }
  }

  Future<void> _onCurrencyChanged(String? newCurrency) async {
    if (newCurrency != null && newCurrency != _selectedCurrency) {
      setState(() {
        _selectedCurrency = newCurrency;
      });
      
      // Save the selected currency
      await _currencyService.saveCurrency(newCurrency);
      
      // Call the callback if provided
      if (widget.onCurrencyChanged != null) {
        widget.onCurrencyChanged!(newCurrency);
      }
      
      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Currency changed to $newCurrency'),
            backgroundColor: Color(0xFFFF6B35),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFFF6B35).withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCurrency,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFFFF6B35),
            size: 12,
          ),
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Color(0xFF2A2D3A),
          onChanged: _onCurrencyChanged,
          items: CurrencyService.supportedCurrencies.entries.map((entry) {
            final currencyCode = entry.key;
            final currencyData = entry.value;
            
            return DropdownMenuItem<String>(
              value: currencyCode,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currencyData['flag'],
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(width: 4),
                  Text(
                    currencyCode,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 2),
                  Text(
                    currencyData['symbol'],
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}