import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/official/stats_card.dart';
import 'reports_management_screen.dart';
import 'analytics_screen.dart';
import 'alert_management_screen.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Alerts',
          ),
        ],
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
      default:
        return 'Ocean Hazard App';
    }
  }
}

/// ---------------- Dashboard View ----------------
class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Recent Crowd Reports',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: Colors.black87),
        ),
        const SizedBox(height: 16),

        // Stats Cards Grid
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          children: const [
            StatsCard(
              title: 'Active Alerts',
              count: 7,
              icon: Icons.warning,
              color: Colors.redAccent,
            ),
            StatsCard(
              title: 'Reports Today',
              count: 15,
              icon: Icons.report,
              color: Colors.blueAccent,
            ),
            StatsCard(
              title: 'Social Media Trends',
              count: 5,
              icon: Icons.trending_up,
              color: Colors.orange,
            ),
            StatsCard(
              title: 'Teams Online',
              count: 8,
              icon: Icons.people,
              color: Colors.green,
            ),
          ],
        ),

        const SizedBox(height: 24),
        Text(
          'Latest Geotagged Reports',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.black87),
        ),
        const SizedBox(height: 12),

        // Recent Reports List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.place, color: Colors.blue),
                ),
                title: Text(
                  'Report #${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Location: Coastal Zone ${index + 1}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {},
              ),
            );
          },
        ),
      ],
    );
  }
}
