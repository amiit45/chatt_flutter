import 'package:flutter/material.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/location_service.dart';



class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  late String _uuid;
  double? _latitude;
  double? _longitude;
  List<dynamic> _nearbyUsers = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _uuid = prefs.getString('uuid') ?? Uuid().v4();
    prefs.setString('uuid', _uuid);

    Position? position = await _locationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Make user available
      await _apiService.makeAvailable(_uuid, _latitude!, _longitude!);
      _scanNearbyUsers();
    }
  }

  void _scanNearbyUsers() async {
    while (_latitude != null && _longitude != null) {
      var nearbyUsers = await _apiService.scanNearby(_latitude!, _longitude!);
      if (nearbyUsers.isNotEmpty) {
        setState(() {
          _nearbyUsers = nearbyUsers;
        });
      }
      await Future.delayed(Duration(seconds: 10));  // Retry scanning after 10 seconds
    }
  }

  // Method to send request to the selected user
  void _sendRequest(String targetUuid) async {
    bool success = await _apiService.sendRequest(_uuid, targetUuid);
    if (success) {
      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request sent to $targetUuid')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan for Nearby Users")),
      body: Center(
        child: _latitude == null
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Scanning for users..."),
            CircularProgressIndicator(), // Radar animation
            SizedBox(height: 20),
            Text("Nearby Users:"),
            _nearbyUsers.isEmpty
                ? Text("No users found.")
                : ListView.builder(
              shrinkWrap: true,
              itemCount: _nearbyUsers.length,
              itemBuilder: (context, index) {
                var user = _nearbyUsers[index];
                return ListTile(
                  title: Text(user['uuid']), // Display user info (UUID)
                  trailing: ElevatedButton(
                    onPressed: () => _sendRequest(user['uuid']),
                    child: Text("Send Request"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
