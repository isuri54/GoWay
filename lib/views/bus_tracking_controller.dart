import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' show cos, sqrt, asin, sin, pi;

class BusTrackingService {
  Stream<LatLng?> getBusLocationStream(String busId) {
    return FirebaseFirestore.instance
        .collection('buses')
        .doc(busId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        return LatLng(data['lat'], data['lng']);
      }
      return null;
    });
  }

  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print("Error geocoding address: $e");
    }
    return null;
  }

  double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371;
    double lat1 = point1.latitude * pi / 180;
    double lon1 = point1.longitude * pi / 180;
    double lat2 = point2.latitude * pi / 180;
    double lon2 = point2.longitude * pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }
}
