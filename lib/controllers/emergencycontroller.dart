import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyController {
  LatLng? _currentLocation;

  LatLng? get currentLocation => _currentLocation;

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        log('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log('Location permissions are permanently denied.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentLocation = LatLng(position.latitude, position.longitude);
    log('Current location: $_currentLocation');
  }

  Future<void> sendEmergencyEmail(String type, Map<String, String> userData, String messageBody) async {
    final String username = dotenv.env['GMAIL_USERNAME'] ?? '';
    final String password = dotenv.env['GMAIL_APP_PASSWORD'] ?? '';
    final String policeEmail = dotenv.env['POLICE_EMAIL'] ?? '';

    log('GMAIL_USERNAME: $username');
    log('GMAIL_APP_PASSWORD: $password');
    log('POLICE_EMAIL: $policeEmail');

    if (username.isEmpty || password.isEmpty || policeEmail.isEmpty) {
      log('Missing credentials in .env file');
      throw Exception('Gmail credentials or police email not found in .env file');
    }

    SmtpServer smtpServer;
    try {
      smtpServer = gmail(username, password);
      log('SMTP server initialized successfully');
    } catch (e) {
      log('Error initializing SMTP server: $e');
      throw Exception('Failed to initialize SMTP server: $e');
    }

    final message = Message()
      ..from = Address(username, 'Emergency Alert System')
      ..recipients.add(policeEmail)
      ..subject = 'Emergency Alert: $type'
      ..text = '''
Emergency Alert: $type

Details:
- Name: ${userData['name']}
- NIC: ${userData['nic']}
- Bus Number: ${userData['busNumber']}
- Bus Name: ${userData['busName']}
- Location: ${_currentLocation != null ? 'Lat: ${_currentLocation!.latitude}, Lng: ${_currentLocation!.longitude}' : 'Location not available'}

$messageBody

Please respond immediately.
''';

    try {
      final sendReport = await send(message, smtpServer);
      log('Emergency email sent: ${sendReport.toString()}');
    } catch (e) {
      log('Error sending emergency email: $e');
      throw Exception('Failed to send emergency email: $e');
    }
  }
}