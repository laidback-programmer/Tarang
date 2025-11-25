import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LiveOSMMap extends StatefulWidget {
  final List<Map<String, dynamic>>? reports;

  const LiveOSMMap({super.key, this.reports});

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
        _handleError(
            'Location permissions are permanently denied. Please enable them in app settings.');
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

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Add current location marker
    markers.add(
      Marker(
        point: _effectiveLocation,
        child: const Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 35,
        ),
      ),
    );

    // Add report markers
    if (widget.reports != null) {
      for (var report in widget.reports!) {
        final locationData = report['location'] as Map<String, dynamic>?;
        if (locationData != null) {
          final lat = locationData['latitude'] as num?;
          final lng = locationData['longitude'] as num?;

          if (lat != null && lng != null) {
            final severity =
                (report['severity'] ?? 'Medium').toString().toLowerCase();
            final disasterType = report['disasterType'] ?? 'Unknown';

            // Color based on severity
            Color markerColor;
            if (severity == 'critical') {
              markerColor = Colors.red;
            } else if (severity == 'high') {
              markerColor = Colors.deepOrange;
            } else if (severity == 'medium') {
              markerColor = Colors.orange;
            } else {
              markerColor = Colors.yellow;
            }

            markers.add(
              Marker(
                point: LatLng(lat.toDouble(), lng.toDouble()),
                child: GestureDetector(
                  onTap: () {
                    // Show report details in a tooltip
                    _showReportTooltip(report);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: markerColor,
                        size: 40,
                      ),
                      Positioned(
                        top: 8,
                        child: Icon(
                          _getDisasterIcon(disasterType),
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
      }
    }

    return markers;
  }

  IconData _getDisasterIcon(String type) {
    switch (type.toLowerCase()) {
      case 'flood':
        return Icons.water_damage;
      case 'cyclone':
        return Icons.cyclone;
      case 'tsunami':
        return Icons.waves;
      case 'earthquake':
        return Icons.vibration;
      case 'fire':
        return Icons.local_fire_department;
      case 'oil spill':
        return Icons.opacity;
      case 'landslide':
        return Icons.terrain;
      case 'storm surge':
        return Icons.storm;
      case 'coastal erosion':
        return Icons.landscape;
      default:
        return Icons.warning;
    }
  }

  void _showReportTooltip(Map<String, dynamic> report) {
    final disasterType = report['disasterType'] ?? 'Unknown';
    final locationData = report['location'] as Map<String, dynamic>?;
    final locationStr = locationData?['address'] ?? 'Unknown Location';
    final severity = report['severity'] ?? 'Medium';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              disasterType,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(locationStr),
            const SizedBox(height: 4),
            Text('Severity: $severity'),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.example.sea_safe',
                      ),
                      MarkerLayer(
                        markers: _buildMarkers(),
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
