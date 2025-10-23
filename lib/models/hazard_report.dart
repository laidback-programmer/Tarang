class HazardReport {
  final String id;
  final String userId;
  final String userName;
  final String hazardType;
  final String description;
  final double latitude;
  final double longitude;
  final String location;
  final List<String> mediaUrls;
  final DateTime timestamp;
  final bool isVerified;
  final int credibilityScore;
  final String severity;

  HazardReport({
    required this.id,
    required this.userId,
    required this.userName,
    required this.hazardType,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.mediaUrls,
    required this.timestamp,
    this.isVerified = false,
    this.credibilityScore = 50,
    this.severity = 'medium',
  });

  factory HazardReport.fromMap(Map<String, dynamic> map) {
    return HazardReport(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      hazardType: map['hazardType'] ?? '',
      description: map['description'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      location: map['location'] ?? '',
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      isVerified: map['isVerified'] ?? false,
      credibilityScore: map['credibilityScore'] ?? 50,
      severity: map['severity'] ?? 'medium',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'hazardType': hazardType,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'mediaUrls': mediaUrls,
      'timestamp': timestamp.toIso8601String(),
      'isVerified': isVerified,
      'credibilityScore': credibilityScore,
      'severity': severity,
    };
  }
}