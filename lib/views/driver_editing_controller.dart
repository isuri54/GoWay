import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverEditingBackend {
  final BuildContext context;

  DriverEditingBackend({required this.context});

  Future<void> loadDriverData({
    required TextEditingController fullNameController,
    required TextEditingController addressController,
    required TextEditingController emailController,
    required TextEditingController birthdayController,
    required TextEditingController phoneNumberController,
    required TextEditingController busNumberController,
    required TextEditingController busNameController,
    required TextEditingController routeController,
    required ValueChanged<String?> onGenderChanged,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final driverDoc = await FirebaseFirestore.instance
            .collection('drivers')
            .doc(user.uid)
            .get();
        if (driverDoc.exists) {
          final driverData = driverDoc.data()!;
          fullNameController.text = driverData['drivName'] ?? '';
          addressController.text = driverData['drivAddress'] ?? '';
          emailController.text = driverData['drivEmail'] ?? '';
          final birthdate = (driverData['drivBirthdate'] as Timestamp?)?.toDate();
          if (birthdate != null) {
            birthdayController.text =
                "${birthdate.day}/${birthdate.month}/${birthdate.year}";
          }
          phoneNumberController.text = driverData['drivMobile'] ?? '';
          onGenderChanged(driverData['drivGender'] ?? 'Female');
          busNumberController.text = driverData['busNumber'] ?? '';
          busNameController.text = driverData['busName'] ?? '';
          routeController.text = driverData['busRoute'] ?? '';
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading driver data: $e')),
        );
      }
    }
  }

  Future<void> saveDriverData({
    required GlobalKey<FormState> formKey,
    required String fullName,
    required String address,
    required String email,
    required String birthday,
    required String phoneNumber,
    required String? gender,
    required String busNumber,
    required String busName,
    required String route,
    required VoidCallback onSuccess,
  }) async {
    if (formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final birthdateParts = birthday.split('/');
          final birthdate = DateTime(
            int.parse(birthdateParts[2]),
            int.parse(birthdateParts[1]),
            int.parse(birthdateParts[0]),
          );

          await FirebaseFirestore.instance.collection('drivers').doc(user.uid).update({
            'drivName': fullName,
            'drivAddress': address,
            'drivEmail': email,
            'drivBirthdate': Timestamp.fromDate(birthdate),
            'drivMobile': phoneNumber,
            'drivGender': gender,
            'busNumber': busNumber,
            'busName': busName,
            'busRoute': route,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          onSuccess();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: $e')),
          );
        }
      }
    }
  }
}