import 'package:flutter/material.dart';

class TopUpPage extends StatefulWidget {
  final String cardNumber;
  final String cardHolderName;
  final String? expiryDate;
  final String? cvv;
  final double? requiredAmount;

  const TopUpPage({
    super.key,
    required this.cardNumber,
    required this.cardHolderName,
    this.expiryDate,
    this.cvv,
    this.requiredAmount,
  });

  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _amountController = TextEditingController();
  String selectedAmount = '';

  @override
  void initState() {
    super.initState();
    if (widget.requiredAmount != null) {
      _amountController.text = widget.requiredAmount!.toStringAsFixed(2);
      selectedAmount = widget.requiredAmount!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Top Up Wallet",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Card Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Card: •••• •••• •••• ${widget.cardNumber.substring(widget.cardNumber.length - 4)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Name: ${widget.cardHolderName}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (widget.expiryDate != null)
                    Text(
                      "Expiry: ${widget.expiryDate}",
                      style: const TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select or Enter Amount",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _amountButton("500"),
                _amountButton("1000"),
                _amountButton("2000"),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (LKR)',
                hintText: 'Enter custom amount',
                prefixText: 'Rs. ',
              ),
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount <= 0) {
                  return 'Enter valid amount';
                }
                if (widget.requiredAmount != null && amount < widget.requiredAmount!) {
                  return 'Minimum Rs. ${widget.requiredAmount!.toStringAsFixed(2)}';
                }
                return null;
              },
              onChanged: (value) => setState(() => selectedAmount = value),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(
                      selectedAmount.isEmpty ? _amountController.text : selectedAmount);
                  if (amount != null && amount > 0) {
                    if (widget.requiredAmount != null && amount < widget.requiredAmount!) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Minimum top-up: Rs. ${widget.requiredAmount!.toStringAsFixed(2)}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context, amount);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter valid amount'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: const Text("CONFIRM TOP UP"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountButton(String amount) {
    return ElevatedButton(
      onPressed: () => setState(() {
        selectedAmount = amount;
        _amountController.text = amount;
      }),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedAmount == amount
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
      ),
      child: Text("Rs. $amount"),
    );
  }
}