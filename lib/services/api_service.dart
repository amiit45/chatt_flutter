import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://your-backend-url.com"; // Replace with your actual backend URL

  // Method to make the user available with UUID and location
  Future<bool> makeAvailable(String uuid, double lat, double lng) async {
    final response = await http.post(
      Uri.parse('$baseUrl/make-available'),
      body: json.encode({'uuid': uuid, 'lat': lat, 'lng': lng}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true; // Successfully marked as available
    } else {
      return false; // Error in making available
    }
  }

  // Method to scan nearby users
  Future<List<dynamic>> scanNearby(double lat, double lng) async {
    final response = await http.get(
      Uri.parse('$baseUrl/scan-nearby?lat=$lat&lng=$lng'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // List of nearby users
    } else {
      return []; // No users found
    }
  }

  // Method to send a chat request to a nearby user
  Future<bool> sendRequest(String uuid, String targetUuid) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-request'),
      body: json.encode({'uuid': uuid, 'target_uuid': targetUuid}),
      headers: {'Content-Type': 'application/json'},
    );

    return response.statusCode == 200;
  }

  // Method to check if a request was accepted
  Future<bool> checkRequestStatus(String uuid, String targetUuid) async {
    final response = await http.get(
      Uri.parse('$baseUrl/check-request-status?uuid=$uuid&target_uuid=$targetUuid'),
      headers: {'Content-Type': 'application/json'},
    );

    return response.statusCode == 200 && json.decode(response.body)['accepted'] == true;
  }
}
