import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/main.dart'; // Import ThemeProvider from main.dart

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 4; // Set to 4 for the profile/settings tab
  String? gender;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadThemePreference();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          setState(() {
            gender = data['gender'] ?? 'Female';
            _isLoading = false;
          });
        } else {
          setState(() {
            gender = 'Female';
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
        setState(() {
          gender = 'Female';
          _isLoading = false;
          _errorMessage = 'Failed to load user data: $e';
        });
      }
    } else {
      setState(() {
        gender = 'Female';
        _isLoading = false;
        _errorMessage = 'No user logged in';
      });
    }
  }

  Future<void> _loadThemePreference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final isDarkMode = userDoc.data()!['isDarkMode'] ?? false;
          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
          if (isDarkMode != themeProvider.isDarkMode) {
            themeProvider.toggleTheme();
          }
        }
      } catch (e) {
        print('Error loading theme preference: $e');
        setState(() {
          _errorMessage = 'Failed to load theme preference: $e';
        });
      }
    }
  }

  Future<void> _saveThemePreference(bool isDarkMode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'isDarkMode': isDarkMode}, SetOptions(merge: true));
      } catch (e) {
        print('Error saving theme preference: $e');
        setState(() {
          _errorMessage = 'Failed to save theme preference: $e';
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  void _onFooterTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/userhome');
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
        // Already on settings/profile page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Determine the image to display
    Widget profileImage;
    if (user != null && user.photoURL != null && user.photoURL!.isNotEmpty) {
      profileImage = CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(user.photoURL!),
        onBackgroundImageError: (error, stackTrace) {
          print('Error loading profile image: $error');
          setState(() {
            _errorMessage = 'Failed to load profile image: $error';
          });
        },
      );
    } else {
      profileImage = CircleAvatar(
        radius: 50,
        child: Image.asset(
          gender == 'Male' ? 'assets/male-user.png' : 'assets/female-user.png',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, size: 50, color: Colors.red);
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.iconTheme?.color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
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
                  const SizedBox(height: 20),
                  profileImage, // Use the determined profile image
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SettingsOption(
                          icon: Icons.edit,
                          text: "Edit Profile",
                          onTap: () {
                            Navigator.pushNamed(context, '/edit_profile');
                          },
                        ),
                        SettingsOption(
                          icon: Icons.payment,
                          text: "Payments",
                          onTap: () {
                            Navigator.pushNamed(context, '/wallet');
                          },
                        ),
                        SettingsOption(
                          icon: Icons.headset_mic,
                          text: "Customer Support",
                          onTap: () {
                            Navigator.pushNamed(context, '/customer_support');
                          },
                        ),
                        SettingsOption(
                          icon: Icons.card_giftcard,
                          text: "My Rewards",
                          onTap: () {
                            Navigator.pushNamed(context, '/my_rewards');
                          },
                        ),
                        SettingsOption(
                          icon: Icons.sos,
                          text: "SOS",
                          iconColor: Colors.red,
                          onTap: () {
                            Navigator.pushNamed(context, '/sos');
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                color: Colors.black,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              themeProvider.isDarkMode ? "Light Mode" : "Dark Mode",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            trailing: Switch(
                              value: themeProvider.isDarkMode,
                              activeColor: Colors.amber,
                              onChanged: (value) {
                                themeProvider.toggleTheme();
                                _saveThemePreference(themeProvider.isDarkMode);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 180,
                              child: ElevatedButton(
                                onPressed: _handleLogout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("LOG OUT"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: CustomFooter(
        currentIndex: _currentIndex,
        onTap: _onFooterTapped,
      ),
    );
  }
}

class SettingsOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final VoidCallback? onTap;

  const SettingsOption({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = Colors.amber,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.black, size: 18),
        ),
        title: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

class CustomFooter extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomFooter({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.amber,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.event_seat), label: 'Seats'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}