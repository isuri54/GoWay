import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_application_1/controllers/busController.dart';
import 'package:flutter_application_1/views/qr_scanner_screen.dart';

class QrHomeBackend {
  final BuildContext context;
  final BusController _busController = BusController();

  QrHomeBackend({required this.context});

  Future<UserDetails> fetchUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return UserDetails(name: 'Guest', gender: 'male', walletBalance: 0.0, role: 'user');
      }

      final uid = user.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userEmail = user.email ?? 'Unknown';

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return UserDetails(
          name: data['name'] ?? userEmail,
          gender: data['gender']?.toLowerCase() == 'female' ? 'female' : 'male',
          walletBalance: (data.containsKey('wallet_balance') ? data['wallet_balance'] : 0).toDouble(),
          role: data['role'] ?? 'user',
        );
      } else {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': userEmail,
          'gender': 'male',
          'wallet_balance': 0.0,
          'role': 'user',
        }, SetOptions(merge: true));
        return UserDetails(name: userEmail, gender: 'male', walletBalance: 0.0, role: 'user');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching user details: $e')));
      }
      return UserDetails(
        name: FirebaseAuth.instance.currentUser?.email ?? 'Guest',
        gender: 'male',
        walletBalance: 0.0,
        role: 'user',
      );
    }
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera permission denied')));
    }
  }

  Future<RouteResult> searchRoute(String from, String to) async {
    final fromTrimmed = from.trim();
    final toTrimmed = to.trim();

    if (fromTrimmed.isEmpty || toTrimmed.isEmpty) {
      return RouteResult(errorMessage: 'Please enter both From and To locations.');
    }

    if (fromTrimmed.length < 3 || toTrimmed.length < 3) {
      return RouteResult(
        errorMessage: 'Location names are too short. Please use format: City, Country (e.g., Colombo, Sri Lanka).',
      );
    }

    String formattedFrom = fromTrimmed.contains(',') ? fromTrimmed : '$fromTrimmed, Sri Lanka';
    String formattedTo = toTrimmed.contains(',') ? toTrimmed : '$toTrimmed, Sri Lanka';
    String routeKey = "${fromTrimmed.toUpperCase()}-${toTrimmed.toUpperCase()}";

    try {
      List<Map<String, dynamic>> routeData = await _busController.getBusDetailsByRoute(routeKey);
      if (routeData.isEmpty) {
        throw Exception('Route not found in the database: $routeKey');
      }
      String fee = routeData[0]['fee'] ?? "0";
      double fetchedPrice = double.parse(fee);

      const apiKey = 'YOUR_NEW_API_KEY';
      final url =
          'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=${Uri.encodeComponent(formattedFrom)}&destinations=${Uri.encodeComponent(formattedTo)}&key=$apiKey';

      final response = await http.get(Uri.parse(url));
      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];

        if (status == 'OK') {
          final rows = data['rows'] as List<dynamic>;
          if (rows.isEmpty || rows[0]['elements'].isEmpty) {
            throw Exception('No results returned for the specified locations.');
          }
          final elements = rows[0]['elements'][0];
          final elementStatus = elements['status'];

          if (elementStatus == 'OK') {
            final distanceInMeters = elements['distance']['value'] as int;
            final newDistance = distanceInMeters / 1000;
            return RouteResult(distance: newDistance, routePrice: fetchedPrice);
          } else if (elementStatus == 'NOT_FOUND') {
            throw Exception(
                'One or both locations could not be found. Try using: City, Country (e.g., Colombo, Sri Lanka).');
          } else if (elementStatus == 'ZERO_RESULTS') {
            throw Exception('No route found between $formattedFrom and $formattedTo. Check if a road route exists.');
          } else {
            throw Exception('Route error: $elementStatus');
          }
        } else if (status == 'INVALID_REQUEST') {
          throw Exception('Invalid location names. Please check your input.');
        } else if (status == 'REQUEST_DENIED') {
          throw Exception('API key is invalid or not enabled for Distance Matrix API. Check Google Cloud Console.');
        } else if (status == 'OVER_QUERY_LIMIT') {
          throw Exception('API quota exceeded. Please try again later.');
        } else {
          throw Exception('API error: $status');
        }
      } else {
        throw Exception('Failed to fetch distance: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching distance or fee: $e');
      return RouteResult(errorMessage: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<QRScanResult?> openQRScanner(double? distance, double totalFare) async {
    if (distance == null || totalFare == 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please search a route and price first to calculate the fare.')),
        );
      }
      return null;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && context.mounted) {
      try {
        final decoded = json.decode(result);
        if (decoded is Map<String, dynamic> &&
            decoded.containsKey('bank') &&
            decoded.containsKey('account_number') &&
            decoded.containsKey('branch')) {
          return QRScanResult(rawResult: result, bankDetails: decoded);
        } else {
          throw Exception('Invalid QR code format. Expected bank details.');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error parsing QR code: $e')));
        }
        return null;
      }
    }
    return null;
  }

  Future<bool> processPayment(
    double totalFare,
    String from,
    String to,
    Map<String, dynamic>? bankDetails,
  ) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('User not logged in.');
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        throw Exception('User data not found.');
      }
      final walletBalance = (userDoc.data()?['wallet_balance'] ?? 0).toDouble();

      if (walletBalance < totalFare) {
        throw Exception('Insufficient wallet balance. Please top up your wallet.');
      }

      final newBalance = walletBalance - totalFare;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'wallet_balance': newBalance,
      });

      await FirebaseFirestore.instance.collection('transactions').add({
        'user_id': uid,
        'amount': totalFare,
        'type': 'debit',
        'description': 'Bus fare from $from to $to',
        'bank_details': bankDetails,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      }
      return false;
    }
  }
}

class UserDetails {
  final String name;
  final String gender;
  final double walletBalance;
  final String role;

  UserDetails({
    required this.name,
    required this.gender,
    required this.walletBalance,
    required this.role,
  });
}

class RouteResult {
  final double? distance;
  final double? routePrice;
  final String? errorMessage;

  RouteResult({this.distance, this.routePrice, this.errorMessage});
}

class QRScanResult {
  final String rawResult;
  final Map<String, dynamic> bankDetails;

  QRScanResult({required this.rawResult, required this.bankDetails});
}