import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/userProfile_controller.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Future<UserProfileData?> _userDataFuture;
  late final UserProfileBackend _backend;

  @override
  void initState() {
    super.initState();
    _backend = UserProfileBackend();
    _fetchUserData();
  }

  void _fetchUserData() {
    _userDataFuture = _backend.fetchUserData();
  }

  void navigateToEditProfile(BuildContext context) {
    Navigator.pushNamed(context, '/edit_profile').then((_) {
      setState(() {
        _fetchUserData();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfileData?>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error loading profile: ${snapshot.error}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/male-user.png'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    snapshot.data?.name ?? 'Not Provided',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Profile data not found.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          );
        }

        final userData = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text('Profile', style: Theme.of(context).appBarTheme.titleTextStyle),
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).appBarTheme.iconTheme?.color),
                onPressed: () => navigateToEditProfile(context),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: userData.profileImage,
                      ),
                      const SizedBox(height: 8),
                      Text(userData.name, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Full Name', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(userData.name, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    Text('Address', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(userData.address, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    Text('E-mail', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(userData.email, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    Text('Phone Number', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(userData.phone, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    Text('Birthday', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(userData.birthday, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    Text('Gender', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(userData.gender, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}