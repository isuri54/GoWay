import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/driverProfile_controller.dart';

class DriverProfile extends StatelessWidget {
  const DriverProfile({super.key});

  void navigatetodriveredit(BuildContext context) {
    Navigator.pushNamed(context, '/driveredit');
  }

  @override
  Widget build(BuildContext context) {
    final backend = DriverProfileBackend();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No driver logged in. Please log in to view your profile.'),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: backend.getDriverData(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error loading profile: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Profile data not found.')),
          );
        }

        final driverData = snapshot.data!.data() as Map<String, dynamic>;
        final String name = driverData['drivName'] ?? 'Not Provided';
        final String address = driverData['drivAddress'] ?? 'Not Provided';
        final String email = driverData['drivEmail'] ?? 'Not Provided';
        final String nic = driverData['drivNic'] ?? 'Not Provided';
        final String mobile = driverData['drivMobile'] ?? 'Not Provided';
        final String gender = driverData['drivGender'] ?? 'Not Provided';
        final DateTime birthdate = (driverData['drivBirthdate'] as Timestamp?)?.toDate() ?? DateTime(2000, 1, 1);
        final String birthdateString = '${birthdate.day}/${birthdate.month}/${birthdate.year}';
        final String busNumber = driverData['busNumber'] ?? 'Not Provided';
        final String busName = driverData['busName'] ?? 'Not Provided';
        final String route = driverData['busRoute'] ?? 'Not Provided';

        ImageProvider profileImage;
        if (gender == 'Male') {
          profileImage = const AssetImage('assets/male-user.png');
        } else if (gender == 'Female') {
          profileImage = const AssetImage('assets/female-user.png');
        } else {
          profileImage = const AssetImage('assets/profile.jpg');
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Driver Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  navigatetodriveredit(context);
                  print('Pencil icon pressed - navigated to edit page');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: profileImage,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Personal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Full Name',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        name,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Address',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        address,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'E-mail',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'ID',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        nic,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Birthdate',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        birthdateString,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tel No',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        mobile,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Gender',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        gender,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Bus Detail',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bus Number',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        busNumber,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Bus Name',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        busName,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Route',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        route,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      onPressed: () {
                        backend.signOut();
                      },
                      child: const Text(
                        'LOG OUT',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}