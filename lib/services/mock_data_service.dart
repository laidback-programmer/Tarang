import '../models/hazard_report.dart';
import '../models/social_media_trend.dart';

class MockDataService {

  static List<HazardReport> getHazardReports() {
    return [
      HazardReport(
        id: '1',
        userId: 'user1',
        userName: 'Coastal Resident',
        hazardType: 'High Waves',
        description: 'Unusually high waves observed at Marina Beach. Water reaching parking area.',
        latitude: 13.0478,
        longitude: 80.2619,
        location: 'Marina Beach, Chennai',
        mediaUrls: ['image1.jpg'],
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isVerified: true,
        credibilityScore: 85,
        severity: 'high',
      ),
      HazardReport(
        id: '2',
        userId: 'user2',
        userName: 'Fisherman',
        hazardType: 'Tsunami Warning',
        description: 'Water receding rapidly from shore. Unusual sea behavior noticed.',
        latitude: 11.9341,
        longitude: 79.8309,
        location: 'Pondicherry Coast',
        mediaUrls: ['video1.mp4'],
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isVerified: false,
        credibilityScore: 90,
        severity: 'critical',
      ),
      HazardReport(
        id: '3',
        userId: 'user3',
        userName: 'Tourist',
        hazardType: 'Oil Spill',
        description: 'Dark patches visible in water near Kovalam beach. Strong smell.',
        latitude: 8.4004,
        longitude: 76.9784,
        location: 'Kovalam, Kerala',
        mediaUrls: ['image2.jpg'],
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isVerified: true,
        credibilityScore: 75,
        severity: 'medium',
      ),
    ];
  }

  static List<SocialMediaTrend> getSocialMediaTrends() {
    return [
      SocialMediaTrend(
        keyword: 'tsunami',
        mentions: 1250,
        sentiment: -0.7,
        platform: 'Twitter',
        timestamp: DateTime.now(),
        relatedPosts: [
          'Earthquake felt strongly, worried about tsunami',
          'Is there any tsunami warning issued?',
          'Coastal areas should be evacuated immediately'
        ],
      ),
      SocialMediaTrend(
        keyword: 'high waves',
        mentions: 890,
        sentiment: -0.5,
        platform: 'Facebook',
        timestamp: DateTime.now(),
        relatedPosts: [
          'Huge waves hitting Chennai coast',
          'Beach closed due to dangerous waves',
          'Fishermen advised not to venture into sea'
        ],
      ),
      SocialMediaTrend(
        keyword: 'oil spill',
        mentions: 640,
        sentiment: -0.8,
        platform: 'Instagram',
        timestamp: DateTime.now(),
        relatedPosts: [
          'Environmental disaster at Kerala coast',
          'Marine life in danger due to oil spill',
          'Cleanup operations urgently needed'
        ],
      ),
    ];
  }

  static Map<String, int> getHazardStatistics() {
    return {
      'totalReports': 156,
      'verifiedReports': 98,
      'pendingReports': 58,
      'hotspots': 7,
      'activeAlerts': 3,
    };
  }

  static Map<String, double> getSentimentAnalysis() {
    return {
      'positive': 0.15,
      'negative': 0.65,
      'neutral': 0.20,
    };
  }

  static List<String> getTrendingKeywords() {
    return [
      'tsunami warning',
      'high waves',
      'oil spill cleanup',
      'coastal flooding',
      'evacuation notice',
      'marine rescue',
    ];
  }

  static List<dynamic> getActiveAlerts() {
    return [
      {
        'id': 'alert1',
        'message': 'High wave warning issued for Tamil Nadu coast',
        'severity': 'high',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      },
      {
        'id': 'alert2',
        'message': 'Oil spill detected near Mumbai harbor',
        'severity': 'medium',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      },
    ];
  }

  static List<dynamic> getRecentActivity() {
    return [
      {
        'title': 'New Tsunami Report',
        'description': 'Verified report from Pondicherry coast',
        'timeAgo': '15m',
        'type': 'report',
      },
      {
        'title': 'High Wave Alert',
        'description': 'Alert issued for Chennai beaches',
        'timeAgo': '45m',
        'type': 'alert',
      },
      {
        'title': 'Oil Spill Cleanup',
        'description': 'Cleanup operations started at Kovalam',
        'timeAgo': '2h',
        'type': 'response',
      },
    ];
  }
}