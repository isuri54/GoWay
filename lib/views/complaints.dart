import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/complaint_controller.dart';
import 'package:flutter_application_1/views/home_page.dart';
import 'package:quickalert/quickalert.dart';

class ComplainWarning extends StatefulWidget {
  const ComplainWarning({super.key});

  @override
  State<ComplainWarning> createState() => _ComplainWarningState();
}

class _ComplainWarningState extends State<ComplainWarning> {
  late final ComplainWarningBackend _backend;
  final TextEditingController _complaintTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _backend = ComplainWarningBackend(context: context);
    _backend.initialize();
  }

  void _openAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Pick Image'),
                onTap: () {
                  Navigator.pop(context);
                  _backend.pickImage().then((_) => setState(() {}));
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Pick Video'),
                onTap: () {
                  Navigator.pop(context);
                  _backend.pickVideo().then((_) => setState(() {}));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning, size: 75, color: Colors.red),
                const SizedBox(height: 10),
                const Text(
                  "Warning!!!",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 10),
                const Text(
                  "By submitting this complaint, the following details will be shared with the police department.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Note: Providing false or misleading information is a punishable offense under the law",
                  style: TextStyle(fontSize: 15, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        _backend
                            .submitComplaint(_complaintTextController.text.trim())
                            .then((result) {
                          if (result.success) {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.success,
                              title: 'Success',
                              text: result.message,
                              onConfirmBtnTap: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const UserHomePage()),
                                  (Route<dynamic> route) => false,
                                );
                              },
                            );
                          } else {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: 'Error',
                              text: result.message,
                            );
                          }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Proceed",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Complaints",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const UserHomePage()),
              (Route<dynamic> route) => false,
            ),
            tooltip: 'Go to Home',
          ),
        ],
      ),
      body: ListView(
        children: [
          // Location Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: _backend.locationNotifier,
                      builder: (context, location, child) {
                        if (location.isEmpty || location == "Fetching location...") {
                          return const Text(
                            "Fetching location...",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          );
                        }
                        if (location.startsWith("Error") ||
                            location.startsWith("Location services") ||
                            location.startsWith("Location permissions")) {
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  location,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _backend.getCurrentLocation(),
                                child: const Text(
                                  "Retry",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        final googleMapsUrl = _backend.generateGoogleMapsUrl(location);
                        if (googleMapsUrl == 'Invalid location format') {
                          return Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Invalid location data",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _backend.getCurrentLocation(),
                                child: const Text(
                                  "Retry",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return GestureDetector(
                          onTap: () async {
                            try {
                              await _backend.launchUrl(googleMapsUrl);
                            } catch (e) {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                title: 'Error',
                                text: 'Failed to open Google Maps: $e',
                              );
                            }
                          },
                          child: const Text(
                            "View Location on Google Maps",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                  const Icon(Icons.location_pin, size: 25, color: Colors.black),
                ],
              ),
            ),
          ),
          // Driver/Bus Details Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: _backend.busDetailsNotifier,
                      builder: (context, busDetails, child) {
                        if (busDetails.isEmpty || busDetails == "Fetching bus details...") {
                          return const Text(
                            "Fetching bus details...",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          );
                        }
                        if (busDetails.startsWith("Error") ||
                            busDetails == "No active booking found" ||
                            busDetails == "No booking found for this user") {
                          return Text(
                            busDetails,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                            overflow: TextOverflow.ellipsis,
                          );
                        }
                        return Text(
                          busDetails,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                  const Icon(Icons.directions_bus, size: 25, color: Colors.black),
                ],
              ),
            ),
          ),
          // User Details Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: _backend.userDetailsNotifier,
                      builder: (context, userDetails, child) {
                        return Text(
                          userDetails,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                  const Icon(Icons.person, size: 25, color: Colors.black),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          // Complaint Text Field
          Container(
            height: 200,
            padding: const EdgeInsets.all(15.0),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextFormField(
              controller: _complaintTextController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "Type Your Complaint",
                hintStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          const SizedBox(height: 20),
          // Attachment Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: GestureDetector(
              onTap: _openAttachmentOptions,
              child: Container(
                height: 80,
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Attach Photos/Video",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                    ),
                    const Icon(Icons.attachment, size: 25, color: Colors.black),
                  ],
                ),
              ),
            ),
          ),
          // Attached Files Section
          if (_backend.attachedFiles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Attached Files:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: _backend.attachedFiles.map((file) {
                      return file.path.endsWith('.mp4') || file.path.endsWith('.mov')
                          ? const Icon(Icons.video_library, size: 50)
                          : Image.file(file, width: 50, height: 50, fit: BoxFit.cover);
                    }).toList(),
                  ),
                ],
              ),
            ),
          // Submit Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () => _showModalBottomSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  "Complain",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}