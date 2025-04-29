import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/controllers/authcontroller.dart';
import 'package:get/get.dart';

class DriverProfileBackend {
  Future<DocumentSnapshot> getDriverData(String uid) async {
    return await FirebaseFirestore.instance.collection('drivers').doc(uid).get();
  }

  void signOut() async {
    final AuthController authController = Get.find<AuthController>();
    await authController.signOut();
    print('Log out button pressed');
    Get.offAllNamed('/SplashScreen');
  }
}