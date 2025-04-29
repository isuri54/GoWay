import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/bus_tracking_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusTrackingPage extends StatefulWidget {
  final String busId;
  const BusTrackingPage({Key? key, required this.busId}) : super(key: key);

  @override
  _BusTrackingPageState createState() => _BusTrackingPageState();
}

class _BusTrackingPageState extends State<BusTrackingPage> {
  final BusTrackingService _service = BusTrackingService();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  GoogleMapController? mapController;
  LatLng? busLocation;
  LatLng? fromLocation;
  LatLng? toLocation;
  double? distanceInKm;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _service.getBusLocationStream(widget.busId).listen((location) {
      if (location != null) {
        setState(() {
          busLocation = location;
        });
      }
    });
  }

  Future<void> searchLocations() async {
    final fromText = fromController.text.trim();
    final toText = toController.text.trim();

    if (fromText.isEmpty || toText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both 'From' and 'To' locations")),
      );
      return;
    }

    setState(() => isLoading = true);

    final fromLatLng = await _service.getLatLngFromAddress(fromText);
    final toLatLng = await _service.getLatLngFromAddress(toText);

    if (fromLatLng != null && toLatLng != null) {
      setState(() {
        fromLocation = fromLatLng;
        toLocation = toLatLng;
        distanceInKm = _service.calculateDistance(fromLatLng, toLatLng);
        isLoading = false;
      });

      if (mapController != null) {
        final bounds = LatLngBounds(
          southwest: LatLng(
            fromLatLng.latitude < toLatLng.latitude
                ? fromLatLng.latitude
                : toLatLng.latitude,
            fromLatLng.longitude < toLatLng.longitude
                ? fromLatLng.longitude
                : toLatLng.longitude,
          ),
          northeast: LatLng(
            fromLatLng.latitude > toLatLng.latitude
                ? fromLatLng.latitude
                : toLatLng.latitude,
            fromLatLng.longitude > toLatLng.longitude
                ? fromLatLng.longitude
                : toLatLng.longitude,
          ),
        );

        mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not find one or both locations")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bus Tracking")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fromController,
                    decoration: InputDecoration(
                      labelText: "From",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: toController,
                    decoration: InputDecoration(
                      labelText: "To",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: searchLocations,
                ),
              ],
            ),
          ),
          if (isLoading)
            CircularProgressIndicator()
          else if (distanceInKm != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Distance: ${distanceInKm!.toStringAsFixed(2)} km",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(6.9271, 79.8612),
                zoom: 12.0,
              ),
              markers: {
                if (busLocation != null)
                  Marker(
                    markerId: MarkerId("bus"),
                    position: busLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue),
                  ),
                if (fromLocation != null)
                  Marker(
                    markerId: MarkerId("from"),
                    position: fromLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                  ),
                if (toLocation != null)
                  Marker(
                    markerId: MarkerId("to"),
                    position: toLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }
}
