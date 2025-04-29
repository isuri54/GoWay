import 'package:flutter/material.dart';

class WalletPageBackend {
  final BuildContext context;
  double _currentBalance = 10000.0;
  String? _savedCardNumber;
  String? _savedCardHolderName;

  WalletPageBackend({required this.context});

  void saveCardDetails({required String cardNumber, required String cardHolderName}) {
    _savedCardNumber = cardNumber;
    _savedCardHolderName = cardHolderName;
  }

  double processTopUp(double amount) {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid top-up amount')),
      );
      return _currentBalance;
    }
    _currentBalance += amount;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Topped up Rs. $amount successfully')),
    );
    return _currentBalance;
  }

  Future<PaymentResult> processPayment(double bookingPrice) async {
    if (_savedCardNumber == null || _savedCardHolderName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a card first')),
      );
      return PaymentResult(success: false, newBalance: _currentBalance);
    }

    if (_currentBalance >= bookingPrice) {
      bool transferSuccess = await _transferToBank(bookingPrice);
      if (transferSuccess) {
        _currentBalance -= bookingPrice;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking paid successfully! Rs. $bookingPrice transferred to bank.'),
            duration: const Duration(seconds: 5),
          ),
        );
        return PaymentResult(success: true, newBalance: _currentBalance);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank transfer failed')),
        );
        return PaymentResult(success: false, newBalance: _currentBalance);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance')),
      );
      return PaymentResult(success: false, newBalance: _currentBalance);
    }
  }

  Future<bool> _transferToBank(double amount) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      print('Transferred Rs. $amount to bank account');
      return true;
    } catch (e) {
      print('Bank transfer failed: $e');
      return false;
    }
  }
}

class PaymentResult {
  final bool success;
  final double newBalance;

  PaymentResult({
    required this.success,
    required this.newBalance,
  });
}