import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/seat_booking_controller.dart';
import 'package:flutter_application_1/views/bus_timetable.dart';

class SeatBookingScreen extends StatefulWidget {
  const SeatBookingScreen({super.key});

  @override
  _SeatBookingScreenState createState() => _SeatBookingScreenState();
}

class _SeatBookingScreenState extends State<SeatBookingScreen> {
  late final SeatBookingBackend _backend;
  Map<String, String> _seatStatus = {};
  double _totalCost = 0;
  double? _distance;
  double? _fee;
  String _busNumber = "";
  String _timeSlot = "";

  @override
  void initState() {
    super.initState();
    _backend = SeatBookingBackend(context: context);
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _distance = double.tryParse(args['distance'].toString()) ?? 0.0;
          _fee = double.tryParse(args['fee'].toString()) ?? 0.0;
          _busNumber = args['busNumber']?.toString() ?? "";
          _timeSlot = args['timeSlot']?.toString() ?? "";
        });
        _initializeSeats();
      }
    });
  }

  void _initializeSeats() async {
    final seatStatus = await _backend.initializeSeats(_busNumber, _timeSlot);
    setState(() {
      _seatStatus = seatStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TimeTablePage()),
          ),
        ),
        title: const Text(
          "Seat Booking",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.yellow[700],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Distance: ${_distance?.toStringAsFixed(2) ?? '0.0'} km", style: const TextStyle(fontSize: 18)),
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSeatSection(["A", "B"]),
                    _buildSeatSection(["C", "D"]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Rs.${_totalCost.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final result = await _backend.bookSeats(_seatStatus, _busNumber, _timeSlot, _fee ?? 0.0);
                if (result.success) {
                  setState(() {
                    _seatStatus = result.seatStatus;
                    _totalCost = 0;
                  });
                  Navigator.pushNamed(context, '/wallet', arguments: {'bookingAmount': result.totalCost});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text("Book Now", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatSection(List<String> columns) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: columns.map((col) => Text(col, style: const TextStyle(fontWeight: FontWeight.bold))).toList(),
        ),
        const SizedBox(height: 10),
        Column(
          children: List.generate(12, (index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _seatWidget('${columns[0]}${index + 1}'),
                const SizedBox(width: 30),
                _seatWidget('${columns[1]}${index + 1}'),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _seatWidget(String seat) {
    return GestureDetector(
      onTap: _seatStatus[seat] == 'booked'
          ? null
          : () {
              final newStatus = _backend.selectSeat(seat, _seatStatus, _fee ?? 0.0);
              setState(() {
                _seatStatus = newStatus.seatStatus;
                _totalCost = newStatus.totalCost;
              });
            },
      child: Container(
        margin: const EdgeInsets.all(6),
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: _backend.getSeatColor(_seatStatus[seat] ?? 'available'),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Text(
            seat,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}