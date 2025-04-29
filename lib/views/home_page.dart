import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _currentIndex = 0; // Track the current index for the footer
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // Search bar
  String? _userGender; // To store the user's gender
  String? _userName; // To store the user's name
  String? _errorMessage;

  final List<SearchableItem> _searchableItems = [
    SearchableItem(
      title: 'Bus Tracking',
      description: 'Track your bus in real-time',
      icon: Icons.directions_bus,
      route: '/bus-tracking',
    ),
    SearchableItem(
      title: 'Select Bus',
      description: 'Check bus schedules',
      icon: Icons.schedule,
      route: '/time-table',
    ),
    SearchableItem(
      title: 'Seats booking',
      description: 'Book your seat in advance',
      icon: Icons.event_seat,
      route: '/seats-booking',
    ),
    SearchableItem(
      title: 'Complaints',
      description: 'Submit your complaints',
      icon: Icons.report_problem,
      route: '/complaints',
    ),
    SearchableItem(
      title: 'Emergency',
      description: 'Emergency contacts and help',
      icon: Icons.emergency,
      route: '/emergency',
    ),
    SearchableItem(
      title: 'Settings',
      description: 'App settings and preferences',
      icon: Icons.settings,
      route: '/settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the page loads
  }

  // Backend: Fetch the user's name and gender from Firestore
  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          setState(() {
            _userName = data['username'] ?? 'Guest'; // Fallback to 'Guest' if username is missing
            _userGender = data['gender'] ?? 'Female'; // Default to Female if gender is not set
          });
        } else {
          // If no document exists, set default values
          setState(() {
            _userName = 'Guest';
            _userGender = 'Female';
          });
        }
      } else {
        setState(() {
          _userName = 'Guest';
          _userGender = 'Female';
          _errorMessage = 'No user logged in';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _userName = 'Error';
        _userGender = 'Female';
        _errorMessage = 'Failed to load user data: $e';
      });
    }
  }

  // Frontend: Function to handle footer navigation
  void _onFooterTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Home
        break;
      case 1: // Seats
        Navigator.pushNamed(context, '/seats-booking');
        break;
      case 2: // QR
        Navigator.pushNamed(context, '/qr-scanner');
        break;
      case 3: // Wallet
        Navigator.pushNamed(context, '/wallet');
        break;
      case 4: // Profile
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Frontend: Determine the profile image based on gender
    ImageProvider profileImage;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.photoURL != null && user.photoURL!.isNotEmpty) {
      profileImage = NetworkImage(user.photoURL!); // Use Firebase photo if available
    } else {
      profileImage = _userGender == 'Male'
          ? const AssetImage('assets/male-user.png')
          : const AssetImage('assets/female-user.png');
    }

    // Frontend: Build the UI
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _searchFocusNode.unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_errorMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                ],
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', height: 100),
                      const SizedBox(height: 10),
                      const Text('Your Journey, Your Way!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome, $_userName!',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(user?.email ?? 'No email',
                            style: const TextStyle(fontSize: 18, color: Colors.black54)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      child: CircleAvatar(
                        backgroundImage: profileImage, // Dynamic image based on gender
                        radius: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[300],
                  ),
                  onChanged: (query) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: _searchableItems
                        .where((item) =>
                            item.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                            item.description.toLowerCase().contains(_searchController.text.toLowerCase()))
                        .map((item) => _buildFeatureButton(context, item))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _buildActiveButton(context, 'GoPay', Icons.account_balance_wallet, '/wallet')),
                    const SizedBox(width: 20),
                    Expanded(child: _buildActiveButton(context, 'User Points', Icons.star, '/my_rewards')),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _buildActiveButton(context, 'Guidelines', Icons.directions_bus, '/guidline_page')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onFooterTapped,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event_seat), label: 'Seats'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Frontend: Build feature button widget
  Widget _buildFeatureButton(BuildContext context, SearchableItem item) {
    return GestureDetector(
      onTap: () {
        try {
          Navigator.pushNamed(context, item.route);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error navigating to ${item.title}: $e')),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFDE05),
            radius: 30,
            child: Icon(item.icon, color: Colors.black),
          ),
          const SizedBox(height: 10),
          Text(item.title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // Frontend: Build active button widget
  Widget _buildActiveButton(
    BuildContext context,
    String label,
    IconData icon,
    String route,
  ) {
    return GestureDetector(
      onTap: () {
        try {
          Navigator.pushNamed(context, route);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error navigating to $label: $e')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 189, 240, 131),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color.fromARGB(255, 90, 85, 85), size: 24),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchableItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  SearchableItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });
}

// Backend: Function to register a user (can be called from a registration page)
Future<void> registerUser(String email, String password, String username, String gender) async {
  try {
    // Create user with email and password
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get the newly created user's UID
    String uid = userCredential.user!.uid;

    // Save user data to Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'username': username,
      'gender': gender,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('User registered successfully!');
  } catch (e) {
    print('Error during registration: $e');
    rethrow; // Throw the error to handle it in the UI if needed
  }
}