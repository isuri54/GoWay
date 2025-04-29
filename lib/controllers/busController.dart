import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getBusDetailsByRoute(String route) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('buses') 
          .where('busRoute', isEqualTo: route)
          .get();

      List<Map<String, dynamic>> busData = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'busNumber': data['busNumber'] ?? doc.id,
          'busName': data['busName'] ?? 'Unknown Bus',
          'busRoute': data['busRoute'] ?? route,
          'times1': List<String>.from(data['timeFromLocation1'] ?? []),
          'times2': List<String>.from(data['timeFromLocation2'] ?? []),
          'drivMobile': data['drivMobile'] ?? 'N/A',
          'distance': data['distance']?.toString() ?? '0',
          'fee': data['fee']?.toString() ?? '0',
        };
      }).toList();

      return busData;
    } catch (e) {
      print("Error fetching bus details: $e");
      return [];
    }
  }

  Future<Map<String, List<String>>> fetchBusSchedule(String busNumber) async {
    try {
      DocumentSnapshot scheduleSnapshot =
          await _firestore.collection('buses').doc(busNumber).get();

      if (scheduleSnapshot.exists) {
        Map<String, dynamic> data = scheduleSnapshot.data() as Map<String, dynamic>;
        List<String> startTimes = List<String>.from(data['timeFromLocation1'] ?? []);
        List<String> endTimes = List<String>.from(data['timeFromLocation2'] ?? []);
        return {
          'times1': startTimes,
          'times2': endTimes,
        };
      } else {
        return {
          'times1': [],
          'times2': [],
        };
      }
    } catch (e) {
      print("Error fetching schedule: $e");
      return {
        'times1': [],
        'times2': [],
      };
    }
  }

  Future<void> saveBusTiming(
    String busNumber,
    String busName,
    String route,
    List<String> times1,
    List<String> times2,
    String mobile,
    String distance,
    String fee,
  ) async {
    final busesRef = _firestore.collection('buses');
    try {
      await busesRef.doc(busNumber).set({
        'busNumber': busNumber,
        'busName': busName,
        'busRoute': route,
        'distance': distance,
        'fee': fee,
        'drivMobile': mobile,
        'timeFromLocation1': times1,
        'timeFromLocation2': times2,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge to update existing documents

      print("Bus data saved successfully for $busNumber");
    } catch (e) {
      print("Error saving bus data: $e");
      rethrow; 
    }
  }

  Future<List<Map<String, dynamic>>> getBusTimeTableByRoute(String route) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('buses')
          .where('busRoute', isEqualTo: route)
          .get();

      List<Map<String, dynamic>> sortedBuses = [];
      if (querySnapshot.size > 0) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String busName = data['busName'] ?? 'Unknown Bus';
          String busNumber = data['busNumber'] ?? doc.id;
          String mobile = data['drivMobile'] ?? 'N/A';
          String distance = data['distance']?.toString() ?? '0';
          String fee = data['fee']?.toString() ?? '0';
          List<String> times = List<String>.from(data['timeFromLocation1'] ?? []);

          for (String time in times) {
            sortedBuses.add({
              'busName': busName,
              'busNumber': busNumber,
              'startTime': time,
              'mobile': mobile,
              'distance': distance,
              'fee': fee,
            });
          }
        }
      } else {
        String reverseRoute = route.split('-').reversed.join('-');
        QuerySnapshot querySnapshot2 = await _firestore
            .collection('buses')
            .where('busRoute', isEqualTo: reverseRoute)
            .get();

        if (querySnapshot2.size > 0) {
          for (var doc in querySnapshot2.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            String busName = data['busName'] ?? 'Unknown Bus';
            String busNumber = data['busNumber'] ?? doc.id;
            String mobile = data['drivMobile'] ?? 'N/A';
            String distance = data['distance']?.toString() ?? '0';
            String fee = data['fee']?.toString() ?? '0';
            List<String> times = List<String>.from(data['timeFromLocation2'] ?? []);

            for (String time in times) {
              sortedBuses.add({
                'busName': busName,
                'busNumber': busNumber,
                'startTime': time,
                'mobile': mobile,
                'distance': distance,
                'fee': fee,
              });
            }
          }
        }
      }

      sortedBuses.sort((a, b) => a['startTime'].compareTo(b['startTime']));
      return sortedBuses;
    } catch (e) {
      print("Error fetching timetable: $e");
      return [];
    }
  }
}