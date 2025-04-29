import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileBackend {
  Future<UserProfileData?> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return null;
      }

      final doc = await FirebaseFirestore.instance.collection('drivers').doc(user.uid).get();
      if (!doc.exists) {
        return UserProfileData(
          name: user.displayName ?? 'Not Provided',
          address: 'Not Provided',
          email: user.email ?? 'Not Provided',
          phone: 'Not Provided',
          gender: 'Not Provided',
          birthday: 'Not Provided',
          profileImage: const AssetImage('assets/male-user.png'),
        );
      }

      final userData = doc.data() as Map<String, dynamic>;
      final String name = userData['name'] ?? user.displayName ?? 'Not Provided';
      final String address = userData['address'] ?? 'Not Provided';
      final String email = user.email ?? userData['email'] ?? 'Not Provided';
      final String phone = userData['phoneNumber'] ?? 'Not Provided';
      final String gender = userData['gender'] ?? 'Not Provided';
      final String birthday = userData['birthday'] ?? 'Not Provided';

      ImageProvider profileImage;
      if (user.photoURL != null) {
        profileImage = NetworkImage(user.photoURL!);
      } else {
        profileImage = gender == 'Male'
            ? const AssetImage('assets/male-user.png')
            : const AssetImage('assets/female-user.png');
      }

      return UserProfileData(
        name: name,
        address: address,
        email: email,
        phone: phone,
        gender: gender,
        birthday: birthday,
        profileImage: profileImage,
      );
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }
}

class UserProfileData {
  final String name;
  final String address;
  final String email;
  final String phone;
  final String gender;
  final String birthday;
  final ImageProvider profileImage;

  UserProfileData({
    required this.name,
    required this.address,
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthday,
    required this.profileImage,
  });
}