// lib/core/location/location_service.dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> current() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services disabled');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) throw Exception('Location permission denied');
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }
    
    return Geolocator.getCurrentPosition();
  }
}