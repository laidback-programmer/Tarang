import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../live_osm_map.dart';
import '../../widgets/common/enhanced_ocean_nav.dart';
import '../../core/constants/nav_items.dart';
import 'add_report_screen.dart';
import 'emergency_screen.dart';
import 'news_screen.dart';
import 'ai_assistant_screen.dart';
import 'profile_screen.dart';

class CitizenHomeScreen extends StatefulWidget {
  static const String routeName = '/citizen-home';

  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomePage(),
      const NewsScreen(),
      const AddReportScreen(),
      const EmergencyScreen(),
      const AiAssistantScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2A57),
      body: _pages[_selectedIndex],
      bottomNavigationBar: EnhancedOceanBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: NavItems.citizenItems,
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF0A6FB8),
        unselectedColor: Colors.grey.shade600,
        floatingCenterButton: true,
        centerButtonIndex: 2, // Report button in the center
      ),
    );
  }

  Widget _buildHomePage() {
    final user = FirebaseAuth.instance.currentUser;
    final DateTime todayStart =
        DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    final DateTime todayEnd =
        DateTime.now().copyWith(hour: 23, minute: 59, second: 59);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Profile & Notification Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tarang",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Row(
                  children: [
                    // Profile Icon
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()),
                        );
                      },
                    ),
                    // Notification Icon with badge
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications,
                              color: Colors.white),
                          onPressed: () {},
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: user != null
                              ? FirebaseFirestore.instance
                                  .collection('reports')
                                  .where('userId', isEqualTo: user.uid)
                                  .where('status', whereIn: [
                                  'in progress',
                                  'resolved'
                                ]).snapshots()
                              : null,
                          builder: (context, snapshot) {
                            final count = snapshot.hasData
                                ? snapshot.data!.docs.length
                                : 0;
                            if (count == 0) return const SizedBox.shrink();

                            return Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  count > 9 ? "9+" : "$count",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),

            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quickAction(Icons.report, "Report",
                    () => setState(() => _selectedIndex = 2)),
                _quickAction(Icons.map, "Live Map", () {}),
                _quickAction(Icons.security, "Safety", () {}),
                _quickAction(Icons.group, "Community", () {}),
              ],
            ),
            const SizedBox(height: 24),

            // Alert Card - Show latest critical report
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .where('severity', isEqualTo: 'Critical')
                  .where('status', whereIn: ['pending', 'in progress'])
                  .orderBy('createdAt', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }

                final doc = snapshot.data!.docs.first;
                final data = doc.data() as Map<String, dynamic>;
                final disasterType = data['disasterType'] ?? 'Alert';
                final locationData = data['location'] as Map<String, dynamic>?;
                final locationStr =
                    locationData?['address'] ?? 'Unknown Location';
                final description = data['description'] ?? '';

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$disasterType Alert",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              locationStr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Live Map with Reports
            const Text(
              "Live Hazard Map",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reports').where(
                  'status',
                  whereIn: ['pending', 'in progress']).snapshots(),
              builder: (context, snapshot) {
                List<Map<String, dynamic>>? reports;

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  reports = snapshot.data!.docs.map((doc) {
                    return doc.data() as Map<String, dynamic>;
                  }).toList();
                }

                return Container(
                  height: 250,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LiveOSMMap(
                      key: ValueKey("live_map_${reports?.length ?? 0}"),
                      reports: reports,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Statistics - Real data from Firebase
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('reports').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statCard("0", "Reports", Colors.blue),
                      _statCard("0", "Verified", Colors.green),
                      _statCard("0", "Critical", Colors.red),
                    ],
                  );
                }

                final allReports = snapshot.data!.docs;
                final todayReports = allReports.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final timestamp = data['createdAt'] as Timestamp?;
                  if (timestamp == null) return false;
                  final date = timestamp.toDate();
                  return date.isAfter(todayStart) && date.isBefore(todayEnd);
                }).length;

                final resolvedReports = allReports.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['status'] ?? '').toLowerCase() == 'resolved';
                }).length;

                final criticalReports = allReports.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['severity'] ?? '').toLowerCase() == 'critical' &&
                      (data['status'] ?? '').toLowerCase() != 'resolved';
                }).length;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statCard("$todayReports", "Today", Colors.blue),
                    _statCard("$resolvedReports", "Resolved", Colors.green),
                    _statCard("$criticalReports", "Critical", Colors.red),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Community Reports - Show all reports from Firebase
            const Text(
              "Recent Community Reports",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .orderBy('createdAt', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Error loading reports',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inbox,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'No reports yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Be the first to report a hazard',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final disasterType = data['disasterType'] ?? 'Unknown';
                    final locationData =
                        data['location'] as Map<String, dynamic>?;
                    final locationStr =
                        locationData?['address'] ?? 'Unknown Location';
                    final timestamp = data['createdAt'] as Timestamp?;
                    final severity =
                        (data['severity'] ?? 'Medium').toLowerCase();

                    // Get icon and color based on disaster type
                    IconData icon;
                    Color color;

                    switch (disasterType.toLowerCase()) {
                      case 'flood':
                        icon = Icons.water_damage;
                        color = Colors.blue;
                        break;
                      case 'cyclone':
                        icon = Icons.cyclone;
                        color = Colors.deepPurple;
                        break;
                      case 'tsunami':
                        icon = Icons.waves;
                        color = Colors.indigo;
                        break;
                      case 'fire':
                        icon = Icons.local_fire_department;
                        color = Colors.deepOrange;
                        break;
                      case 'oil spill':
                        icon = Icons.opacity;
                        color = Colors.black87;
                        break;
                      case 'storm surge':
                        icon = Icons.storm;
                        color = Colors.blueGrey;
                        break;
                      default:
                        icon = Icons.warning;
                        color = Colors.orange;
                    }

                    // Override color if severity is critical
                    if (severity == 'critical') {
                      color = Colors.red;
                    } else if (severity == 'high') {
                      color = Colors.deepOrange;
                    }

                    String timeAgo = 'Unknown time';
                    if (timestamp != null) {
                      final dateTime = timestamp.toDate();
                      final difference = DateTime.now().difference(dateTime);

                      if (difference.inMinutes < 1) {
                        timeAgo = 'Just now';
                      } else if (difference.inMinutes < 60) {
                        timeAgo = '${difference.inMinutes}m ago';
                      } else if (difference.inHours < 24) {
                        timeAgo = '${difference.inHours}h ago';
                      } else if (difference.inDays < 7) {
                        timeAgo = '${difference.inDays}d ago';
                      } else {
                        timeAgo = DateFormat('MMM d').format(dateTime);
                      }
                    }

                    return _communityReport(
                      disasterType,
                      locationStr,
                      timeAgo,
                      icon,
                      color,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.blue, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _communityReport(
      String title, String location, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(location,
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 14)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
