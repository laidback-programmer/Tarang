class AIPredictionService {
  static Future<String> getRiskLevel(String position) async {
    await Future.delayed(const Duration(seconds: 1));
    return "Low"; // Dummy risk
  }
}
