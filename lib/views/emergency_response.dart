import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/emergency_response_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

// Placeholder for other screens
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Home Page')));
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Login Page')));
}

class PreviousEmergencyAlertsPage extends StatelessWidget {
  const PreviousEmergencyAlertsPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Previous Alerts')));
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.hasData ? const EmergencyResponsePage() : const LoginPage();
      },
    );
  }
}

class EmergencyResponsePage extends StatefulWidget {
  const EmergencyResponsePage({super.key});

  @override
  _EmergencyResponsePageState createState() => _EmergencyResponsePageState();
}

class _EmergencyResponsePageState extends State<EmergencyResponsePage> {
  late final EmergencyResponseBackend _backend;
  late GoogleMapController mapController;
  LatLng _center = const LatLng(6.9271, 79.8612);
  int _currentIndex = 0;
  OverlayEntry? _overlayEntry;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _backend = EmergencyResponseBackend(context: context);
    _backend.getCurrentLocation().then((position) {
      if (position != null && mounted) {
        setState(() {
          _center = LatLng(position.latitude, position.longitude);
        });
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(target: _center, zoom: 14.0)),
        );
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: _center, zoom: 14.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          ),
        ),
        title: const Text('Emergency Response'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(target: _center, zoom: 14.0),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  liteModeEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  buildingsEnabled: false,
                  trafficEnabled: false,
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.red[100],
                    child: ListTile(
                      leading: const Icon(Icons.error, color: Colors.red),
                      title: Text(_errorMessage!),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _errorMessage = null),
                      ),
                    ),
                  ),
                ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.green[100],
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(_successMessage!),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _successMessage = null),
                      ),
                    ),
                  ),
                ),
              FutureBuilder<Map<String, String>?>(
                future: _backend.fetchUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('Failed to load user data')),
                    );
                  }
                  final userData = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('My Name', userData['name']!),
                        const SizedBox(height: 10),
                        _buildInfoRow('NIC', userData['nic']!),
                        const SizedBox(height: 10),
                        _buildInfoRow('Bus Number', userData['busNumber']!),
                        const SizedBox(height: 10),
                        _buildInfoRow('Bus Name', userData['busName']!),
                      ],
                    ),
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _backend.getRecentAlerts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading alerts'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No emergency alerts'));
                  }
                  final alerts = snapshot.data!.docs;
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: alerts.length,
                        itemBuilder: (context, index) {
                          final alert = alerts[index].data() as Map<String, dynamic>;
                          final timestamp = (alert['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              title: Text('Emergency: ${alert['type']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Name: ${alert['name']}'),
                                  Text('Bus: ${alert['busName']} (${alert['busNumber']})'),
                                  Text('Location: Lat: ${alert['location'].latitude}, Lng: ${alert['location'].longitude}'),
                                  Text('Time: ${timestamp.toString()}'),
                                ],
                              ),
                              leading: Icon(
                                alert['type'] == 'Accident'
                                    ? Icons.car_crash
                                    : alert['type'] == 'Fire Emergency'
                                        ? Icons.local_fire_department
                                        : Icons.local_police,
                                color: Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PreviousEmergencyAlertsPage()),
                          ),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFDE05)),
                          child: const Text('View Previous Alerts', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ],
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 1, blurRadius: 5),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildEmergencyButton('Accident', Icons.car_crash, () => _showAnimatedWarning('Accident')),
                    _buildEmergencyButton('Fire Emergency', Icons.local_fire_department, () => _showAnimatedWarning('Fire Emergency')),
                    _buildEmergencyButton('Call Police', Icons.local_police, _backend.openDialer),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFFDE05),
        unselectedItemColor: Colors.black54,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index >= 0 && index < 5) {
            setState(() => _currentIndex = index);
            switch (index) {
              case 0:
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                break;
              case 1:
                Navigator.pushNamed(context, '/seats-booking');
                break;
              case 2:
                Navigator.pushNamed(context, '/qr-scanner');
                break;
              case 3:
                Navigator.pushNamed(context, '/wallet');
                break;
              case 4:
                Navigator.pushNamed(context, '/profile');
                break;
            }
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.location_pin), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Seats'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'QR'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _buildEmergencyButton(String label, IconData icon, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(color: Color(0xFFFFDE05), shape: BoxShape.circle),
            child: Center(child: Icon(icon, color: Colors.red, size: 30)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  void _showAnimatedWarning(String type) {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => AnimatedWarningMessage(
        type: type,
        onClose: _removeOverlay,
        onProceed: () async {
          final result = await _backend.sendEmergencyAlert(type);
          if (mounted) {
            setState(() {
              _errorMessage = result.errorMessage;
              _successMessage = result.successMessage;
            });
          }
          _removeOverlay();
        },
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }
}

class AnimatedWarningMessage extends StatefulWidget {
  final String type;
  final VoidCallback onClose;
  final VoidCallback onProceed;

  const AnimatedWarningMessage({
    super.key,
    required this.type,
    required this.onClose,
    required this.onProceed,
  });

  @override
  _AnimatedWarningMessageState createState() => _AnimatedWarningMessageState();
}

class _AnimatedWarningMessageState extends State<AnimatedWarningMessage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _offsetAnimation = Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _offsetAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Warning!!!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Icon(Icons.error_outline, color: Colors.red, size: 50),
                      const SizedBox(height: 10),
                      Text(
                        'Are you sure you want to trigger an emergency alert for ${widget.type}?',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Note: By proceeding, your location, personal information, and vehicle details will be automatically sent to the respective emergency department. False alerts may result in penalties.',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _controller.reverse().then((_) => widget.onClose()),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFDE05)),
                            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              widget.onProceed();
                              _controller.reverse().then((_) => widget.onClose());
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFDE05)),
                            child: const Text('Proceed', style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}