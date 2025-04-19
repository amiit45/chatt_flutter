import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Check and request location permission
  Future<bool> requestLocationPermission() async {
    var status = await Permission.location.request();
    return status.isGranted;
  }

  // Get current location (lat, lng)
  Future<Position?> getCurrentLocation() async {
    if (await requestLocationPermission()) {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }
    return null;
  }
}
