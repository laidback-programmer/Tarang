import 'package:flutter/material.dart';
import '../../widgets/common/enhanced_ocean_nav.dart';

class NavItems {
  // Citizen Navigation Items
  static const List<OceanNavItem> citizenItems = [
    OceanNavItem(
      icon: Icons.home_rounded,
      label: 'Home',
      tooltip: 'Home Dashboard',
    ),
    OceanNavItem(
      icon: Icons.newspaper_rounded,
      label: 'News',
      tooltip: 'Latest News',
    ),
    OceanNavItem(
      icon: Icons.add_circle_rounded,
      label: 'Report',
      tooltip: 'Report Hazard',
    ),
    OceanNavItem(
      icon: Icons.emergency_rounded,
      label: 'Emergency',
      tooltip: 'Emergency SOS',
    ),
    OceanNavItem(
      icon: Icons.assistant_rounded,
      label: 'Assistant',
      tooltip: 'AI Assistant',
    ),
  ];

  // Official Navigation Items
  static const List<OceanNavItem> officialItems = [
    OceanNavItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      tooltip: 'Dashboard Overview',
    ),
    OceanNavItem(
      icon: Icons.list_alt_rounded,
      label: 'Reports',
      tooltip: 'Manage Reports',
    ),
    OceanNavItem(
      icon: Icons.analytics_rounded,
      label: 'Analytics',
      tooltip: 'View Analytics',
    ),
    OceanNavItem(
      icon: Icons.warning_rounded,
      label: 'Alerts',
      tooltip: 'Alert Management',
    ),
  ];
}
