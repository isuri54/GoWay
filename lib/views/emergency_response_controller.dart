import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';

class EmergencyResponseBackend {
  final BuildContext context;

  EmergencyResponseBackend({required this.context});

  Future<Map<String, String>?> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        log('No user is currently logged in');
        return null;
      }
      log('Current user UID: ${user.uid}');
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        log('User document does not exist for UID: ${user.uid}');
        return null;
      }
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      String name = userData['name']?.toString() ?? "Unknown";
      String nic = userData['nic']?.toString() ?? "N/A";
      String busNumber = userData['busNumber']?.toString() ?? "N/A";
      String busName = userData['busName']?.toString() ?? "N/A";

      try {
        QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (bookingSnapshot.docs.isNotEmpty) {
          Map<String, dynamic> bookingData = bookingSnapshot.docs.first.data() as Map<String, dynamic>;
          String? busId = bookingData['busId']?.toString();
          if (busId != null) {
            DocumentSnapshot busDoc = await FirebaseFirestore.instance.collection('buses').doc(busId).get();
            if (busDoc.exists) {
              Map<String, dynamic> busData = busDoc.data() as Map<String, dynamic>;
              busNumber = busData['busNumber']?.toString() ?? busNumber;
              busName = busData['busName']?.toString() ?? busName;
              log('Using bus details from booking: $busNumber, $busName');
            } else {
              log('Bus document for busId: $busId does not exist');
            }
          }
        } else {
          log('No bookings found for user, using default bus details');
        }
      } catch (e) {
        log('Error querying bookings: $e');
      }

      if (busNumber == 'N/A' || busName == 'N/A') {
        log('Warning: busNumber or busName is N/A, check users or bookings data');
      }

      return {'name': name, 'nic': nic, 'busNumber': busNumber, 'busName': busName};
    } catch (e) {
      log('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching user data: $e')));
      return null;
    }
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log('Location services are disabled.');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        log('Location permissions are denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log('Location permissions are permanently denied.');
      return null;
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Stream<QuerySnapshot> getRecentAlerts() {
    return FirebaseFirestore.instance
        .collection('emergency_alerts')
        .orderBy('timestamp', descending: true)
        .limit(3)
        .snapshots();
  }

  Future<void> openDialer() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '0761174943');
    try {
      bool isEmulator = false;
      if (Platform.isAndroid || Platform.isIOS) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          isEmulator = !androidInfo.isPhysicalDevice;
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          isEmulator = !iosInfo.isPhysicalDevice;
        }
      }

      log('Attempting to launch URL: $phoneUri, isEmulator: $isEmulator');
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        log('Dialer opened with number 0761174943');
      } else {
        log('Cannot launch dialer');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEmulator
                  ? 'Phone dialer not available on emulator. Please test on a physical device.'
                  : 'Cannot open phone dialer on this device.',
            ),
          ),
        );
      }
    } catch (e) {
      log('Error launching dialer: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening dialer: $e')));
    }
  }

  Future<AlertResult> sendEmergencyAlert(String type) async {
    log('Starting sendEmergencyAlert for type: $type');
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      log('Cannot send emergency alert: No user is logged in');
      return AlertResult(errorMessage: 'Cannot send emergency alert: No user is logged in');
    }

    Position? position;
    try {
      position = await getCurrentLocation();
      if (position == null) {
        log('Error getting location: Unable to obtain location');
        return AlertResult(errorMessage: 'Error getting location: Unable to obtain location');
      }
      log('Location obtained: Lat: ${position.latitude}, Lng: ${position.longitude}');
    } catch (e) {
      log('Error getting location: $e');
      return AlertResult(errorMessage: 'Error getting location: $e');
    }

    Map<String, String>? userData = await fetchUserData();
    if (userData == null) {
      log('Cannot send emergency alert: User data is missing');
      return AlertResult(errorMessage: 'Cannot send emergency alert: User data is missing');
    }
    log('User data fetched: $userData');

    try {
      await FirebaseFirestore.instance.collection('emergency_alerts').add({
        'userId': user.uid,
        'type': type,
        'location': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
        'name': userData['name'],
        'nic': userData['nic'],
        'busNumber': userData['busNumber'],
        'busName': userData['busName'],
      });
      log('Emergency alert added to Firestore successfully');

      final gmailUsername = dotenv.env['GMAIL_USERNAME'];
      final gmailAppPassword = dotenv.env['GMAIL_APP_PASSWORD'];
      final policeEmail = dotenv.env['POLICE_EMAIL'];

      log('GMAIL_USERNAME: ${gmailUsername ?? "null"}');
      log('GMAIL_APP_PASSWORD: ${gmailAppPassword != null ? "**** (length: ${gmailAppPassword.length})" : "null"}');
      log('POLICE_EMAIL: ${policeEmail ?? "null"}');

      if (gmailUsername == null || gmailAppPassword == null || policeEmail == null) {
        log('Error: One or more environment variables are missing');
        return AlertResult(errorMessage: 'Error: Missing environment variables. Check .env file.');
      }

      if (gmailUsername.trim() != gmailUsername ||
          gmailAppPassword.trim() != gmailAppPassword ||
          policeEmail.trim() != policeEmail) {
        log('Error: .env variables contain spaces or invalid characters');
        return AlertResult(errorMessage: 'Error: .env variables contain spaces or invalid characters.');
      }

      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      String? emailError;
      if (!emailRegExp.hasMatch(gmailUsername)) {
        emailError = 'Invalid email format for GMAIL_USERNAME: $gmailUsername';
      } else if (!emailRegExp.hasMatch(policeEmail)) {
        emailError = 'Invalid email format for POLICE_EMAIL: $policeEmail';
      }

      if (emailError != null) {
        log('Error: $emailError');
        return AlertResult(errorMessage: emailError);
      }

      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        port: 587,
        username: gmailUsername,
        password: gmailAppPassword,
        ssl: false,
        allowInsecure: true,
      );
      log('SMTP server configured: smtp.gmail.com, port: 587, username: $gmailUsername');

      final message = Message()
        ..from = Address(gmailUsername, 'Emergency Alert System')
        ..recipients.add(policeEmail)
        ..subject = 'Emergency Alert: $type'
        ..text = '''
Emergency Alert: $type

Details:
- Name: ${userData['name']}
- NIC: ${userData['nic']}
- Bus Number: ${userData['busNumber']}
- Bus Name: ${userData['busName']}
- Location: Lat: ${position.latitude}, Lng: ${position.longitude}
- Timestamp: ${DateTime.now().toString()}

${type == 'Accident' ? 'An accident has occurred involving the bus. Immediate medical and police assistance is required at the location.' : type == 'Fire Emergency' ? 'A fire emergency has been reported on the bus. Firefighting services and emergency response teams are needed urgently.' : 'A general emergency alert has been triggered. Please investigate the situation at the provided location.'}

Please respond immediately.
        ''';

      log('Email message prepared for sending to $policeEmail');

      try {
        final sendReport = await send(message, smtpServer).timeout(
          const Duration(seconds: 60),
          onTimeout: () async {
            log('Email sending timed out, retrying once...');
            try {
              final retryReport = await send(message, smtpServer).timeout(
                const Duration(seconds: 30),
                onTimeout: () => throw Exception('Email sending timed out after retry'),
              );
              return retryReport;
            } catch (e) {
              throw Exception('Email sending failed after retry: $e');
            }
          },
        );
        log('Email sent successfully: ${sendReport.toString()}');
        return AlertResult(successMessage: 'Email sent successfully, we will help you as soon as possible.');
      } catch (e, stackTrace) {
        log('Error sending email via Gmail: $e\nStackTrace: $stackTrace');
        String errorMessage = 'Error sending email: $e';
        if (e.toString().contains('Authentication Failed') || e.toString().contains('535')) {
          errorMessage = 'Email authentication failed. Please verify Gmail app password or security settings.';
          log('Authentication failure details: Check https://support.google.com/mail/?p=BadCredentials');
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Email sending timed out. Check network connection.';
        }
        return AlertResult(errorMessage: errorMessage);
      }
    } catch (e) {
      log('Error adding emergency alert to Firestore: $e');
      return AlertResult(errorMessage: 'Error sending emergency alert: $e');
    }
  }
}

class AlertResult {
  final String? errorMessage;
  final String? successMessage;

  AlertResult({this.errorMessage, this.successMessage});
}