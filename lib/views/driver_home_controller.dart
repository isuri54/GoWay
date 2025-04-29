import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/locationController.dart';
import 'package:geolocator/geolocator.dart';

class DriverHomePageBackend {
  final BuildContext context;
  final LocationController locationController;
  final ValueChanged<String> onTripStatusChanged;
  final void Function(int booked, int available, int total) onSeatInfoChanged;
  final ValueChanged<Position> onLocationUpdated;
  final VoidCallback onMarkersCleared;
  String? busId;

  DriverHomePageBackend({
    required this.context,
    required this.locationController,
    required this.onTripStatusChanged,
    required this.onSeatInfoChanged,
    required this.onLocationUpdated,
    required this.onMarkersCleared,
  });

  Future<void> checkInitialStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final driverDoc = await FirebaseFirestore.instance
            .collection('drivers')
            .doc(user.uid)
            .get();
        busId = driverDoc.data()?['busNumber'];
        if (busId != null) {
          await fetchBusSeatInfo();
        }
      } catch (e) {
        _showSnackBar('Error loading initial status: $e');
      }
    }
  }

  Future<void> fetchBusSeatInfo() async {
    if (busId == null) return;

    try {
      FirebaseFirestore.instance
          .collection('buses')
          .where('busNumber', isEqualTo: busId)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final busData = querySnapshot.docs.first.data();
          onSeatInfoChanged(
            busData['bookedSeats'] ?? 0,
            busData['availableSeats'] ?? 0,
            busData['totalSeats'] ?? 0,
          );
        } else {
          onSeatInfoChanged(0, 0, 0);
          _showSnackBar('Bus data not found for bus number: $busId');
        }
      }, onError: (e) {
        onSeatInfoChanged(0, 0, 0);
        _showSnackBar('Error loading bus seat info: $e');
      });
    } catch (e) {
      onSeatInfoChanged(0, 0, 0);
      _showSnackBar('Error loading bus seat info: $e');
    }
  }

  void startTrip(void Function(String) showTripDialog) {
    locationController.startSharingLocation(
      context: context,
      busId: busId,
      onSuccess: (status) {
        onTripStatusChanged(status);
        locationController.positionStream?.listen(onLocationUpdated);
        showTripDialog('Trip Wanted Successfully!');
      },
      onError: _showSnackBar,
    );
  }

  void endTrip(void Function(String) showTripDialog) {
    locationController.stopSharingLocation(
      busId: busId,
      onSuccess: (status) {
        onTripStatusChanged(status);
        onMarkersCleared();
        showTripDialog('Trip Ended Successfully!');
      },
      onError: _showSnackBar,
    );
  }

  void _showSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}