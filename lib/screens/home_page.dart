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
      print("Tentative de récupération de la position...");
      final position = await LocationService.getCurrentLocation();
      print("Position actuelle : ${position.latitude}, ${position.longitude}");
      final userLatLng = LatLng(position.latitude, position.longitude);

      if (!mounted) return;

      setState(() {
        _initialPosition = userLatLng;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: userLatLng,
            infoWindow: const InfoWindow(title: 'Ma position'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );

        _markers.addAll([
          Marker(
            markerId: const MarkerId('1'),
            position: LatLng(
              userLatLng.latitude + 0.001,
              userLatLng.longitude + 0.001,
            ),
            infoWindow: const InfoWindow(title: 'Café Local'),
          ),
          Marker(
            markerId: const MarkerId('2'),
            position: LatLng(
              userLatLng.latitude - 0.001,
              userLatLng.longitude - 0.001,
            ),
            infoWindow: const InfoWindow(title: 'Parc Central'),
          ),
        ]);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLatLng, 15.0),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            position.accuracy > 1000
                ? 'Position approximative trouvée'
                : 'Position GPS précise trouvée',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Erreur : $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de localisation: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      setState(() {
        _initialPosition = const LatLng(48.8566, 2.3522);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Découverte locale')),
      body:
          _initialPosition.latitude == 0 && _initialPosition.longitude == 0
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (controller) => _mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 15,
                    ),
                    markers: _markers,
                    myLocationEnabled: false, // Désactiver le point bleu natif
                    myLocationButtonEnabled:
                        false, // Désactiver le bouton natif
                  ),
                  // Ajout de votre propre bouton de localisation
                  Positioned(
                    left:
                        16, // Changé de "right" à "left" pour placer le bouton à gauche
                    bottom: 16,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.my_location, color: Colors.blue),
                      onPressed: () async {
                        // Utiliser votre service de localisation personnalisé
                        await _setUserLocation();
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
