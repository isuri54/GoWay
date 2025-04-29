import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/views/user_editing_controller.dart';

class UserEditing extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const UserEditing({super.key, this.onProfileUpdated});

  @override
  _UserEditingState createState() => _UserEditingState();
}

class _UserEditingState extends State<UserEditing> {
  final fullNameController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final birthdayController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final UserEditingBackend _backend;

  @override
  void initState() {
    super.initState();
    _backend = UserEditingBackend(
      context: context,
      onUserDataLoaded: (data) {
        setState(() {
          fullNameController.text = data['name'] ?? '';
          addressController.text = data['address'] ?? '';
          emailController.text = data['email'] ?? '';
          birthdayController.text = data['birthday'] ?? '';
          phoneNumberController.text = data['phoneNumber'] ?? '';
          _backend.gender = data['gender'] ?? 'Female';
        });
      },
      onLoadingUpdated: (isLoading) {
        setState(() {
          _backend.isLoading = isLoading;
        });
      },
    );
    _backend.loadUserData();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    addressController.dispose();
    emailController.dispose();
    birthdayController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Edit Profile", style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.iconTheme?.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Full Name", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: fullNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16.0),
              Text("Address", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16.0),
              Text("Email", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16.0),
              Text("Birthday", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: birthdayController,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16.0),
              Text("Phone Number", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: phoneNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length != 10) {
                    return 'Please enter exactly 10 digits';
                  }
                  return null;
                },
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16.0),
              Text("Gender", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Radio<String>(
                    value: "Female",
                    groupValue: _backend.gender,
                    onChanged: null,
                    activeColor: Colors.grey,
                  ),
                  Text("Female", style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(width: 20.0),
                  Radio<String>(
                    value: "Male",
                    groupValue: _backend.gender,
                    onChanged: null,
                    activeColor: Colors.grey,
                  ),
                  Text("Male", style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
              const SizedBox(height: 24.0),
              Center(
                child: _backend.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _backend.saveProfile(
                              fullName: fullNameController.text,
                              address: addressController.text,
                              email: emailController.text,
                              phoneNumber: phoneNumberController.text,
                            );
                            if (_backend.saveSuccessful) {
                              widget.onProfileUpdated?.call();
                              Navigator.pop(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                        ),
                        child: Text(
                          "Save",
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}