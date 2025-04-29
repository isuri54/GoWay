import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Seatcontroller {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getBookedSheets(String busNumber, String time, String date) async {
    String key = "$busNumber~$date~$time";
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(key)
          .get();

    if (snapshot.exists) {
      List<String> seats = List<String>.from(snapshot['bookedSeats'] ?? []);
      return seats;
    } else{
      return [];
    }
  }

  Future<void> addSeatBooking (String busNumber, String time, String date, List<String> selectedSeats) async{
    final bookingRef = FirebaseFirestore.instance.collection('bookings');
    String key = "$busNumber~$date~$time";
    try {
      DocumentSnapshot bookingSnapshot = await bookingRef.doc(key).get();

      if (bookingSnapshot.exists) {
        await bookingRef.doc(key).update({
          'bookedSeats': FieldValue.arrayUnion(selectedSeats),
        });
      } else {
        await bookingRef.doc(key).set({
          'busNumber': busNumber,
          'date': date,
          'time': time,
          'bookedSeats': selectedSeats
        });
      }
    } catch (e) {
      print("Error $e");
    }
  }
}