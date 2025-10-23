import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

class AlertManagementScreen extends StatefulWidget {
  const AlertManagementScreen({super.key});

  @override
  State<AlertManagementScreen> createState() => _AlertManagementScreenState();
}

class _AlertManagementScreenState extends State<AlertManagementScreen> {
  final List<Alert> alerts = [
    Alert(
      id: 'ALT001',
      type: 'Flood Warning',
      severity: 'High',
      area: 'Coastal Districts',
      status: 'Active',
      issued: '2023-10-15 10:30',
      expires: '2023-10-17 18:00',
    ),
    Alert(
      id: 'ALT002',
      type: 'Cyclone Alert',
      severity: 'Emergency',
      area: 'Eastern Region',
      status: 'Active',
      issued: '2023-10-14 16:45',
      expires: '2023-10-16 12:00',
    ),
    Alert(
      id: 'ALT003',
      type: 'Heat Wave',
      severity: 'Medium',
      area: 'Northern Plains',
      status: 'Expired',
      issued: '2023-10-10 09:15',
      expires: '2023-10-12 20:00',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Alert Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Quick Actions
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: _createNewAlert,
                    icon: const Icon(Icons.add_alert),
                    label: const Text('New Alert'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _sendBroadcast,
                    icon: const Icon(Icons.campaign),
                    label: const Text('Broadcast'),
                  ),
                ],
              ),
            ),
          ),

          // Alerts List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: alerts.length,
              itemBuilder: (context, index) => _buildAlertCard(alerts[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Alert alert) {
    Color severityColor = AppColors.gray;
    if (alert.severity == 'Medium') severityColor = AppColors.warning;
    if (alert.severity == 'High') severityColor = AppColors.error;
    if (alert.severity == 'Emergency') severityColor = Colors.red[900]!;

    Color statusColor = AppColors.gray;
    if (alert.status == 'Active') statusColor = AppColors.success;
    if (alert.status == 'Expired') statusColor = AppColors.warning;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: severityColor.withOpacity(0.2),
          child: Icon(
            Icons.warning,
            color: severityColor,
          ),
        ),
        title: Text(
          alert.type,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Area: ${alert.area}'),
            Text('Issued: ${alert.issued}'),
            Text('Expires: ${alert.expires}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    alert.severity,
                    style: TextStyle(color: AppColors.white, fontSize: 12),
                  ),
                  backgroundColor: severityColor,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    alert.status,
                    style: TextStyle(color: AppColors.white, fontSize: 12),
                  ),
                  backgroundColor: statusColor,
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showAlertActions(alert),
        ),
      ),
    );
  }

  void _showAlertActions(Alert alert) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('View Details'),
            onTap: () {
              Navigator.pop(context);
              _viewAlertDetails(alert);
            },
          ),
          if (alert.status == 'Active') ...[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Alert'),
              onTap: () {
                Navigator.pop(context);
                _editAlert(alert);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Deactivate Alert'),
              onTap: () {
                Navigator.pop(context);
                _deactivateAlert(alert);
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Alert'),
            onTap: () {
              Navigator.pop(context);
              _deleteAlert(alert);
            },
          ),
        ],
      ),
    );
  }

  void _createNewAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Alert'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Alert Type'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Affected Area'),
              ),
              DropdownButtonFormField(
                items: ['Low', 'Medium', 'High', 'Emergency']
                    .map((severity) => DropdownMenuItem(
                          value: severity,
                          child: Text(severity),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Severity Level'),
                onChanged: (value) {},
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Message'),
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
            child: const Text('Create Alert'),
          ),
        ],
      ),
    );
  }

  void _sendBroadcast() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Broadcast Message'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Broadcast Message'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Send to All Users'),
          ),
        ],
      ),
    );
  }

  void _viewAlertDetails(Alert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alert Details - ${alert.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${alert.type}'),
              Text('Severity: ${alert.severity}'),
              Text('Area: ${alert.area}'),
              Text('Status: ${alert.status}'),
              Text('Issued: ${alert.issued}'),
              Text('Expires: ${alert.expires}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editAlert(Alert alert) {
    // Implementation for editing alert
  }

  void _deactivateAlert(Alert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Alert'),
        content: const Text('Are you sure you want to deactivate this alert?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Deactivate logic here
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _deleteAlert(Alert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert'),
        content: const Text('Are you sure you want to delete this alert? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete logic here
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class Alert {
  final String id;
  final String type;
  final String severity;
  final String area;
  final String status;
  final String issued;
  final String expires;

  Alert({
    required this.id,
    required this.type,
    required this.severity,
    required this.area,
    required this.status,
    required this.issued,
    required this.expires,
  });
}