class LocationService {
  static Future<String> getCurrentLocation() async {
    await Future.delayed(const Duration(seconds: 1));
    return "Lat:0, Lon:0"; // Dummy location
  }
}
