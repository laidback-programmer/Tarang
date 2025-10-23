import 'package:flutter/material.dart';

// Common Screens
import 'screens/common/intro_screen.dart';
import 'screens/common/role_selection_screen.dart';
// Citizen Screens
import 'screens/citizen/citizen_home_screen.dart';
import 'screens/citizen/add_report_screen.dart';
import 'screens/citizen/emergency_screen.dart';
import 'screens/citizen/news_screen.dart';
import 'screens/citizen/ai_assistant_screen.dart';

// Official Screens (inside official folder)
import 'screens/official/official_dashboard_screen.dart';
import 'screens/official/reports_management_screen.dart';
import 'screens/official/analytics_screen.dart';
import 'screens/official/alert_management_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarang',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),

      // Start with intro screen
      home: const IntroScreen(),

      // Named routes for navigation
      routes: {
        // Common
        '/intro': (context) => const IntroScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),

        // Citizen
        '/citizen-home': (context) => const CitizenHomeScreen(),
        '/add-report': (context) => const AddReportScreen(),
        '/emergency': (context) => const EmergencyScreen(),
        '/news': (context) => const NewsScreen(),
        '/ai-assistant': (context) => const AiAssistantScreen(),

        // Official
        // Official
        '/official-dashboard': (context) => OfficialDashboardScreen(),
        '/reports-management': (context) => ReportsManagementScreen(),
        '/analytics': (context) => AnalyticsScreen(),
        '/alert-management': (context) => AlertManagementScreen(),
      },
    );
  }
}
