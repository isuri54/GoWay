import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/authcontroller.dart';
import 'package:flutter_application_1/views/user_screens_controller.dart';
import 'package:get/get.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  late final UserLoginBackend _backend;
  final AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _backend = UserLoginBackend(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 80),
            const SizedBox(height: 8),
            const Text("Your Journey, Your Way!",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            const Text(
              "Travel & Enjoy with the\nMost Reliable Public Transport",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLabeledTextField("Email", controller.emailController),
                  const SizedBox(height: 20),
                  buildLabeledTextField("Password", controller.passwordController, isPassword: true),
                  const SizedBox(height: 10),
                  Center(
                    child: SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async {
                          final result = await _backend.handleLogin(
                            email: controller.emailController.text.trim(),
                            password: controller.passwordController.text.trim(),
                          );
                          if (result.success) {
                            if (result.isAdmin) {
                              Navigator.pop(context);
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/admin',
                                (route) => false,
                              );
                            } else {
                              _showModalBottomSheetsuccess(context);
                            }
                          }
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/userregister');
                      },
                      child: const Text("Don't have an account? Create Account",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModalBottomSheetsuccess(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ListTile(
                title: Icon(Icons.check_circle, size: 70, color: Colors.green),
              ),
              ListTile(
                title: Center(
                  child: Text(
                    "Login Successful",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Center(
                  child: Text(
                    "Welcome back!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/userhome',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 214, 75, 1)),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "Home",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildLabeledTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    ValueNotifier<bool> obscureTextNotifier = ValueNotifier<bool>(isPassword);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<bool>(
          valueListenable: obscureTextNotifier,
          builder: (context, obscureText, child) {
            return TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          obscureTextNotifier.value = !obscureTextNotifier.value;
                        },
                      )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }
}