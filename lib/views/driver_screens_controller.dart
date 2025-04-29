import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/authcontroller.dart';
import 'package:get/get.dart';

class DriverLoginBackend {
  final BuildContext context;
  final AuthController controller = Get.find<AuthController>();

  DriverLoginBackend({required this.context});

  Future<AuthResult> handleLogin({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password.")),
      );
      return AuthResult(success: false);
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address.")),
      );
      return AuthResult(success: false);
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters long.")),
      );
      return AuthResult(success: false);
    }

    try {
      await controller.loginUser();
      if (controller.userCredential != null) {
        return AuthResult(success: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed. Please check your credentials.")),
        );
        return AuthResult(success: false);
      }
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('invalid-credential')) {
        errorMessage = "Invalid email or password. Please try again.";
      } else if (e.toString().contains('user-not-found')) {
        errorMessage = "No driver found with this email. Please register.";
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = "Incorrect password. Please try again.";
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = "Network error. Please check your internet connection.";
      } else {
        errorMessage = "An error occurred: ${e.toString()}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return AuthResult(success: false);
    }
  }
}

class AuthResult {
  final bool success;
  final bool isAdmin;

  AuthResult({required this.success, this.isAdmin = false});
}

class DriverRegisterBackend {
  final BuildContext context;
  final AuthController controller = Get.find<AuthController>();

  DriverRegisterBackend({required this.context});

  Future<AuthResult> handleRegister({
    required String email,
    required String password,
    required String name,
    required String mobile,
    required String address,
    required String nic,
    String? gender,
    DateTime? birthdate,
    String? busNumber,
    String? busName,
    String? route,
  }) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty || mobile.isEmpty || address.isEmpty || nic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return AuthResult(success: false);
    }

    if (busNumber == null || busName == null || route == null || busNumber.isEmpty || busName.isEmpty || route.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all bus details.")),
      );
      return AuthResult(success: false);
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address.")),
      );
      return AuthResult(success: false);
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters long.")),
      );
      return AuthResult(success: false);
    }

    if (gender == null || controller.selectedGender.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a gender.")),
      );
      return AuthResult(success: false);
    }

    if (birthdate == null || controller.selectedDate.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a birthdate.")),
      );
      return AuthResult(success: false);
    }

    try {
      await controller.signupUser(true);
      if (controller.userCredential != null) {
        return AuthResult(success: true);
      }
      return AuthResult(success: false);
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = "This email is already registered. Please use a different email.";
      } else if (e.toString().contains('weak-password')) {
        errorMessage = "Password is too weak. Please use a stronger password.";
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = "Network error. Please check your internet connection.";
      } else {
        errorMessage = "An error occurred: ${e.toString()}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return AuthResult(success: false);
    }
  }
}

