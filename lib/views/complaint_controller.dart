import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/controllers/complaintcontroller.dart';

class ComplainWarningBackend {
  final BuildContext context;
  final ComplaintController _complaintController = ComplaintController();
  ValueListenable<String> get locationNotifier => _complaintController.locationNotifier;
  ValueListenable<String> get userDetailsNotifier => _complaintController.userDetailsNotifier;
  ValueListenable<String> get busDetailsNotifier => _complaintController.busDetailsNotifier;
  List get attachedFiles => _complaintController.attachedFiles;

  ComplainWarningBackend({required this.context});

  Future<void> initialize() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'default_user_id';
    if (FirebaseAuth.instance.currentUser == null) {
      debugPrint("No user signed in");
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'You must be signed in to file a complaint',
        onConfirmBtnTap: () => Navigator.pop(context),
      );
      return;
    }
    await Future.wait([
      _complaintController.getCurrentLocation(),
      _complaintController.getUserDetails(),
      _complaintController.getBookedBusDetails(userId),
    ]);
  }

  String generateGoogleMapsUrl(String location) {
    try {
      if (location.isEmpty || location == "Fetching location...") {
        debugPrint("Location is empty or still fetching");
        return 'Invalid location format';
      }
      if (location.startsWith("Error") ||
          location.startsWith("Location services") ||
          location.startsWith("Location permissions")) {
        debugPrint("Location error: $location");
        return 'Invalid location format';
      }
      if (!location.contains(',')) {
        debugPrint("Location does not contain a comma: $location");
        return 'Invalid location format';
      }
      final parts = location.split(',');
      if (parts.length != 2) {
        debugPrint("Location does not have exactly two parts: $location");
        return 'Invalid location format';
      }
      final latPart = parts[0].trim().replaceAll("Lat: ", "");
      final lngPart = parts[1].trim().replaceAll("Lng: ", "");
      final latDouble = double.tryParse(latPart);
      final lngDouble = double.tryParse(lngPart);
      if (latDouble == null || lngDouble == null) {
        debugPrint("Cannot parse lat/lng as doubles: lat=$latPart, lng=$lngPart");
        return 'Invalid location format';
      }
      if (latDouble < -90 || latDouble > 90 || lngDouble < -180 || lngDouble > 180) {
        debugPrint("Lat/lng out of valid range: lat=$latDouble, lng=$lngDouble");
        return 'Invalid location format';
      }
      final url = 'https://www.google.com/maps?q=$latDouble,$lngDouble';
      debugPrint("Generated Google Maps URL: $url");
      return url;
    } catch (e) {
      debugPrint("Error generating Google Maps URL: $e");
      return 'Invalid location format';
    }
  }

  Future<void> launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> sendEmail(String complaint, String location, String userDetails, String busDetails) async {
    String username = 'osandihirimuthugodage23.se@gmail.com';
    String password = 'jkei qsci dhlm tkoa';
    final smtpServer = gmail(username, password);
    final googleMapsUrl = generateGoogleMapsUrl(location);
    final locationText = googleMapsUrl == 'Invalid location format' ? 'Location not available' : googleMapsUrl;

    final message = Message()
      ..from = Address(username, 'Complaint System')
      ..recipients.add('actual.police.department.email@example.com')
      ..subject = 'New Complaint Submission - ${DateTime.now()}'
      ..text = '''
New Complaint Received:

**User Details:**
$userDetails

**Bus Details:**
$busDetails

**Location:**
$locationText

**Complaint:**
$complaint

**Attachments:**
${_complaintController.attachedFiles.isNotEmpty ? _complaintController.attachedFiles.map((file) => file.path).join('\n') : 'No attachments'}

Please take appropriate action.
''';

    try {
      final sendReport = await send(message, smtpServer);
      debugPrint('Email sent: ${sendReport.toString()}');
    } catch (e) {
      debugPrint('Error sending email: $e');
      throw Exception('Failed to send email: $e');
    }
  }

  Future<ComplaintResult> submitComplaint(String complaint) async {
    if (complaint.isEmpty) {
      return ComplaintResult(success: false, message: 'Please fill in the complaint field');
    }

    try {
      await _complaintController.submitComplaint(complaint, "");
      String location = _complaintController.locationNotifier.value;
      String userDetails = _complaintController.userDetailsNotifier.value;
      String busDetails = _complaintController.busDetailsNotifier.value;
      final googleMapsUrl = generateGoogleMapsUrl(location);
      final locationText = googleMapsUrl == 'Invalid location format' ? 'Location not available' : googleMapsUrl;

      bool emailSent = false;
      bool whatsappSent = false;
      String? emailError;
      String? whatsappError;

      try {
        await sendEmail(complaint, location, userDetails, busDetails);
        emailSent = true;
      } catch (error) {
        emailError = error.toString();
      }

      try {
        await _complaintController.sendWhatsAppMessage(
          complaint: complaint,
          location: locationText,
          userDetails: userDetails,
          busDetails: busDetails,
          phoneNumber: '0761174943',
        );
        whatsappSent = true;
      } catch (error) {
        whatsappError = error.toString();
      }

      if (emailSent && whatsappSent) {
        return ComplaintResult(
          success: true,
          message:
              'Complaint submitted successfully, email sent to the police department, and WhatsApp message sent to the police station',
        );
      } else {
        String errorMessage = 'Failed to complete the following actions:\n';
        if (!emailSent) errorMessage += '- Send email: ${emailError ?? 'Unknown error'}\n';
        if (!whatsappSent) errorMessage += '- Send WhatsApp message: ${whatsappError ?? 'Unknown error'}\n';
        return ComplaintResult(success: false, message: errorMessage);
      }
    } catch (error) {
      return ComplaintResult(success: false, message: 'Failed to submit complaint: $error');
    }
  }

  Future<void> getCurrentLocation() async {
    await _complaintController.getCurrentLocation();
  }

  Future<void> pickImage() async {
    await _complaintController.pickImage();
  }

  Future<void> pickVideo() async {
    await _complaintController.pickVideo();
  }
}

class ComplaintResult {
  final bool success;
  final String message;

  ComplaintResult({required this.success, required this.message});
}