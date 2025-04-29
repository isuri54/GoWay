import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/home_page.dart';
import 'package:flutter_application_1/views/settings.dart' show CustomFooter;
import 'package:flutter_application_1/views/timetable_controller.dart';

class TimeTablePage extends StatefulWidget {
  const TimeTablePage({super.key});

  @override
  _TimeTablePageState createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
  late final TimeTableBackend _backend;
  int _currentIndex = 0;
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  List<Map<String, dynamic>> busList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _backend = TimeTableBackend(context: context);
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  void _onFooterTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0: 
        Navigator.pushNamed(context, '/userhome');
        break;
      case 1: 
        Navigator.pushNamed(context, '/seats-booking');
        break;
      case 2: 
        Navigator.pushNamed(context, '/qr-scanner');
        break;
      case 3: 
        Navigator.pushNamed(context, '/wallet');
        break;
      case 4: 
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time table"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserHomePage()),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: fromController,
                decoration: const InputDecoration(
                  labelText: "From",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: toController,
                decoration: const InputDecoration(
                  labelText: "To",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() => isLoading = true);
                    final result = await _backend.fetchBuses(fromController.text, toController.text);
                    setState(() {
                      busList = result.buses;
                      isLoading = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "SEARCH",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : busList.isEmpty
                        ? const Center(child: Text("Enter locations to search for buses"))
                        : ListView.builder(
                            itemCount: busList.length,
                            itemBuilder: (context, index) {
                              return BusTile(busData: busList[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomFooter(
        currentIndex: _currentIndex,
        onTap: _onFooterTapped,
      ),
    );
  }
}

class BusTile extends StatefulWidget {
  final Map<String, dynamic> busData;

  const BusTile({super.key, required this.busData});

  @override
  _BusTileState createState() => _BusTileState();
}

class _BusTileState extends State<BusTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: ListTile(
            tileColor: Colors.yellow[100],
            title: Text(
              widget.busData["busName"] ?? "Unknown",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.busData["startTime"] ?? "N/A"),
            trailing: IconButton(
              icon: Icon(
                expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.black,
              ),
              onPressed: () => setState(() => expanded = !expanded),
            ),
          ),
        ),
        if (expanded)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Start Time: ${widget.busData["startTime"] ?? "N/A"}"),
                  Text("Distance: ${widget.busData["distance"]?.toString() ?? "N/A"} km"),
                  Text("Fee: Rs. ${widget.busData["fee"]?.toString() ?? "N/A"}"),
                  Text("Contact: ${widget.busData["mobile"] ?? "N/A"}"),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/seats-booking',
                        arguments: {
                          "distance": widget.busData["distance"] ?? 0.0,
                          "fee": widget.busData["fee"] ?? 0.0,
                          "busNumber": widget.busData["busNumber"] ?? "",
                          "timeSlot": widget.busData["startTime"] ?? "",
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: const Text("Book Now"),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}