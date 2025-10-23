class SocialMediaTrend {
  final String keyword;
  final int mentions;
  final double sentiment;
  final String platform;
  final DateTime timestamp;
  final List<String> relatedPosts;

  SocialMediaTrend({
    required this.keyword,
    required this.mentions,
    required this.sentiment,
    required this.platform,
    required this.timestamp,
    required this.relatedPosts,
  });

  factory SocialMediaTrend.fromMap(Map<String, dynamic> map) {
    return SocialMediaTrend(
      keyword: map['keyword'] ?? '',
      mentions: map['mentions'] ?? 0,
      sentiment: map['sentiment']?.toDouble() ?? 0.0,
      platform: map['platform'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      relatedPosts: List<String>.from(map['relatedPosts'] ?? []),
    );
  }
}
