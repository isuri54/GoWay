import 'package:flutter/material.dart';

class UserManualPage extends StatelessWidget {
  const UserManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDE05), // Yellow theme
        title: const Text(
          'User Manual',
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
                      Icons.book,
                      size: 60,
                      color: Color(0xFFFFDE05),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'User Manual',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Step-by-step guide to mastering your journey!',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Manual Sections
              const Text(
                'How to Use the App',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              _buildManualSection(
                context,
                title: '1. Bus Tracking',
                steps: [
                  'Open the app and tap "Bus Tracking" from the home screen.',
                  'Select your bus route or enter the bus number.',
                  'View real-time location updates on the map.',
                  'Check estimated arrival times at your stop.',
                ],
              ),
              _buildManualSection(
                context,
                title: '2. Seat Booking',
                steps: [
                  'Tap "Seats booking" on the home screen.',
                  'Choose your bus and travel date.',
                  'Select your preferred seat from the seating chart.',
                  'Confirm payment via the in-app wallet.',
                  'Receive a booking confirmation with a QR code.',
                ],
              ),
              _buildManualSection(
                context,
                title: '3. QR Scanner',
                steps: [
                  'Tap "QR" from the bottom navigation bar.',
                  'Allow camera access to scan the ticket QR code.',
                  'Point your camera at the QR code provided by the conductor.',
                  'View ticket validation status instantly.',
                ],
              ),
              _buildManualSection(
                context,
                title: '4. Wallet',
                steps: [
                  'Tap "Wallet" from the bottom navigation or "GoPay" button.',
                  'Add funds using your preferred payment method.',
                  'View transaction history and balance.',
                  'Use wallet funds for seat bookings or other payments.',
                ],
              ),
              _buildManualSection(
                context,
                title: '5. Complaints',
                steps: [
                  'Tap "Complaints" from the home screen.',
                  'Describe your issue in the provided form.',
                  'Attach photos or screenshots if necessary.',
                  'Submit and track the status of your complaint.',
                ],
              ),
              _buildManualSection(
                context,
                title: '6. Emergency',
                steps: [
                  'Tap "Emergency" from the home screen.',
                  'Access a list of emergency contacts (e.g., police, transport authority).',
                  'Tap a contact to call directly from the app.',
                  'Use the SOS feature for immediate assistance if available.',
                ],
              ),
              _buildManualSection(
                context,
                title: '7. Settings',
                steps: [
                  'Tap "Settings" from the home screen.',
                  'Update your profile details (e.g., name, gender).',
                  'Adjust notification preferences.',
                  'Change app language or theme if supported.',
                ],
              ),
              const SizedBox(height: 20),

              // Tips Section
              const Text(
                'Tips for a Smooth Experience',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              _buildTipTile(
                context,
                'Keep Wallet Funded',
                'Ensure your wallet has sufficient funds for quick bookings.',
              ),
              _buildTipTile(
                context,
                'Enable Notifications',
                'Turn on notifications for real-time bus updates.',
              ),
              _buildTipTile(
                context,
                'Check Schedules',
                'Regularly check bus schedules to plan your trips.',
              ),
              const SizedBox(height: 20),

              // Back to Guidelines
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
                    'Back to Guidelines',
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

  // Helper method to build manual sections
  Widget _buildManualSection(
    BuildContext context, {
    required String title,
    required List<String> steps,
  }) {
    return Card(
      color: const Color.fromARGB(255, 189, 240, 131),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            ...steps.asMap().entries.map((entry) {
              int index = entry.key + 1;
              String step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$index. ',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Helper method to build tip tiles
  Widget _buildTipTile(BuildContext context, String title, String description) {
    return ListTile(
      leading: const Icon(
        Icons.lightbulb,
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