import 'package:flutter/material.dart';
import 'transaction_model.dart';

class WalletHistoryScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const WalletHistoryScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            leading: Icon(
              transaction.type == 'topup' 
                  ? Icons.add_circle_outline 
                  : Icons.remove_circle_outline,
              color: transaction.type == 'topup' ? Colors.green : Colors.red,
            ),
            title: Text(
              transaction.type.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(transaction.date.toString()),
            trailing: Text(
              'Rs. ${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.type == 'topup' ? Colors.green : Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }
}