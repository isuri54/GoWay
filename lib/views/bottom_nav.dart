import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomFooter({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFFFDE05),
      unselectedItemColor: Colors.black54,
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index);
        switch (index) {
          case 0:
            Get.offAllNamed('/userhome');
            break;
          case 1:
            Get.offAllNamed('/seats-booking');
            break;
          case 2:
            Get.offAllNamed('/qr'); // Navigate to QrHome
            break;
          case 3:
            Get.offAllNamed('/wallet');
            break;
          case 4:
            Get.offAllNamed('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.event_seat), label: 'Seats'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'QrHome'),
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}