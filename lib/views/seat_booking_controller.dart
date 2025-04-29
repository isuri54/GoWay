import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/seatController.dart';
import 'package:intl/intl.dart';

class SeatBookingBackend {
  final BuildContext context;
  final Seatcontroller _seatcontroller = Seatcontroller();

  SeatBookingBackend({required this.context});

  Future<Map<String, String>> initializeSeats(String busNumber, String timeSlot) async {
    List<String> rows = ['A', 'B', 'C', 'D'];
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    String date = dateFormat.format(DateTime.now());
    List<String> bookedSeats = await _seatcontroller.getBookedSheets(busNumber, timeSlot, date);

    Map<String, String> seatStatus = {};
    for (var row in rows) {
      for (int i = 1; i <= 12; i++) {
        seatStatus['$row$i'] = bookedSeats.contains('$row$i') ? 'booked' : 'available';
      }
    }
    return seatStatus;
  }

  SeatSelectionResult selectSeat(String seat, Map<String, String> seatStatus, double fee) {
    Map<String, String> updatedSeatStatus = Map.from(seatStatus);
    double totalCost = 0;

    if (updatedSeatStatus[seat] == 'available') {
      updatedSeatStatus[seat] = 'selected';
    } else if (updatedSeatStatus[seat] == 'selected') {
      updatedSeatStatus[seat] = 'available';
    }

    int selectedSeats = updatedSeatStatus.values.where((s) => s == 'selected').length;
    totalCost = (selectedSeats * fee).toDouble();

    return SeatSelectionResult(seatStatus: updatedSeatStatus, totalCost: totalCost);
  }

  Color getSeatColor(String status) {
    switch (status) {
      case 'available':
        return Colors.white;
      case 'booked':
        return Colors.grey;
      case 'selected':
        return Colors.yellow;
      default:
        return Colors.black;
    }
  }

  Future<BookingResult> bookSeats(Map<String, String> seatStatus, String busNumber, String timeSlot, double fee) async {
    List<String> selectedSeats = seatStatus.entries
        .where((entry) => entry.value == 'selected')
        .map((entry) => entry.key)
        .toList();

    if (selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one seat!")),
      );
      return BookingResult(success: false, seatStatus: seatStatus, totalCost: 0);
    }

    try {
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      String date = dateFormat.format(DateTime.now());
      await _seatcontroller.addSeatBooking(busNumber, timeSlot, date, selectedSeats);

      Map<String, String> updatedSeatStatus = Map.from(seatStatus);
      for (var seat in selectedSeats) {
        updatedSeatStatus[seat] = 'booked';
      }

      double totalCost = (selectedSeats.length * fee).toDouble();
      return BookingResult(success: true, seatStatus: updatedSeatStatus, totalCost: totalCost);
    } catch (e) {
      print("Error booking seats: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $e")),
      );
      return BookingResult(success: false, seatStatus: seatStatus, totalCost: 0);
    }
  }
}

class SeatSelectionResult {
  final Map<String, String> seatStatus;
  final double totalCost;

  SeatSelectionResult({required this.seatStatus, required this.totalCost});
}

class BookingResult {
  final bool success;
  final Map<String, String> seatStatus;
  final double totalCost;

  BookingResult({required this.success, required this.seatStatus, required this.totalCost});
}