import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../live_osm_map.dart';
import 'add_report_screen.dart';
import 'emergency_screen.dart';
import 'news_screen.dart';
import 'ai_assistant_screen.dart';
import 'profile_screen.dart'; // Import the profile screen

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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "News"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle), label: "Report"),
          BottomNavigationBarItem(
              icon: Icon(Icons.warning), label: "Emergency"),
          BottomNavigationBarItem(
              icon: Icon(Icons.assistant), label: "Assistant"),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
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
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              "3",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
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

            // Alert Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "High Wave Alert\n3m waves expected along Tamil Nadu coast",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live Map
            const Text(
              "Live Hazard Map",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Container(
              height: 250,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LiveOSMMap(
                  key: const ValueKey("live_map"),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statCard("24", "Reports", Colors.blue),
                _statCard("18", "Verified", Colors.green),
                _statCard("3", "Emergencies", Colors.red),
              ],
            ),
            const SizedBox(height: 24),

            // Community Reports
            const Text(
              "Recent Community Reports",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 12),
            _communityReport("High Waves", "Chennai Beach", "2h ago",
                Icons.warning, Colors.red),
            _communityReport("Oil Spill", "Mumbai Coast", "4h ago",
                Icons.water_drop, Colors.orange),
            _communityReport(
                "Storm Alert", "Kerala", "6h ago", Icons.cloud, Colors.red),
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
