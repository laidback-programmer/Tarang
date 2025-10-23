import 'package:flutter/foundation.dart';
import '../models/social_media_trend.dart';
import '../services/mock_data_service.dart';

class SocialAnalyticsProvider extends ChangeNotifier {
  List<SocialMediaTrend> _trends = [];
  Map<String, double> _sentimentAnalysis = {};
  List<String> _trendingKeywords = [];
  bool _isAnalyzing = false;

  List<SocialMediaTrend> get trends => _trends;
  Map<String, double> get sentimentAnalysis => _sentimentAnalysis;
  List<String> get trendingKeywords => _trendingKeywords;
  bool get isAnalyzing => _isAnalyzing;

  Future<void> analyzeSocialMedia() async {
    _isAnalyzing = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _trends = MockDataService.getSocialMediaTrends();
    _sentimentAnalysis = MockDataService.getSentimentAnalysis();
    _trendingKeywords = MockDataService.getTrendingKeywords();

    _isAnalyzing = false;
    notifyListeners();
  }
}