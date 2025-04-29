import 'package:cloud_firestore/cloud_firestore.dart';

class BookingManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if wallet has sufficient balance and deduct amount
  Future<bool> deductWalletBalance(String userId, double amount, String bookingId) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final walletRef = _firestore.collection('wallets').doc(userId);
        final walletDoc = await transaction.get(walletRef);

        double currentBalance;
        if (!walletDoc.exists) {
          // Initialize wallet with Rs. 40,000 if it doesn't exist
          transaction.set(walletRef, {
            'balance': 40000.0,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          currentBalance = 40000.0;
        } else {
          final walletData = walletDoc.data()!;
          currentBalance = walletData['balance'] as double;
        }

        if (currentBalance < amount) {
          return false; // Insufficient balance
        }

        // Update wallet balance
        transaction.update(walletRef, {
          'balance': currentBalance - amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Log transaction
        final transactionRef = _firestore.collection('transactions').doc();
        transaction.set(transactionRef, {
          'userId': userId,
          'amount': -amount,
          'type': 'booking',
          'bookingId': bookingId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        return true;
      });
    } catch (e) {
      throw Exception('Error deducting wallet balance: $e');
    }
  }

  // Add top-up amount to wallet
  Future<void> topUpWallet(String userId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final walletRef = _firestore.collection('wallets').doc(userId);
        final walletDoc = await transaction.get(walletRef);

        double currentBalance = 0.0;
        if (walletDoc.exists) {
          currentBalance = walletDoc.data()!['balance'] as double;
        } else {
          // Initialize wallet if it doesn't exist
          transaction.set(walletRef, {
            'balance': 0.0,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }

        // Update wallet balance
        transaction.update(walletRef, {
          'balance': currentBalance + amount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Log transaction
        final transactionRef = _firestore.collection('transactions').doc();
        transaction.set(transactionRef, {
          'userId': userId,
          'amount': amount,
          'type': 'top_up',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Error topping up wallet: $e');
    }
  }

  // Existing functions (updateBusSeatsOnBooking, updateBusSeatsOnDelete) remain unchanged
  Future<void> updateBusSeatsOnBooking(String busNumber, List<String> bookedSeats, String date) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final bookingsQuery = await _firestore
            .collection('bookings')
            .where('busNumber', isEqualTo: busNumber)
            .get();

        int totalBookedSeats = 0;
        for (var doc in bookingsQuery.docs) {
          final bookingData = doc.data();
          final seats = List<String>.from(bookingData['bookedSeats'] ?? []);
          totalBookedSeats += seats.length;
        }

        totalBookedSeats += bookedSeats.length;

        final busQuery = await _firestore
            .collection('buses')
            .where('busNumber', isEqualTo: busNumber)
            .limit(1)
            .get();

        if (busQuery.docs.isEmpty) {
          throw Exception('Bus with busNumber $busNumber not found');
        }

        final busDoc = busQuery.docs.first;
        final busRef = busDoc.reference;
        final busData = busDoc.data();
        final totalSeats = busData['totalSeats'] ?? 0;

        final newAvailableSeats = totalSeats - totalBookedSeats;

        if (totalBookedSeats > totalSeats) {
          throw Exception('Booking exceeds available seats');
        }

        transaction.update(busRef, {
          'bookedSeats': totalBookedSeats,
          'availableSeats': newAvailableSeats,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Error updating bus seats: $e');
    }
  }

  Future<void> updateBusSeatsOnDelete(String busNumber) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final bookingsQuery = await _firestore
            .collection('bookings')
            .where('busNumber', isEqualTo: busNumber)
            .get();

        int totalBookedSeats = 0;
        for (var doc in bookingsQuery.docs) {
          final bookingData = doc.data();
          final seats = List<String>.from(bookingData['bookedSeats'] ?? []);
          totalBookedSeats += seats.length;
        }

        final busQuery = await _firestore
            .collection('buses')
            .where('busNumber', isEqualTo: busNumber)
            .limit(1)
            .get();

        if (busQuery.docs.isEmpty) {
          throw Exception('Bus with busNumber $busNumber not found');
        }

        final busDoc = busQuery.docs.first;
        final busRef = busDoc.reference;
        final busData = busDoc.data();
        final totalSeats = busData['totalSeats'] ?? 0;

        final newAvailableSeats = totalSeats - totalBookedSeats;

        transaction.update(busRef, {
          'bookedSeats': totalBookedSeats,
          'availableSeats': newAvailableSeats,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Error updating bus seats on deletion: $e');
    }
  }
}