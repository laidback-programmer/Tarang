import 'package:flutter/foundation.dart';
import '../models/hazard_report.dart';
import '../models/social_media_trend.dart';
import '../services/mock_data_service.dart';

class DashboardProvider extends ChangeNotifier {
  List<HazardReport> _reports = [];
  List<SocialMediaTrend> _trends = [];
  Map<String, int> _hazardStats = {};
  bool _isLoading = false;

  List<HazardReport> get reports => _reports;
  List<SocialMediaTrend> get trends => _trends;
  Map<String, int> get hazardStats => _hazardStats;
  bool get isLoading => _isLoading;

  int get totalReports => _reports.length;
  int get verifiedReports => _reports.where((r) => r.isVerified).length;
  int get activeHotspots => _hazardStats['hotspots'] ?? 5;
  List<dynamic> get activeAlerts => MockDataService.getActiveAlerts();
  List<dynamic> get recentActivity => MockDataService.getRecentActivity();

  Future<void> refreshDashboard() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _reports = MockDataService.getHazardReports();
    _trends = MockDataService.getSocialMediaTrends();
    _hazardStats = MockDataService.getHazardStatistics();

    _isLoading = false;
    notifyListeners();
  }

  void addReport(HazardReport report) {
    _reports.add(report);
    notifyListeners();
  }
}
