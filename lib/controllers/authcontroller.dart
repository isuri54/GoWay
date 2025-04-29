import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/views/driver_home.dart';
import 'package:flutter_application_1/views/home_page.dart';
import 'package:flutter_application_1/views/spashscreen.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController();
  var passwordController = TextEditingController();
  UserCredential? userCredential;

  // For users
  var addressController = TextEditingController();
  var nicController = TextEditingController();
  var selectedGender = RxnString();
  var selectedDate = Rxn<DateTime>();
  var selectedRoute = RxnString();

  // For drivers
  var busNumberController = TextEditingController();
  var busNameController = TextEditingController();
  // var routeController = TextEditingController();

  void updateGender(String gender) {
    selectedGender.value = gender;
  }

  void updateRoute(String route) {
    selectedRoute.value = route;
  }

  void updateDate(DateTime date) {
    selectedDate.value = date;
  }

  isUserAlreadyLoggedIn() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        try {
          var driverDoc = await FirebaseFirestore.instance.collection('drivers').doc(user.uid).get();
          var isDriver = driverDoc.exists && (driverDoc.data()?.containsKey('drivName') ?? false);

          if (isDriver) {
            Get.offAll(() => const DriverHomePage());
          } else {
            var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
            if (userDoc.exists) {
              Get.offAll(() => const UserHomePage());
            } else {
              
              await FirebaseAuth.instance.signOut();
              Get.offAll(() => const SplashScreen());
            }
          }
        } catch (e) {
          print("Error checking user role: $e");
          await FirebaseAuth.instance.signOut();
          Get.offAll(() => const SplashScreen());
        }
      } else {
        Get.offAll(() => const SplashScreen());
      }
    });
  }

  loginUser() async {
    userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
  }

  signupUser(bool isDriver) async {
    userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
    await storeUserData(
      userCredential!.user!.uid,
      nameController.text,
      emailController.text,
      mobileController.text,
      addressController.text,
      nicController.text,
      selectedGender.value ?? "Not Specified",
      selectedDate.value ?? DateTime(2000, 1, 1),
      isDriver,
      busNumberController.text,
      busNameController.text,
      selectedRoute.value ?? "-",
    );
  }

  storeUserData(
    String uid,
    String name,
    String email,
    String mobile,
    String address,
    String nic,
    String gender,
    DateTime birthdate,
    bool isDriver,
    [String busNumber = '',
    String busName = '',
    String route = '']
  ) async {
    var store = FirebaseFirestore.instance.collection(isDriver ? 'drivers' : 'users').doc(uid);
    if (isDriver) {
      await store.set({
        'drivName': name,
        'drivMobile': mobile,
        'drivEmail': email,
        'drivId': FirebaseAuth.instance.currentUser?.uid,
        'drivAddress': address,
        'drivNic': nic,
        'drivGender': gender,
        'drivBirthdate': birthdate,
        'busNumber': busNumber,
        'busName': busName,
        'busRoute': route,
      });
    } else {
      await store.set({
        'email': email,
        'mobile': mobile,
        'name': name,
        'address': address,
        'nic': nic,
        'gender': gender,
        'birthdate': birthdate,
      });
    }
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}