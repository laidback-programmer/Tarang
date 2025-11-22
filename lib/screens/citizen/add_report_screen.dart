import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

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

  void _submitReport() async {
    if (!_validateForm()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate API
    setState(() => _isSubmitting = false);
    _showSuccess("Report submitted successfully!");
    _resetForm();
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
    if (uploadedFiles.isEmpty) {
      _showError("Upload at least one photo/video");
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
      body: FadeTransition(
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

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0A6FB8).withOpacity(0.1),
            const Color(0xFF006994).withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0A6FB8).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A6FB8).withOpacity(0.1),
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
            color: Colors.black.withOpacity(0.05),
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
                  ? (type['color'] as Color).withOpacity(0.1)
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
                color:
                    isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
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
              color: const Color(0xFF0A6FB8).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0A6FB8).withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A6FB8).withOpacity(0.1),
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
                              color: Colors.black.withOpacity(0.2),
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
                color: const Color(0xFF0A6FB8).withOpacity(0.3),
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
            color: const Color(0xFF0A6FB8).withOpacity(0.4),
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
