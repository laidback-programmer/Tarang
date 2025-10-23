import 'package:flutter/material.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> hazardFeed = const [
    {
      "user": "Fisherman (Chennai)",
      "report": "Unusually high waves spotted near Marina Beach.",
      "time": "5 mins ago",
      "type": "High Waves",
      "severity": "Moderate"
    },
    {
      "user": "Citizen (Andaman)",
      "report": "Water suddenly receded from shoreline – possible tsunami warning!",
      "time": "15 mins ago",
      "type": "Tsunami",
      "severity": "High"
    },
    {
      "user": "Coastal Guard",
      "report": "Oil spill detected, strong smell in the air.",
      "time": "30 mins ago",
      "type": "Oil Spill",
      "severity": "Moderate"
    },
    {
      "user": "Volunteer (Kerala)",
      "report": "Flooded streets in Alappuzha, people stranded.",
      "time": "1 hr ago",
      "type": "Flood",
      "severity": "High"
    },
  ];

  late AnimationController _sosController;
  late Animation<double> _sosAnimation;
  final List<Animation<Offset>> _cardSlideAnimations = [];
  bool _sosActive = false;

  @override
  void initState() {
    super.initState();

    // SOS pulsating animation
    _sosController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _sosAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _sosController, curve: Curves.easeInOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _sosController.reverse();
        else if (status == AnimationStatus.dismissed && _sosActive)
          _sosController.forward();
      });

    // QuickAction card slide animations
    for (int i = 0; i < 3; i++) {
      _cardSlideAnimations.add(Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _sosController,
        curve: Interval(i * 0.2, 1.0, curve: Curves.easeOut),
      )));
    }
  }

  @override
  void dispose() {
    _sosController.dispose();
    super.dispose();
  }

  void _triggerSOS() {
    setState(() {
      _sosActive = !_sosActive;
      if (_sosActive) {
        _sosController.forward();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.red[50],
            title: const Text('Emergency Alert Activated',
                style: TextStyle(color: Colors.red)),
            content: const Text(
                'Authorities and nearby responders have been notified with your location. Help is on the way.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK', style: TextStyle(color: Colors.red)),
              )
            ],
          ),
        );
      } else {
        _sosController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text("Emergency Response",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A2472),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSOSSection(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildLiveFeed(),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
      ]),
      child: Column(
        children: [
          const Text("EMERGENCY ALERT",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0A2472), letterSpacing: 1.2)),
          const SizedBox(height: 10),
          const Text(
            "Tap to send immediate distress signal to authorities and nearby responders",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ScaleTransition(
            scale: _sosAnimation,
            child: GestureDetector(
              onTap: _triggerSOS,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _sosActive ? Colors.red[700] : const Color(0xFFE83636),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_sosActive ? Colors.red[700]! : const Color(0xFFE83636))
                          .withOpacity(0.4),
                      blurRadius: _sosActive ? 20 : 10,
                      spreadRadius: _sosActive ? 4 : 2,
                    )
                  ],
                ),
                child: const Icon(Icons.warning_rounded, size: 40, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _sosActive ? "ALERT ACTIVE - HELP IS ON THE WAY" : "TAP FOR EMERGENCY SOS",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _sosActive ? Colors.red[700] : const Color(0xFF0A2472),
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2472))),
        const SizedBox(height: 12),
        SlideTransition(
          position: _cardSlideAnimations[0],
          child: _buildQuickAction(Icons.add_location_alt, const Color(0xFF16C79A),
              "Report Hazard", "Submit geotagged hazard reports", () => Navigator.pushNamed(context, "/add")),
        ),
        const SizedBox(height: 12),
        SlideTransition(
          position: _cardSlideAnimations[1],
          child: _buildQuickAction(Icons.health_and_safety, const Color(0xFFF6A32C),
              "Safety Guidelines", "What to do during a hazard event", () {}),
        ),
        const SizedBox(height: 12),
        SlideTransition(
          position: _cardSlideAnimations[2],
          child: _buildQuickAction(Icons.map, const Color(0xFF3D7BFF),
              "View Hazard Map", "See live hazard hotspots & reports", () => Navigator.pushNamed(context, "/map")),
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, Color color, String title, String subtitle, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 26),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLiveFeed() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Live Hazard Feed",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2472))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2472).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text("LIVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0A2472))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text("Real-time alerts from your area", style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 16),
          Column(
            children: hazardFeed.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, String> feed = entry.value;
              return AnimatedContainer(
                duration: Duration(milliseconds: 400 + index * 150),
                curve: Curves.easeOut,
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildHazardCard(feed),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHazardCard(Map<String, String> feed) {
    Color severityColor = Colors.grey;
    if (feed["severity"] == "High") severityColor = Colors.red;
    else if (feed["severity"] == "Moderate") severityColor = Colors.orange;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: _getHazardColor(feed["type"]!).withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(_getHazardIcon(feed["type"]!), color: _getHazardColor(feed["type"]!), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(feed["type"]!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _getHazardColor(feed["type"]!))),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: severityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(feed["severity"]!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: severityColor)),
                    ),
                  ],
                ),
                Text(feed["report"]!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(feed["user"]!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(feed["time"]!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getHazardIcon(String type) {
    switch (type) {
      case "Tsunami":
        return Icons.waves;
      case "High Waves":
        return Icons.water;
      case "Oil Spill":
        return Icons.local_gas_station;
      case "Flood":
        return Icons.flood;
      default:
        return Icons.report;
    }
  }

  Color _getHazardColor(String type) {
    switch (type) {
      case "Tsunami":
        return const Color(0xFF1565C0);
      case "High Waves":
        return const Color(0xFF0277BD);
      case "Oil Spill":
        return const Color(0xFF37474F);
      case "Flood":
        return const Color(0xFF01579B);
      default:
        return const Color(0xFF0A2472);
    }
  }
}
