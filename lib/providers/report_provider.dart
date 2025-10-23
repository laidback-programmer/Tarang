import 'package:flutter/foundation.dart';
import '../models/hazard_report.dart';

class ReportProvider extends ChangeNotifier {
  List<HazardReport> _userReports = [];
  bool _isSubmitting = false;

  List<HazardReport> get userReports => _userReports;
  bool get isSubmitting => _isSubmitting;

  Future<bool> submitReport(HazardReport report) async {
    _isSubmitting = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _userReports.add(report);
    _isSubmitting = false;
    notifyListeners();

    return true;
  }
}