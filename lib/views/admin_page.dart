import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/views/spashscreen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/controllers/busController.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final List<Map<String, String>> routes = [
    {"route": "GALLE-COLOMBO", "distance": "210", "fee": "500"},
    {"route": "MATARA-COLOMBO", "distance": "230", "fee": "600"},
    {"route": "TANGALLE-COLOMBO", "distance": "810", "fee": "700"},
    {"route": "KANDY-COLOMBO", "distance": "410", "fee": "500"},
    {"route": "JAFFNA-GALLE", "distance": "910", "fee": "400"},
    {"route": "TRINCO-COLOMBO", "distance": "710", "fee": "200"},
    {"route": "MAPALAGAMA-GALLE", "distance": "40", "fee": "100"},
    {"route": "YAKKALAMULLA-GALLE", "distance": "30", "fee": "50"},
    {"route": "AMBALANGODA-GALLE", "distance": "20", "fee": "50"}
  ];

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  void _showAddBusDialog(String route) {
    final TextEditingController busNumberController = TextEditingController();
    final TextEditingController busNameController = TextEditingController();
    final TextEditingController mobileController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Bus for $route'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: busNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Bus Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: busNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bus Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Driver Mobile',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final busNumber = busNumberController.text.trim();
                final busName = busNameController.text.trim();
                final mobile = mobileController.text.trim();

                if (busNumber.isEmpty || busName.isEmpty || mobile.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                try {
                  final routeData = routes.firstWhere((r) => r['route'] == route);
                  await BusController().saveBusTiming(
                    busNumber,
                    busName,
                    route,
                    [], // Initial empty times
                    [], // Initial empty times
                    mobile,
                    routeData['distance'] ?? '0',
                    routeData['fee'] ?? '0',
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bus added successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding bus: $e')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Routes",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Log Out',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ...routes.map((route) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RouteDetailPage(route: route),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          route["route"] ?? "N/A",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: () => _showAddBusDialog(route['route']!),
                      tooltip: 'Add Bus',
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class RouteDetailPage extends StatefulWidget {
  final Map<String, String> route;

  const RouteDetailPage({super.key, required this.route});

  @override
  _RouteDetailPageState createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> {
  final BusController _busController = BusController();
  List<Map<String, dynamic>> busesData = [];
  bool isLoading = true;
  final TextEditingController feeController = TextEditingController();
  String currentFee = "";

  @override
  void initState() {
    super.initState();
    currentFee = widget.route['fee'] ?? "0";
    feeController.text = currentFee;
    fetchBusData();
  }

  Future<void> fetchBusData() async {
    try {
      List<Map<String, dynamic>> data = await _busController.getBusDetailsByRoute(widget.route['route'] ?? "N/A");
      setState(() {
        busesData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching bus data: $e")),
      );
    }
  }

  Future<void> updateFee() async {
    final newFee = feeController.text.trim();
    if (newFee.isEmpty || double.tryParse(newFee) == null || double.parse(newFee) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid fee')),
      );
      return;
    }

    try {
      for (var bus in busesData) {
        await _busController.saveBusTiming(
          bus['busNumber'],
          bus['busName'],
          bus['busRoute'],
          bus['times1'] ?? [],
          bus['times2'] ?? [],
          bus['drivMobile'],
          widget.route['distance'] ?? "0",
          newFee,
        );
      }

      setState(() {
        currentFee = newFee;
        widget.route['fee'] = newFee;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fee updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating fee: $e')),
      );
    }
  }

  Future<void> showTimePickerDialog(Map<String, dynamic> bus) async {
    List<String> location1Times = List<String>.from(bus['times1'] ?? []);
    List<String> location2Times = List<String>.from(bus['times2'] ?? []);
    String key = bus['busRoute'];
    List<String> locations = key.split('-');

    String loc1 = locations.isNotEmpty ? locations[0] : "";
    String loc2 = locations.length > 1 ? locations[1] : "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Edit Bus Timings"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("$loc1 Start Times", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Column(
                    children: location1Times.map((time) {
                      return ListTile(
                        title: Text(time),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setDialogState(() {
                              location1Times.remove(time);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        final now = DateTime.now();
                        final formattedTime = DateFormat.Hm().format(
                          DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
                        );
                        setDialogState(() {
                          location1Times.add(formattedTime);
                        });
                      }
                    },
                    child: const Text("Add Start Time"),
                  ),
                  const SizedBox(height: 10),
                  Text("$loc2 Start Times", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Column(
                    children: location2Times.map((time) {
                      return ListTile(
                        title: Text(time),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setDialogState(() {
                              location2Times.remove(time);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        final now = DateTime.now();
                        final formattedTime = DateFormat.Hm().format(
                          DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
                        );
                        setDialogState(() {
                          location2Times.add(formattedTime);
                        });
                      }
                    },
                    child: const Text("Add End Time"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _busController.saveBusTiming(
                      bus['busNumber'],
                      bus['busName'],
                      bus['busRoute'],
                      location1Times,
                      location2Times,
                      bus['drivMobile'],
                      widget.route['distance'] ?? "0",
                      currentFee,
                    );
                    Navigator.pop(context);
                    fetchBusData(); // Refresh bus list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Timings updated successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving timings: $e')),
                    );
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  void dispose() {
    feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.route['route'] ?? "N/A"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Route Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("Distance: ${widget.route['distance']} km"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: feeController,
                              decoration: const InputDecoration(
                                labelText: "Fee (Rs.)",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: updateFee,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Update Fee"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: busesData.isEmpty
                      ? Center(
                          child: Text("No buses found for route: ${widget.route['route'] ?? 'N/A'}"),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: busesData.length,
                          itemBuilder: (context, index) {
                            final bus = busesData[index];
                            return InkWell(
                              onTap: () => showTimePickerDialog(bus),
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text("Bus Name: ${bus['busName']}"),
                                  subtitle: Text("Bus Number: ${bus['busNumber']}"),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}