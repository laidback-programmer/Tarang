import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

class ReportsManagementScreen extends StatefulWidget {
  static const String routeName = '/reports-management';

  @override
  State<ReportsManagementScreen> createState() =>
      _ReportsManagementScreenState();
}

class _ReportsManagementScreenState extends State<ReportsManagementScreen> {
  final List<Report> reports = [
    Report(
      id: '#RPT001',
      type: 'Flood',
      location: 'District 5, Sector 2',
      status: 'Pending',
      priority: 'High',
      date: '2023-10-15 14:30',
      description: 'Water level rising rapidly in residential area',
    ),
    Report(
      id: '#RPT002',
      type: 'Fire',
      location: 'Industrial Zone, Block C',
      status: 'In Progress',
      priority: 'Alert',
      date: '2023-10-15 12:45',
      description: 'Factory fire with chemical hazards',
    ),
    Report(
      id: '#RPT003',
      type: 'Earthquake',
      location: 'Northern Region',
      status: 'Resolved',
      priority: 'Medium',
      date: '2023-10-14 09:20',
      description: 'Minor tremors felt, no major damage reported',
    ),
  ];

  String filterStatus = 'All';
  String filterPriority = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredReports = reports.where((report) {
      final statusMatch =
          filterStatus == 'All' || report.status == filterStatus;
      final priorityMatch =
          filterPriority == 'All' || report.priority == filterPriority;
      return statusMatch && priorityMatch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Reports Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Filters
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: filterStatus,
                      items: ['All', 'Pending', 'In Progress', 'Resolved']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => filterStatus = value!),
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: filterPriority,
                      items: ['All', 'Low', 'Medium', 'High', 'Emergency']
                          .map((priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(priority),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => filterPriority = value!),
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Reports List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredReports.length,
              itemBuilder: (context, index) =>
                  _buildReportCard(filteredReports[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReportDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    Color statusColor = AppColors.gray;
    if (report.status == 'Pending') statusColor = AppColors.warning;
    if (report.status == 'In Progress') statusColor = AppColors.info;
    if (report.status == 'Resolved') statusColor = AppColors.success;

    Color priorityColor = AppColors.gray;
    if (report.priority == 'Medium') priorityColor = AppColors.warning;
    if (report.priority == 'High') priorityColor = AppColors.error;
    if (report.priority == 'Emergency') priorityColor = Colors.red[900]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getReportTypeColor(report.type),
          child: Icon(
            _getReportTypeIcon(report.type),
            color: AppColors.white,
            size: 20,
          ),
        ),
        title: Text(
          report.type,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.location),
            Text(report.description,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    report.status,
                    style: TextStyle(color: AppColors.white, fontSize: 12),
                  ),
                  backgroundColor: statusColor,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    report.priority,
                    style: TextStyle(color: AppColors.white, fontSize: 12),
                  ),
                  backgroundColor: priorityColor,
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => _showReportDetails(report),
        ),
      ),
    );
  }

  Color _getReportTypeColor(String type) {
    switch (type) {
      case 'Flood':
        return Colors.blue;
      case 'Fire':
        return Colors.red;
      case 'Earthquake':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  IconData _getReportTypeIcon(String type) {
    switch (type) {
      case 'Flood':
        return Icons.water_damage;
      case 'Fire':
        return Icons.local_fire_department;
      case 'Earthquake':
        return Icons.terrain;
      default:
        return Icons.warning;
    }
  }

  void _showReportDetails(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Details - ${report.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${report.type}'),
              Text('Location: ${report.location}'),
              Text('Date: ${report.date}'),
              Text('Status: ${report.status}'),
              Text('Priority: ${report.priority}'),
              const SizedBox(height: 16),
              const Text('Description:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(report.description),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Update Status'),
          ),
        ],
      ),
    );
  }

  void _showAddReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Report'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Report Type'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Add Report'),
          ),
        ],
      ),
    );
  }
}

class Report {
  final String id;
  final String type;
  final String location;
  final String status;
  final String priority;
  final String date;
  final String description;

  Report({
    required this.id,
    required this.type,
    required this.location,
    required this.status,
    required this.priority,
    required this.date,
    required this.description,
  });
}
