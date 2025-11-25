import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/official/stats_card.dart';
import '../../widgets/common/enhanced_ocean_nav.dart';
import '../../core/constants/nav_items.dart';
import 'reports_management_screen.dart';
import 'analytics_screen.dart';
import 'alert_management_screen.dart';
import 'official_profile_screen.dart';

class OfficialDashboardScreen extends StatefulWidget {
  static const String routeName = '/official-dashboard';

  const OfficialDashboardScreen({super.key});

  @override
  State<OfficialDashboardScreen> createState() =>
      _OfficialDashboardScreenState();
}

class _OfficialDashboardScreenState extends State<OfficialDashboardScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
        const _DashboardView(),
        ReportsManagementScreen(),
        const AnalyticsScreen(),
        const AlertManagementScreen(),
        const OfficialProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: const Color(0xFF0A2A57),
        automaticallyImplyLeading: false,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: EnhancedOceanBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: NavItems.officialItems,
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF0A6FB8),
        unselectedColor: Colors.grey.shade600,
        floatingCenterButton: false,
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return AppStrings.officialDashboard;
      case 1:
        return AppStrings.reportsManagement;
      case 2:
        return AppStrings.analytics;
      case 3:
        return AppStrings.alertManagement;
      case 4:
        return 'Profile';
      default:
        return 'Ocean Hazard App';
    }
  }
}

/// ---------------- Dashboard View ----------------
class _DashboardView extends StatelessWidget {
  const _DashboardView();

  // Helper to get today's date range
  DateTime get _todayStart =>
      DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
  DateTime get _todayEnd =>
      DateTime.now().copyWith(hour: 23, minute: 59, second: 59);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Force rebuild
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A6FB8), Color(0xFF006994)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A6FB8).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.dashboard,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Maritime Control Center',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Real-time hazard monitoring',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats Section
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 16),

            // Real-time Stats Cards
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('reports').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allReports = snapshot.data!.docs;
                final todayReports = allReports.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final timestamp = data['createdAt'] as Timestamp?;
                  if (timestamp == null) return false;
                  final date = timestamp.toDate();
                  return date.isAfter(_todayStart) && date.isBefore(_todayEnd);
                }).length;

                final pendingReports = allReports.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['status'] ?? 'pending').toLowerCase() ==
                      'pending';
                }).length;

                final inProgressReports = allReports.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['status'] ?? '').toLowerCase() == 'in progress';
                }).length;

                final resolvedReports = allReports.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['status'] ?? '').toLowerCase() == 'resolved';
                }).length;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    StatsCard(
                      title: 'Pending Reports',
                      count: pendingReports,
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                    StatsCard(
                      title: 'Reports Today',
                      count: todayReports,
                      icon: Icons.today,
                      color: Colors.blueAccent,
                    ),
                    StatsCard(
                      title: 'In Progress',
                      count: inProgressReports,
                      icon: Icons.sync,
                      color: Colors.blue,
                    ),
                    StatsCard(
                      title: 'Resolved',
                      count: resolvedReports,
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Recent Reports Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Reports',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to reports tab
                  },
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0A6FB8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recent Reports List
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'Error loading reports',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inbox,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No Reports Yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Reports from citizens will appear here',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final disasterType = data['disasterType'] ?? 'Unknown';
                    final status =
                        (data['status'] ?? 'pending').toString().toLowerCase();
                    final severity = data['severity'] ?? 'Medium';
                    final userName = data['userName'] ?? 'Anonymous';
                    final timestamp = data['createdAt'] as Timestamp?;
                    final locationData =
                        data['location'] as Map<String, dynamic>?;
                    final locationStr =
                        locationData?['address'] ?? 'Unknown Location';

                    // Status color and icon
                    Color statusColor;
                    IconData statusIcon;
                    switch (status) {
                      case 'in progress':
                        statusColor = Colors.blue;
                        statusIcon = Icons.sync;
                        break;
                      case 'resolved':
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                        break;
                      default: // pending
                        statusColor = Colors.orange;
                        statusIcon = Icons.pending;
                    }

                    // Severity color
                    Color severityColor;
                    switch (severity.toLowerCase()) {
                      case 'critical':
                        severityColor = Colors.red;
                        break;
                      case 'high':
                        severityColor = Colors.deepOrange;
                        break;
                      case 'medium':
                        severityColor = Colors.orange;
                        break;
                      default: // low
                        severityColor = Colors.green;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // Show report details
                          _showReportDetails(context, data, doc.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Disaster icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A6FB8)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _getDisasterIcon(disasterType),
                                      color: const Color(0xFF0A6FB8),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          disasterType,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Reported by $userName',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Status badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: statusColor, width: 1),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(statusIcon,
                                            size: 14, color: statusColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          status == 'in progress'
                                              ? 'In Progress'
                                              : status
                                                      .substring(0, 1)
                                                      .toUpperCase() +
                                                  status.substring(1),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      locationStr,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          severityColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      severity,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: severityColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (timestamp != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 14, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatTimestamp(timestamp.toDate()),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
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
        return Icons.report_problem;
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  void _showReportDetails(
      BuildContext context, Map<String, dynamic> data, String reportId) {
    final description = data['description'] ?? 'No description provided';
    final imageUrl = data['imageUrl'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['disasterType'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 48),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
