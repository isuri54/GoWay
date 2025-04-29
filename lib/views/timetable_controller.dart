import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/busController.dart';

class TimeTableBackend {
  final BuildContext context;
  final BusController _busController = BusController();

  TimeTableBackend({required this.context});

  Future<BusFetchResult> fetchBuses(String from, String to) async {
    final String from1 = from.trim().toUpperCase();
    final String to1 = to.trim().toUpperCase();
    final String route = "$from1-$to1";

    if (from1.isEmpty || to1.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both 'From' and 'To' locations")),
      );
      return BusFetchResult(buses: []);
    }

    try {
      List<Map<String, dynamic>> data = await _busController.getBusTimeTableByRoute(route);
      if (data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No buses found for route: $route")),
        );
      }
      return BusFetchResult(buses: data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching bus data: $e")),
      );
      return BusFetchResult(buses: []);
    }
  }
}

class BusFetchResult {
  final List<Map<String, dynamic>> buses;

  BusFetchResult({required this.buses});
}