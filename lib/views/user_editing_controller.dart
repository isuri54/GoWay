import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserEditingBackend {
  String? gender;
  bool isLoading = false;
  bool saveSuccessful = false;
  final BuildContext context;
  final void Function(Map<String, String?>) onUserDataLoaded;
  final void Function(bool) onLoadingUpdated;

  UserEditingBackend({
    required this.context,
    required this.onUserDataLoaded,
    required this.onLoadingUpdated,
  });

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    Map<String, String?> data = {
      'name': '',
      'address': '',
      'email': '',
      'birthday': '',
      'phoneNumber': '',
      'gender': 'Female',
    };

    if (user != null) {
      data['name'] = user.displayName ?? '';
      data['email'] = user.email ?? '';

      final driverDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (driverDoc.exists) {
        final docData = driverDoc.data()!;
        data['name'] = docData['name'] ?? data['name'];
        data['address'] = docData['address'] ?? '';
        data['birthday'] = docData['birthday'] ?? '';
        data['phoneNumber'] = docData['phoneNumber'] ?? '';
        data['gender'] = docData['gender'] ?? 'Female';
        gender = data['gender'];
      }
    }

    onUserDataLoaded(data);
  }

  Future<void> saveProfile({
    required String fullName,
    required String address,
    required String email,
    required String phoneNumber,
  }) async {
    isLoading = true;
    onLoadingUpdated(true);
    saveSuccessful = false;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Update Firebase Authentication
      if (fullName != user.displayName) {
        await user.updateDisplayName(fullName);
      }
      if (email != user.email) {
        await user.updateEmail(email);
      }

      // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': fullName,
        'address': address,
        'email': email,
        'phoneNumber': phoneNumber,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      saveSuccessful = true;
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('requires-recent-login')) {
        errorMessage = 'This operation requires recent authentication. Please log out and log in again.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'The email address is invalid.';
      } else {
        errorMessage = 'Error updating profile: $e';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      isLoading = false;
      onLoadingUpdated(false);
    }
  }
}