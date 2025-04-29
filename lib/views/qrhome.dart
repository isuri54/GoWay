import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/qr_controller.dart';
import 'package:flutter_application_1/views/admin_page.dart';
import 'package:flutter_application_1/views/home_page.dart';
import 'package:flutter_application_1/views/qr_scanner_screen.dart';

class QrHome extends StatefulWidget {
  const QrHome({super.key});

  @override
  _QrHomeState createState() => _QrHomeState();
}

class _QrHomeState extends State<QrHome> {
  late final QrHomeBackend _backend;
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  String scannedResult = "";
  double? distance;
  double totalFare = 0;
  double? routePrice;
  String userName = "";
  String gender = "male";
  String role = 'user';
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? bankDetails;
  double? walletBalance;
  bool isFetchingUser = true;

  @override
  void initState() {
    super.initState();
    _backend = QrHomeBackend(context: context);
    _backend.requestCameraPermission();
    _backend.fetchUserDetails().then((userDetails) {
      if (mounted) {
        setState(() {
          userName = userDetails.name;
          gender = userDetails.gender;
          walletBalance = userDetails.walletBalance;
          role = userDetails.role;
          isFetchingUser = false;
        });
      }
    });
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.6,
              builder: (_, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Payment Confirmation",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text("From: ${fromController.text.isEmpty ? 'N/A' : fromController.text}"),
                        Text("To: ${toController.text.isEmpty ? 'N/A' : toController.text}"),
                        if (distance != null)
                          Text("Distance: ${distance!.toStringAsFixed(2)} km"),
                        const SizedBox(height: 5),
                        Text(
                          "Total Fare: Rs. ${totalFare.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        if (bankDetails != null) ...[
                          const Text(
                            "Bank Details:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Bank: ${bankDetails!['bank']}"),
                          Text("Account Number: ${bankDetails!['account_number']}"),
                          Text("Branch: ${bankDetails!['branch']}"),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          "Wallet Balance: Rs. ${walletBalance?.toStringAsFixed(2) ?? '0.00'}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              final success = await _backend.processPayment(
                                totalFare,
                                fromController.text,
                                toController.text,
                                bankDetails,
                              );
                              if (success && mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Payment successful!')),
                                );
                                setState(() {
                                  scannedResult = "";
                                  bankDetails = null;
                                  walletBalance = walletBalance! - totalFare;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Confirm Payment",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = gender == 'female' ? 'assets/female-user.png' : 'assets/male-user.png';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserHomePage()),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/logo.png', height: 50),
                const SizedBox(height: 10),
                const Text(
                  "Your Journey, Your Way!",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: isFetchingUser
                          ? const Text(
                              'Loading...',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text(
                              userName.isEmpty ? 'Welcome, User!' : 'Welcome, $userName!',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    if (role == 'admin')
                      IconButton(
                        icon: const Icon(Icons.admin_panel_settings),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminPage()),
                        ),
                      ),
                    CircleAvatar(
                      backgroundImage: AssetImage(profileImage),
                      radius: 20,
                      onBackgroundImageError: (_, __) => setState(() => gender = 'male'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: fromController,
                  decoration: const InputDecoration(
                    hintText: "From (e.g., Galle, Sri Lanka)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: toController,
                  decoration: const InputDecoration(
                    hintText: "To (e.g., Colombo, Sri Lanka)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          setState(() => isLoading = true);
                          final result = await _backend.searchRoute(fromController.text, toController.text);
                          if (mounted) {
                            setState(() {
                              distance = result.distance;
                              routePrice = result.routePrice;
                              errorMessage = result.errorMessage;
                              isLoading = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text("Search Route", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (distance != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Distance: ${distance!.toStringAsFixed(2)} km",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        if (totalFare == 0)
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  totalFare = routePrice ?? 0;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Search Price", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        if (totalFare > 0) ...[
                          const SizedBox(height: 5),
                          Text(
                            "Ticket Price: Rs. ${totalFare.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                final scanResult = await _backend.openQRScanner(distance, totalFare);
                                if (scanResult != null && mounted) {
                                  setState(() {
                                    scannedResult = scanResult.rawResult;
                                    bankDetails = scanResult.bankDetails;
                                  });
                                  _showBottomSheet();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Scan QR to Pay", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final scanResult = await _backend.openQRScanner(distance, totalFare);
                          if (scanResult != null && mounted) {
                            setState(() {
                              scannedResult = scanResult.rawResult;
                              bankDetails = scanResult.bankDetails;
                            });
                            _showBottomSheet();
                          }
                        },
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        label: const Text("Open Scanner", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(200, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}