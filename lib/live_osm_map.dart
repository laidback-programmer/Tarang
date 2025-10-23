import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LiveOSMMap extends StatefulWidget {
  const LiveOSMMap({super.key});

  @override
  State<LiveOSMMap> createState() => _LiveOSMMapState();
}

class _LiveOSMMapState extends State<LiveOSMMap> {
  LatLng? _currentLocation;
  bool _loading = true;
  String? _errorMessage;
  final MapController _mapController = MapController();

  // Use a constant for default location
  static const LatLng _defaultLocation = LatLng(19.0760, 72.8777); // Mumbai

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _handleError('Location services are disabled. Please enable them.');
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _handleError('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _handleError('Location permissions are permanently denied. Please enable them in app settings.');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _loading = false;
        _errorMessage = null;
      });

      // Move map to location after build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentLocation != null) {
          _mapController.move(_currentLocation!, 15.0);
        }
      });

    } catch (e) {
      _handleError('Failed to get location: ${e.toString()}');
    }
  }

  void _handleError(String message) {
    setState(() {
      _errorMessage = message;
      _loading = false;
      _currentLocation = _defaultLocation;
    });
  }

  LatLng get _effectiveLocation {
    return _currentLocation ?? _defaultLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 250,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _effectiveLocation,
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.example.sea_safe',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _effectiveLocation,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_errorMessage != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}