import 'package:flutter/material.dart';
import 'dart:math';

import '../services/api_service.dart';
import '../services/location_service.dart';
 // Import ApiService
 // Import LocationService

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isLoading = false;
  List<dynamic> nearbyUsers = []; // List to hold nearby users

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
    _getLocationAndScan(); // Calling the new method to get location and scan users
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Method to get location and scan nearby users
  void _getLocationAndScan() async {
    setState(() {
      isLoading = true;
    });

    final position = await LocationService().getCurrentLocation(); // Get current location

    print("Lat: ${position?.latitude}, Lng: ${position?.longitude}");

    // Scan nearby users with the fetched location
    ApiService().scanNearby(position!.latitude, position.longitude).then((users) {
      setState(() {
        nearbyUsers = users;
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    });
  }

  // Method to build radar animation
  Widget _buildRadar() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: RadarPainter(angle: _animation.value),
          size: const Size(300, 300),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildRadar(),
            if (isLoading)
              const CircularProgressIndicator(color: Colors.greenAccent)
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Scanning...",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  _buildUserList(), // Display list of nearby users
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Widget to build the list of nearby users
  Widget _buildUserList() {
    if (nearbyUsers.isEmpty) {
      return const Text(
        "No nearby users found",
        style: TextStyle(color: Colors.white),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: nearbyUsers.length,
      itemBuilder: (context, index) {
        final user = nearbyUsers[index];
        return ListTile(
          title: Text(
            "User: ${user['uuid']}",
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            "Lat: ${user['location']['latitude']}, Lng: ${user['location']['longitude']}",
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.send, color: Colors.greenAccent),
            onPressed: () {
              // Send request functionality can be added here
              // ApiService().sendRequest(currentUserUuid, user['uuid']);
            },
          ),
        );
      },
    );
  }
}

// Custom painter for radar animation
class RadarPainter extends CustomPainter {
  final double angle;

  RadarPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final paintCircle = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final paintSweep = Paint()
      ..color = Colors.greenAccent.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Draw concentric circles
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, paintCircle);
    }

    // Sweep line
    final sweepAngle = pi / 6;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..arcTo(Rect.fromCircle(center: Offset.zero, radius: radius), 0, sweepAngle, false)
      ..lineTo(0, 0);
    canvas.drawPath(path, paintSweep);
    canvas.restore();
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) => oldDelegate.angle != angle;
}
