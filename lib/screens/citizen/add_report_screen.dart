import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddReportScreen extends StatefulWidget {
  static const String routeName = '/add_report';

  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? selectedDisaster;
  String? selectedSeverity;
  Position? _currentPosition;
  List<PlatformFile> uploadedFiles = [];
  bool _isSubmitting = false;
  bool _isGettingLocation = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Track existing report status
  String? _currentReportStatus;
  String? _currentReportId;
  bool _hasActiveReport = false;

  final List<Map<String, dynamic>> disasterTypes = [
    {"name": "Flood", "icon": Icons.water_damage, "color": Colors.blue},
    {"name": "Cyclone", "icon": Icons.cyclone, "color": Colors.deepPurple},
    {"name": "Tsunami", "icon": Icons.waves, "color": Colors.indigo},
    {"name": "Earthquake", "icon": Icons.vibration, "color": Colors.brown},
    {
      "name": "Fire",
      "icon": Icons.local_fire_department,
      "color": Colors.deepOrange
    },
    {"name": "Oil Spill", "icon": Icons.opacity, "color": Colors.black87},
    {
      "name": "Landslide",
      "icon": Icons.terrain,
      "color": Colors.brown.shade700
    },
    {"name": "Storm Surge", "icon": Icons.storm, "color": Colors.blueGrey},
    {
      "name": "Coastal Erosion",
      "icon": Icons.landscape,
      "color": Colors.amber.shade900
    },
  ];

  final List<Map<String, dynamic>> severityLevels = [
    {"name": "Low", "icon": Icons.info_outline, "color": Colors.green},
    {"name": "Medium", "icon": Icons.warning_amber, "color": Colors.orange},
    {"name": "High", "icon": Icons.priority_high, "color": Colors.deepOrange},
    {"name": "Critical", "icon": Icons.error_outline, "color": Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _checkExistingReport();
  }

  Future<void> _checkExistingReport() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Query for any pending or in-progress reports by this user
      // Note: Removed orderBy to avoid composite index requirement
      final snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: ['pending', 'in progress'])
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        setState(() {
          _hasActiveReport = true;
          _currentReportStatus = data['status'] ?? 'pending';
          _currentReportId = doc.id;
        });
      } else {
        // No active reports found
        setState(() {
          _hasActiveReport = false;
          _currentReportStatus = null;
          _currentReportId = null;
        });
      }
    } catch (e) {
      print('Error checking existing report: $e');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.media,
        withData: kIsWeb,
      );
      if (result != null) setState(() => uploadedFiles.addAll(result.files));
    } catch (e) {
      _showError("Failed to pick files: ${e.toString()}");
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError("Please enable location services");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError("Location permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError("Location permission permanently denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _currentPosition = position;
        _locationController.text =
            "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      });
      _showSuccess("Location fetched successfully!");
    } catch (e) {
      _showError("Failed to get location: ${e.toString()}");
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _submitReport() async {
    if (!_validateForm()) return;
    setState(() => _isSubmitting = true);

    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError("You must be logged in to submit a report");
        setState(() => _isSubmitting = false);
        return;
      }

      // Get user profile data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userName = userDoc.data()?['name'] ?? user.email ?? 'Anonymous';

      // Upload first image to Firebase Storage (if available)
      String? imageUrl;
      if (uploadedFiles.isNotEmpty) {
        try {
          final firstImage = uploadedFiles.first;
          final ext = p.extension(firstImage.name).toLowerCase();

          // Only upload image files
          if ([".jpg", ".jpeg", ".png"].contains(ext)) {
            final fileName =
                '${user.uid}_${DateTime.now().millisecondsSinceEpoch}$ext';
            final storageRef =
                FirebaseStorage.instance.ref().child('reports').child(fileName);

            // Upload the file
            if (kIsWeb && firstImage.bytes != null) {
              final uploadTask = await storageRef.putData(
                firstImage.bytes!,
                SettableMetadata(
                    contentType: 'image/${ext.replaceAll(".", "")}'),
              );
              imageUrl = await uploadTask.ref.getDownloadURL();
            } else if (firstImage.path != null) {
              final uploadTask = await storageRef.putFile(
                File(firstImage.path!),
                SettableMetadata(
                    contentType: 'image/${ext.replaceAll(".", "")}'),
              );
              imageUrl = await uploadTask.ref.getDownloadURL();
            }
          }
        } catch (storageError) {
          print('Storage upload error: $storageError');
          // Continue without image if storage fails
          imageUrl = null;
        }
      }

      // Create report document in Firestore
      final reportData = {
        'userId': user.uid,
        'userName': userName,
        'userEmail': user.email,
        'disasterType': selectedDisaster,
        'severity': selectedSeverity ?? 'Medium',
        'description': _descriptionController.text.trim(),
        'imageUrl': imageUrl,
        'location': {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'address': _locationController.text,
        },
        'deviceLocation': {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
        },
        'status': 'pending', // pending, verified, resolved
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('reports').add(reportData);

      if (mounted) {
        _showSuccess("Report submitted successfully!");
        _resetForm();
        // Check again for any active reports
        _checkExistingReport();
      }
    } catch (e) {
      if (mounted) {
        _showError("Failed to submit report: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool _validateForm() {
    if (selectedDisaster == null) {
      _showError("Select a disaster type");
      return false;
    }
    if (_descriptionController.text.isEmpty) {
      _showError("Provide description");
      return false;
    }
    if (_descriptionController.text.trim().length < 10) {
      _showError("Description must be at least 10 characters");
      return false;
    }
    if (uploadedFiles.isEmpty) {
      _showError("Upload at least one image");
      return false;
    }
    // Check if first file is an image
    final firstFile = uploadedFiles.first;
    final ext = p.extension(firstFile.name).toLowerCase();
    if (![".jpg", ".jpeg", ".png"].contains(ext)) {
      _showError("First file must be an image (JPG/PNG)");
      return false;
    }
    if (_currentPosition == null) {
      _showError("Fetch current location");
      return false;
    }
    return true;
  }

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );

  void _showSuccess(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );

  void _resetForm() {
    setState(() {
      selectedDisaster = null;
      selectedSeverity = null;
      _descriptionController.clear();
      _locationController.clear();
      uploadedFiles.clear();
      _currentPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: const Text("Report Maritime Hazard",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF0A6FB8), const Color(0xFF006994)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _hasActiveReport
          ? _buildActiveReportView()
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      title: "What happened?",
                      icon: Icons.report_problem_outlined,
                      child: _buildDisasterTypeSelector(),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionCard(
                      title: "How severe is it?",
                      icon: Icons.speed,
                      child: _buildSeveritySelector(),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionCard(
                      title: "Describe the situation",
                      icon: Icons.description_outlined,
                      child: _buildDescriptionField(),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionCard(
                      title: "Add visual evidence",
                      icon: Icons.photo_camera_outlined,
                      child: _buildMediaUpload(),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionCard(
                      title: "Where is this happening?",
                      icon: Icons.location_on_outlined,
                      child: _buildLocationField(),
                    ),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildActiveReportView() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _currentReportId != null
          ? FirebaseFirestore.instance
              .collection('reports')
              .doc(_currentReportId)
              .snapshots()
          : null,
      builder: (context, snapshot) {
        // Get the latest status from the stream
        String currentStatus = _currentReportStatus ?? 'pending';
        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          currentStatus = data?['status'] ?? 'pending';
        }

        Color statusColor;
        IconData statusIcon;
        String statusText;
        String message;
        bool showNewReportButton = false;

        switch (currentStatus.toLowerCase()) {
          case 'in progress':
            statusColor = Colors.blue;
            statusIcon = Icons.sync;
            statusText = 'In Progress';
            message =
                'Officials are actively working on your report. We\'ll notify you when it\'s resolved.';
            break;
          case 'resolved':
            statusColor = Colors.green;
            statusIcon = Icons.check_circle;
            statusText = 'Resolved';
            message =
                'Your report has been successfully resolved by maritime officials. Thank you for keeping our waters safe!';
            showNewReportButton = true;
            break;
          default: // pending
            statusColor = Colors.orange;
            statusIcon = Icons.pending;
            statusText = 'Pending Review';
            message =
                'Your report is awaiting review by maritime officials. You\'ll be notified of any status changes.';
        }

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(statusIcon, size: 64, color: statusColor),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Report $statusText',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor, width: 1.5),
                        ),
                        child: Text(
                          statusText.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      if (!showNewReportButton) ...[
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF0A6FB8).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF0A6FB8)
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Color(0xFF0A6FB8), size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You can submit a new report once this one is resolved.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (showNewReportButton) ...[
                        // Resolved - show button to create new report
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0A6FB8), Color(0xFF006994)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0A6FB8)
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _hasActiveReport = false;
                                _currentReportId = null;
                                _currentReportStatus = null;
                              });
                            },
                            icon:
                                const Icon(Icons.add_circle_outline, size: 22),
                            label: const Text(
                              'Report New Hazard',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.home, size: 20),
                          label: const Text('Go to Home'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF0A6FB8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                        ),
                      ] else ...[
                        // Not resolved yet - show refresh button
                        ElevatedButton.icon(
                          onPressed: () {
                            // Refresh to check status
                            _checkExistingReport();
                          },
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text('Refresh Status'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A6FB8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0A6FB8).withValues(alpha: 0.1),
            const Color(0xFF006994).withValues(alpha: 0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFF0A6FB8).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A6FB8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.campaign, color: Color(0xFF0A6FB8), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Help Keep Others Safe",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A6FB8)),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your report helps authorities respond quickly to maritime hazards",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0A6FB8), size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDisasterTypeSelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: disasterTypes.length,
      itemBuilder: (context, index) {
        final type = disasterTypes[index];
        final isSelected = selectedDisaster == type['name'];
        return GestureDetector(
          onTap: () =>
              setState(() => selectedDisaster = type['name'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? (type['color'] as Color).withValues(alpha: 0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? (type['color'] as Color)
                    : Colors.grey.shade300,
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type['icon'] as IconData,
                  color: isSelected
                      ? (type['color'] as Color)
                      : Colors.grey.shade600,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  type['name'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? (type['color'] as Color)
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeveritySelector() {
    return Row(
      children: severityLevels.map((level) {
        final isSelected = selectedSeverity == level['name'];
        final color = level['color'] as Color;
        return Expanded(
          child: GestureDetector(
            onTap: () =>
                setState(() => selectedSeverity = level['name'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    level['icon'] as IconData,
                    color: isSelected ? color : Colors.grey.shade600,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    level['name'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? color : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText:
            "Provide detailed information about the hazard, its impact, and any immediate dangers...",
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A6FB8), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildMediaUpload() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0A6FB8).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0A6FB8).withValues(alpha: 0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A6FB8).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: Color(0xFF0A6FB8),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Tap to upload photos or videos",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A6FB8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${uploadedFiles.length} file(s) selected",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (uploadedFiles.isNotEmpty) const SizedBox(height: 16),
        if (uploadedFiles.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: uploadedFiles.length,
            itemBuilder: (context, index) {
              final file = uploadedFiles[index];
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.grey.shade50,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildMediaThumbnail(file),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => uploadedFiles.removeAt(index)),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildMediaThumbnail(PlatformFile file) {
    final ext = p.extension(file.name).toLowerCase();
    if ([".jpg", ".jpeg", ".png"].contains(ext)) {
      return kIsWeb
          ? Image.memory(file.bytes!, fit: BoxFit.cover)
          : File(file.path!).existsSync()
              ? Image.file(File(file.path!), fit: BoxFit.cover)
              : const Icon(Icons.image_not_supported);
    } else if ([".mp4", ".mov"].contains(ext)) {
      return const Center(child: Icon(Icons.videocam, size: 40));
    }
    return const Center(child: Icon(Icons.insert_drive_file, size: 40));
  }

  Widget _buildLocationField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _locationController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: "Tap the button to get current location",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon:
                  const Icon(Icons.location_on, color: Color(0xFF0A6FB8)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF0A6FB8), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              suffixIcon: _isGettingLocation
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0A6FB8),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A6FB8), Color(0xFF006994)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A6FB8).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.my_location, size: 24),
            onPressed: _isGettingLocation ? null : _getCurrentLocation,
            color: Colors.white,
            padding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A6FB8), Color(0xFF006994)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A6FB8).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.send, color: Colors.white, size: 22),
                  SizedBox(width: 12),
                  Text(
                    "SUBMIT REPORT",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
