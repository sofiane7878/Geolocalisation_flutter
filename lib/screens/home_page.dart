// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(0, 0);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setUserLocation();
  }

  Future<void> _setUserLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      final userLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _initialPosition = userLatLng;
        _markers.addAll([
          Marker(
            markerId: const MarkerId('1'),
            position: LatLng(userLatLng.latitude + 0.001, userLatLng.longitude + 0.001),
            infoWindow: const InfoWindow(title: 'Café Local'),
          ),
          Marker(
            markerId: const MarkerId('2'),
            position: LatLng(userLatLng.latitude - 0.001, userLatLng.longitude - 0.001),
            infoWindow: const InfoWindow(title: 'Parc Central'),
          ),
        ]);
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 15.0));
    } catch (e) {
      print("Erreur : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Découverte locale')),
      body: GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 12),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
