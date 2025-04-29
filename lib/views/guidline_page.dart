import 'package:flutter/material.dart';

class HowToRidePage extends StatelessWidget {
  const HowToRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDE05), // Yellow theme
        title: const Text(
          'Guidelines',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_bus,
                      size: 60,
                      color: Color(0xFFFFDE05),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Your Guide to Using the App',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Explore how to make your journey seamless!',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // App Features Section
              const Text(
                'Our System',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              _buildFeatureCard(
                context,
                icon: Icons.directions_bus,
                title: 'Bus Tracking',
                description: 'Track your bus in real-time to know exactly when it arrives.',
              ),
              _buildFeatureCard(
                context,
                icon: Icons.event_seat,
                title: 'Seat Booking',
                description: 'Reserve your seat in advance for a comfortable journey.',
              ),
              _buildFeatureCard(
                context,
                icon: Icons.qr_code,
                title: 'QR Scanner',
                description: 'Scan QR codes for quick ticket validation.',
              ),
              _buildFeatureCard(
                context,
                icon: Icons.account_balance_wallet,
                title: 'Wallet',
                description: 'Manage payments easily with our in-app wallet.',
              ),
              _buildFeatureCard(
                context,
                icon: Icons.report_problem,
                title: 'Complaints',
                description: 'Submit issues directly for quick resolution.',
              ),
              _buildFeatureCard(
                context,
                icon: Icons.emergency,
                title: 'Emergency',
                description: 'Access emergency contacts instantly when needed.',
              ),
              _buildFeatureCard(
                context,
                icon: Icons.settings,
                title: 'Settings',
                description: 'Customize your app experience with ease.',
              ),
              const SizedBox(height: 20),

              // Advantages Section
              const Text(
                'Why Use Our App?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              _buildAdvantageTile(
                context,
                'Real-Time Updates',
                'Stay informed with live bus tracking and schedule updates.',
              ),
              _buildAdvantageTile(
                context,
                'Hassle-Free Booking',
                'Book seats in seconds without standing in queues.',
              ),
              _buildAdvantageTile(
                context,
                'Quick Support',
                'Get instant help through complaints and emergency features.',
              ),
              _buildAdvantageTile(
                context,
                'User-Friendly',
                'Navigate the app effortlessly with a clean, intuitive design.',
              ),
              const SizedBox(height: 20),

              // Call to Action
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 189, 240, 131),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Start Your Journey',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Link to User Manual
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/user-manual'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFDE05),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'View User Manual',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build feature cards
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      color: const Color.fromARGB(255, 189, 240, 131),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 68, 67, 65), size: 30),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  // Helper method to build advantage tiles
  Widget _buildAdvantageTile(
    BuildContext context, String title, String description) {
    return ListTile(
      leading: const Icon(
        Icons.check_circle,
        color: Color(0xFFFFDE05),
        size: 30,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }
}