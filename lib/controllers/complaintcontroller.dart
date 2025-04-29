import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class ComplaintController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ValueNotifier<String> locationNotifier = ValueNotifier("Fetching location...");
  ValueNotifier<String> policeStationNotifier = ValueNotifier("Fetching police station...");
  ValueNotifier<String> userDetailsNotifier = ValueNotifier("Fetching user details...");
  ValueNotifier<String> busDetailsNotifier = ValueNotifier("Fetching bus details...");

  Future<bool> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }
    if (status.isGranted) {
      return true;
    } else {
      locationNotifier.value = "Location permission denied";
      policeStationNotifier.value = "Location permission denied";
      return false;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      bool hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      locationNotifier.value = "Lat: ${position.latitude}, Lng: ${position.longitude}";

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        policeStationNotifier.value = placemarks.first.locality ?? "Unknown Police Station";
      }
    } catch (e) {
      locationNotifier.value = "Error fetching location: $e";
      policeStationNotifier.value = "Error fetching police station";
    }
  }

  Future<void> getUserDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
          userDetailsNotifier.value = "Name: ${data?["name"]}, Phone: ${data?["mobile"]}, NIC: ${data?["nic"]}";
        }
      }
    } catch (e) {
      userDetailsNotifier.value = "Error fetching user details";
    }
  }

  Future<void> getBookedBusDetails(String userId) async {
    try {
      print("Fetching bus details for user: $userId");
      final snapshot = await _firestore.collection('bookings').doc(userId).get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        print("Booking data: $data");

        if (data['status'] == 'active') {
          final busNumber = data['busNumber'];
          print("Fetching bus details for bus number: $busNumber");

          final busDoc = await _firestore.collection('buses').doc(busNumber).get();

          if (busDoc.exists) {
            final busData = busDoc.data()!;
            print("Fetched bus data: $busData");

            busDetailsNotifier.value =
                "Bus Name: ${busData['busName'] ?? 'Unknown'}, Bus Number: ${busData['busNumber'] ?? 'Unknown'}, Route: ${busData['route'] ?? 'Unknown'}, Driver: ${busData['drivMobile'] ?? 'Unknown'}, Distance: ${busData['distance'] ?? 0} km, Fee: Rs.${busData['fee'] ?? 0}";
          } else {
            busDetailsNotifier.value = "Bus details not found in buses collection";
          }
        } else {
          busDetailsNotifier.value = "No active booking found";
        }
      } else {
        busDetailsNotifier.value = "No booking found for this user";
      }
    } catch (e) {
      busDetailsNotifier.value = "Error fetching bus details: $e";
      print("Error fetching bus details: $e");
    }
  }

  Future<void> submitComplaint(String complaint, String busNumber) async {
    try {
      await _firestore.collection('complaints').add({
        'location': locationNotifier.value,
        'police_station': policeStationNotifier.value,
        'user_details': userDetailsNotifier.value,
        'bus_number': busNumber,
        'complaint': complaint,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Complaint submitted successfully");
    } catch (e) {
      print("Error submitting complaint: $e");
      throw Exception("Error submitting complaint: $e");
    }
  }

  final ImagePicker _imagePicker = ImagePicker();
  final List<File> _attachedFiles = [];

  List<File> get attachedFiles => _attachedFiles;

  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  Future<void> pickImage() async {
    try {
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) return;

      final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _attachedFiles.add(File(pickedFile.path));
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> pickVideo() async {
    try {
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) return;

      final XFile? pickedFile = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        _attachedFiles.add(File(pickedFile.path));
      }
    } catch (e) {
      print("Error picking video: $e");
    }
  }

  Future<void> sendWhatsAppMessage({
    required String complaint,
    required String location,
    required String userDetails,
    required String phoneNumber,
    required String busDetails,
  }) async {
    try {
      String cleanedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanedPhoneNumber.length != 9 || !RegExp(r'^[0-9]+$').hasMatch(cleanedPhoneNumber)) {
        throw Exception('Invalid phone number format. Use 0761234567 style.');
      }

      final String message = '''
New Complaint Received:

**User Details:**
$userDetails

**Bus Details:**
$busDetails

**Location:**
$location

**Complaint:**
$complaint

**Attachments:**
${_attachedFiles.isNotEmpty ? _attachedFiles.map((file) => file.path).join('\n') : 'No attachments'}

Please take appropriate action.
''';

      final String encodedMessage = Uri.encodeComponent(message);
      final String whatsappUrl = "whatsapp://send?phone=+94$cleanedPhoneNumber&text=$encodedMessage";
      final Uri whatsappUri = Uri.parse(whatsappUrl);
      final String smsUrl = "sms:+94$cleanedPhoneNumber?body=$encodedMessage";
      final Uri smsUri = Uri.parse(smsUrl);

      bool whatsappLaunched = false;
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        whatsappLaunched = true;
      }

      if (!whatsappLaunched) {
        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('WhatsApp/SMS not available on this device.');
        }
      }
    } catch (e) {
      print("Error sending WhatsApp/SMS message: $e");
      throw Exception('Failed to send message: $e');
    }
  }
}
