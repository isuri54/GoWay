class Transaction {
  final String id;
  final String userId;
  final double amount;
  final DateTime date;
  final String type; // 'payment', 'topup', 'transfer'
  final String? reference; // booking ID or other reference
  final String status; // 'completed', 'failed', 'pending'

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.type,
    this.reference,
    this.status = 'completed',
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['userId'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      type: json['type'],
      reference: json['reference'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
      'reference': reference,
      'status': status,
    };
  }
}