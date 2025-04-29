// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'dart:ui';

// class ConfirmationBottomSheet extends StatefulWidget {
//   final String from;
//   final String to;
//   final double distance;
//   final String total;
//   final String clientSecret;

//   const ConfirmationBottomSheet({
//     required this.from,
//     required this.to,
//     required this.distance,
//     required this.total,
//     required this.clientSecret,
//     super.key,
//   });

//   @override
//   _ConfirmationBottomSheetState createState() => _ConfirmationBottomSheetState();
// }

// class _ConfirmationBottomSheetState extends State<ConfirmationBottomSheet> {
//   bool isProcessing = false;

//   @override
//   void initState() {
//     super.initState();
//     Stripe.publishableKey = 'pk_test_your_stripe_publishable_key';
//   }

//   Future<void> _confirmPayment() async {
//     setState(() => isProcessing = true);
//     try {
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: widget.clientSecret,
//           merchantDisplayName: 'QR Payment App',
//           style: ThemeMode.system,
//         ),
//       );

//       await Stripe.instance.presentPaymentSheet();

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Payment Successful')),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Payment Failed: $e')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => isProcessing = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned.fill(
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//             child: Container(
//               color: Colors.black.withOpacity(0.2),
//             ),
//           ),
//         ),
//         DraggableScrollableSheet(
//           initialChildSize: 0.4,
//           minChildSize: 0.3,
//           maxChildSize: 0.5,
//           builder: (_, scrollController) {
//             return Container(
//               padding: const EdgeInsets.all(20.0),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: SingleChildScrollView(
//                 controller: scrollController,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           "Confirmation",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     _buildDetailRow("From", widget.from),
//                     const SizedBox(height: 5),
//                     _buildDetailRow("To", widget.to),
//                     const SizedBox(height: 5),
//                     _buildDetailRow(
//                         "Distance", "${widget.distance.toStringAsFixed(1)} km"),
//                     const SizedBox(height: 10),
//                     _buildDetailRow("Total", widget.total, isTotal: true),
//                     const SizedBox(height: 20),
//                     Center(
//                       child: isProcessing
//                           ? const CircularProgressIndicator()
//                           : ElevatedButton(
//                               onPressed: _confirmPayment,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.yellow,
//                                 foregroundColor: Colors.black,
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 20, vertical: 12),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 minimumSize: const Size(double.infinity, 50),
//                               ),
//                               child: const Text(
//                                 "Confirm Payment",
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontSize: 16),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//             color: isTotal ? Colors.green[700] : Colors.black,
//           ),
//         ),
//       ],
//     );
//   }
// }