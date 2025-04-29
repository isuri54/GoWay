import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Ensure this is imported

class CustomerSupportScreen extends StatelessWidget {
  const CustomerSupportScreen({super.key});

  // Function to launch the phone dialer
  Future<void> _launchPhoneDialer(String phoneNumber, BuildContext context) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      // Check if the device can launch the URI
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        print('Dialer launched successfully for $phoneNumber');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone dialer is not available on this device')),
        );
        print('Cannot launch dialer: $phoneUri');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching dialer: $e')),
      );
      print('Error: $e');
    }
  }

  // Optional: Function to launch email client
  Future<void> _launchEmail(String email, BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        print('Email client launched successfully for $email');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email client is not available on this device')),
        );
        print('Cannot launch email: $emailUri');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching email: $e')),
      );
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6F5), // Light purple background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: const Text(
          'Customer Support',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Need Help?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Contact our support team for assistance. We’re here to help you 24/7.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                _launchEmail('support@example.com', context); // Replace with your support email
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              icon: const Icon(Icons.email, color: Colors.white),
              label: const Text(
                'Email Support',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _launchPhoneDialer('+94123456789', context); // Replace with your support number
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              icon: const Icon(Icons.phone, color: Colors.white),
              label: const Text(
                'Call Support',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}