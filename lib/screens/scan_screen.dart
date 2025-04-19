import 'package:flutter/material.dart';
import 'dart:math';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Dummy users (replace with API data later)
  final List<Map<String, dynamic>> foundUsers = [
    {"id": "user1", "distance": 20},
    {"id": "user2", "distance": 45},
    {"id": "user3", "distance": 60},
  ];

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  void _sendRequest(String userId) {
    // Backend se integrate karega later
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request sent to $userId'),
        backgroundColor: Colors.greenAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildRadar(),
                  const Text(
                    "Scanning...",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: ListView.builder(
                itemCount: foundUsers.length,
                itemBuilder: (context, index) {
                  final user = foundUsers[index];
                  return Card(
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        "User ID: ${user['id']}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "Distance: ${user['distance']}m",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                        ),
                        onPressed: () {
                          _sendRequest(user['id']);
                        },
                        child: const Text("Request"),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, paintCircle);
    }

    final sweepAngle = pi / 6;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..arcTo(Rect.fromCircle(center: Offset.zero, radius: radius), 0,
          sweepAngle, false)
      ..lineTo(0, 0);
    canvas.drawPath(path, paintSweep);
    canvas.restore();
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) =>
      oldDelegate.angle != angle;
}
