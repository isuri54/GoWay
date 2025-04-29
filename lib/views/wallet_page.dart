import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/wallet_controller.dart';
import 'credit_card_form.dart';
import 'bottom_nav.dart';

class WalletPage extends StatefulWidget {
  final double? bookingPrice;

  const WalletPage({super.key, this.bookingPrice});

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late final WalletPageBackend _backend;
  int _currentIndex = 3;
  double _currentBalance = 10000.0;
  String? _savedCardNumber;
  String? _savedCardHolderName;

  @override
  void initState() {
    super.initState();
    _backend = WalletPageBackend(context: context);
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/userhome');
        break;
      case 1:
        Navigator.pushNamed(context, '/seats-booking');
        break;
      case 2:
        Navigator.pushNamed(context, '/qr-scanner');
        break;
      case 3:
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Future<void> _showPaymentDialog(BuildContext context, double bookingPrice) async {
    final remainingBalance = _currentBalance - bookingPrice;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Confirm Payment'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Booking Price: Rs. ${bookingPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Current Balance: Rs. ${_currentBalance.toStringAsFixed(2)}'),
              const SizedBox(height: 10),
              if (remainingBalance >= 0)
                Text('Remaining Balance: Rs. ${remainingBalance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green))
              else
                Text(
                  'Insufficient balance. Please top up Rs. ${(bookingPrice - _currentBalance).toStringAsFixed(2)}.',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.white,
          actions: [
            if (remainingBalance < 0)
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (_savedCardNumber == null || _savedCardHolderName == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please add a card first')),
                    );
                    return;
                  }

                  final requiredTopUpAmount = bookingPrice - _currentBalance;
                  final topUpResult = await Navigator.pushNamed(
                    context,
                    '/topup',
                    arguments: {
                      'cardNumber': _savedCardNumber!,
                      'cardHolderName': _savedCardHolderName!,
                      'requiredAmount': requiredTopUpAmount,
                    },
                  );

                  if (topUpResult != null && topUpResult is double) {
                    final newBalance = _backend.processTopUp(topUpResult);
                    setState(() {
                      _currentBalance = newBalance;
                    });
                    _showPaymentDialog(context, bookingPrice);
                  }
                },
                child: const Text('Top Up'),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            if (remainingBalance >= 0)
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await _backend.processPayment(bookingPrice);
                  if (result.success) {
                    setState(() {
                      _currentBalance = result.newBalance;
                    });
                  }
                },
                child: const Text('Confirm'),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bookingPrice = widget.bookingPrice ?? 1500.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Goway Wallet",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.account_balance_wallet, size: 40),
                      SizedBox(width: 10),
                      Text(
                        "Goway Customer Wallet",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Current Balance",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  Semantics(
                    label: 'Current wallet balance',
                    child: Text(
                      "Rs ${_currentBalance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreditCardForm()),
                    );
                    if (result != null && result is Map<String, String>) {
                      setState(() {
                        _savedCardNumber = result['cardNumber'];
                        _savedCardHolderName = result['cardHolderName'];
                      });
                      _backend.saveCardDetails(
                        cardNumber: _savedCardNumber!,
                        cardHolderName: _savedCardHolderName!,
                      );
                      final topUpResult = await Navigator.pushNamed(
                        context,
                        '/topup',
                        arguments: {
                          'cardNumber': _savedCardNumber!,
                          'cardHolderName': _savedCardHolderName!,
                        },
                      );
                      if (topUpResult != null && topUpResult is double) {
                        final newBalance = _backend.processTopUp(topUpResult);
                        setState(() {
                          _currentBalance = newBalance;
                        });
                      }
                    }
                  },
                  icon: const Icon(Icons.credit_card),
                  label: const Text("Add Card"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (bookingPrice <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No booking price specified')),
                      );
                      return;
                    }
                    await _showPaymentDialog(context, bookingPrice);
                  },
                  icon: const Icon(Icons.account_balance),
                  label: const Text("Pay Booking"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomFooter(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}