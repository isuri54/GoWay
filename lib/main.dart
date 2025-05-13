import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/views/admin_page.dart';
import 'package:flutter_application_1/views/bus_timetable.dart';
import 'package:flutter_application_1/views/bus_tracking.dart';
import 'package:flutter_application_1/views/complaints.dart';
import 'package:flutter_application_1/views/credit_card_form.dart';
import 'package:flutter_application_1/views/customer_support_screen.dart';
import 'package:flutter_application_1/views/driverProfile.dart';
import 'package:flutter_application_1/views/driver_editing.dart';
import 'package:flutter_application_1/views/driver_home.dart';
import 'package:flutter_application_1/views/driver_login.dart';
import 'package:flutter_application_1/views/driver_registration.dart';
import 'package:flutter_application_1/views/driver_wallet.dart';
import 'package:flutter_application_1/views/emergency_response.dart';
import 'package:flutter_application_1/views/guidline_page.dart';
import 'package:flutter_application_1/views/home_page.dart';
import 'package:flutter_application_1/views/my_rewards_screen.dart';
import 'package:flutter_application_1/views/payment_success_screen.dart';
import 'package:flutter_application_1/views/qrhome.dart';
import 'package:flutter_application_1/views/seat_booking.dart';
import 'package:flutter_application_1/views/settings.dart';
import 'package:flutter_application_1/views/sos_screen.dart';
import 'package:flutter_application_1/views/spashscreen.dart';
import 'package:flutter_application_1/views/top_up_page.dart';
import 'package:flutter_application_1/views/userProfile.dart';
import 'package:flutter_application_1/views/user_editing.dart';
import 'package:flutter_application_1/views/user_login.dart';
import 'package:flutter_application_1/views/user_manual_page.dart';
import 'package:flutter_application_1/views/wallet_history_screen.dart';
import 'package:flutter_application_1/views/wallet_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const GoWayApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode ? darkTheme : lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.amber,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
      labelLarge: TextStyle(color: Colors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(255, 214, 75, 1),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      labelStyle: TextStyle(color: Colors.black54),
      hintStyle: TextStyle(color: Colors.grey),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.amber,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      labelLarge: TextStyle(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(255, 214, 75, 1),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      labelStyle: TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.grey),
    ),
  );
}

class GoWayApp extends StatelessWidget {
  const GoWayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          home: const SplashScreen(),
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/userlogin': (context) => const UserLoginScreen(),
            '/userhome': (context) => const UserHomePage(),
            '/driverlogin': (context) => const DriverLoginScreen(),
            '/driverregister': (context) => const DriverRegisterScreen(),
            '/driverhome': (context) => const DriverHomePage(),
            '/driverwallet': (context) => const DriverWallet(),
            '/driverprofile': (context) => const DriverProfile(),
            '/driveredit': (context) => const DriverEditing(),
            '/bus-tracking': (context) => const BusTrackingPage(busId: '',),
            '/time-table': (context) => const TimeTablePage(),
            '/seats-booking': (context) => const SeatBookingScreen(),
            '/complaints': (context) => const ComplainWarning(),
            '/emergency': (context) => const EmergencyResponsePage(),
            '/settings': (context) => ChangeNotifierProvider.value(
                  value: Provider.of<ThemeProvider>(context, listen: false),
                  child: const SettingsScreen(),
                ),
            '/wallet': (context) {
              final args = ModalRoute.of(context)!.settings.arguments;
              double? bookingPrice;
              if (args is Map && args.containsKey('bookingPrice')) {
                bookingPrice = args['bookingPrice'] as double?;
              }
              return WalletPage(bookingPrice: bookingPrice);
            },
            '/profile': (context) => const UserProfile(),
            '/guidline_page': (context) => const HowToRidePage(),
            '/cardform': (context) => const CreditCardForm(),
            '/admin': (context) => const AdminPage(),
            '/edit_profile': (context) => const UserEditing(),
            '/customer_support': (context) => const CustomerSupportScreen(),
            '/my_rewards': (context) => const MyRewardsScreen(),
            '/sos': (context) => const SosScreen(),
            '/wallet-history': (context) =>
                const WalletHistoryScreen(transactions: []),
            '/payment-success': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map;
              return PaymentSuccessScreen(
                amount: args['amount'],
                bookingId: args['bookingId'],
              );
            },
            '/topup': (context) {
              final args = ModalRoute.of(context)!.settings.arguments;
              if (args is Map) {
                final cardNumber = args['cardNumber'] as String?;
                final cardHolderName = args['cardHolderName'] as String?;
                final expiryDate = args['expiryDate'] as String?;
                final cvv = args['cvv'] as String?;
                final requiredAmount = args['requiredAmount'] as double?;
                if (cardNumber == null || cardHolderName == null) {
                  return Scaffold(
                    body: Center(
                      child: Text(
                        'Error: Missing card details',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  );
                }
                return TopUpPage(
                  cardNumber: cardNumber,
                  cardHolderName: cardHolderName,
                  expiryDate: expiryDate,
                  cvv: cvv,
                  requiredAmount: requiredAmount,
                );
              }
              return Scaffold(
                body: Center(
                  child: Text(
                    'Error: Invalid arguments for top-up page',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              );
            },
            '/qr-scanner': (context) => const QrHome(),
            '/user-manual': (context) => const UserManualPage(),
          },
        );
      },
    );
  }
}