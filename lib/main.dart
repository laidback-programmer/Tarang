import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Common Screens
import 'screens/common/intro_screen.dart';
import 'screens/common/role_selection_screen.dart';

// Auth Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/official_login_screen.dart';

// Citizen Screens
import 'screens/citizen/citizen_home_screen.dart';
import 'screens/citizen/add_report_screen.dart';
import 'screens/citizen/emergency_screen.dart';
import 'screens/citizen/news_screen.dart';
import 'screens/citizen/ai_assistant_screen.dart';
import 'screens/citizen/profile_screen.dart';

// Official Screens
import 'screens/official/official_dashboard_screen.dart';
import 'screens/official/reports_management_screen.dart';
import 'screens/official/analytics_screen.dart';
import 'screens/official/alert_management_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

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

      // Check auth state and navigate accordingly
      home: const AuthWrapper(),

      // Named routes for navigation
      routes: {
        // Common
        '/intro': (context) => const IntroScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),

        // Auth
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/official-login': (context) => const OfficialLoginScreen(),

        // Citizen
        '/citizen-home': (context) => const CitizenHomeScreen(),
        '/add-report': (context) => const AddReportScreen(),
        '/emergency': (context) => const EmergencyScreen(),
        '/news': (context) => const NewsScreen(),
        '/ai-assistant': (context) => const AiAssistantScreen(),
        '/profile': (context) => const ProfileScreen(),

        // Official
        '/official-dashboard': (context) => const OfficialDashboardScreen(),
        '/reports-management': (context) => ReportsManagementScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/alert-management': (context) => const AlertManagementScreen(),
      },
    );
  }
}

// Auth wrapper to check if user is already logged in
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is logged in, go to home screen
        if (snapshot.hasData && snapshot.data != null) {
          return const CitizenHomeScreen();
        }

        // Otherwise, show intro screen
        return const IntroScreen();
      },
    );
  }
}
