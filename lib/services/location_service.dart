import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  static Future<Position> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Service GPS désactivé, tentative par IP...");
        return await _getLocationByIP();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever ||
            permission == LocationPermission.denied) {
          print("Permissions GPS refusées, tentative par IP...");
          return await _getLocationByIP();
        }
      }

      // Essai GPS
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
      print("Position GPS : ${position.latitude}, ${position.longitude}");
      return position;
    } catch (e) {
      print("Erreur GPS : $e, tentative par IP...");
      return await _getLocationByIP();
    }
  }

  static Future<Position> _getLocationByIP() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Position IP : ${data['city']} (${data['lat']}, ${data['lon']})");
        return Position(
          latitude: data['lat'],
          longitude: data['lon'],
          timestamp: DateTime.now(),
          accuracy: 5000.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 1.0,
          headingAccuracy: 1.0,
        );
      } else {
        throw Exception('Erreur IPAPI : ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur IPAPI : $e, position par défaut (Paris)");
      return Position(
        latitude: 48.8566,
        longitude: 2.3522,
        timestamp: DateTime.now(),
        accuracy: 10000.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
      );
    }
  }
}
