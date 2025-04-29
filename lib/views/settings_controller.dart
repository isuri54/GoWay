import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

class SettingsScreenBackend {
  String? userName;
  String? gender;
  bool isLoading = true;
  bool themeLoaded = false;
  final BuildContext context;
  final void Function(String?, String?, bool) onUserDataUpdated;

  SettingsScreenBackend({
    required this.context,
    required this.onUserDataUpdated,
  });

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          userName = data['username'];
          gender = data['gender'] ?? 'Female';
          isLoading = false;
        } else {
          userName = null;
          gender = 'Female';
          isLoading = false;
        }
      } catch (e) {
        print('Error fetching user data: $e');
        userName = null;
        gender = 'Female';
        isLoading = false;
      }
    } else {
      userName = null;
      gender = 'Female';
      isLoading = false;
    }
    onUserDataUpdated(userName, gender, isLoading);
  }

  Future<void> loadThemePreference(ThemeProvider themeProvider) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final isDarkMode = userDoc.data()!['isDarkMode'] ?? false;
          if (isDarkMode) {
            themeProvider.toggleTheme();
          }
        }
      } catch (e) {
        print('Error loading theme preference: $e');
      }
    }
  }

  Future<void> saveThemePreference(bool isDarkMode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'isDarkMode': isDarkMode}, SetOptions(merge: true));
      } catch (e) {
        print('Error saving theme preference: $e');
      }
    }
  }

  Future<void> handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }
}