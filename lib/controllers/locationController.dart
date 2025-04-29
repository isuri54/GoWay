import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationController {
  bool isSharingLocation = false;
  Stream<Position>? _positionStream;

  Stream<Position>? get positionStream => _positionStream;

  Future<void> startSharingLocation({
    required BuildContext context,
    required String? busId,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        onError('Please enable location services');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          onError('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        onError('Please enable location permission in settings');
        return;
      }

      isSharingLocation = true;

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && busId != null) {
        _positionStream?.listen((Position position) async {
          await FirebaseFirestore.instance.collection('buses').doc(busId).set({
            'driverId': user.uid,
            'busId': busId,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'timestamp': FieldValue.serverTimestamp(),
            'status': 'active',
          }, SetOptions(merge: true));
        });
      }

      onSuccess('Active');
    } catch (e) {
      isSharingLocation = false;
      onError('Error starting trip: $e');
    }
  }

  Future<void> stopSharingLocation({
    required String? busId,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      isSharingLocation = false;

      if (busId != null) {
        await FirebaseFirestore.instance.collection('buses').doc(busId).update({
          'status': 'inactive',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      await _positionStream?.drain();
      _positionStream = null;

      onSuccess('Completed');
    } catch (e) {
      onError('Error ending trip: $e');
    }
  }

  void dispose() {
    _positionStream?.drain();
    _positionStream = null;
  }
}