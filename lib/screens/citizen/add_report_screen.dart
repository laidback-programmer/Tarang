import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:geolocator/geolocator.dart';

class AddReportScreen extends StatefulWidget {
  static const String routeName = '/add_report';

  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? selectedDisaster;
  String? selectedSeverity;
  Position? _currentPosition;
  List<PlatformFile> uploadedFiles = [];
  bool _isSubmitting = false;
  bool _isGettingLocation = false;

  final List<String> disasterTypes = [
    "Flood", "Cyclone", "Tsunami", "Earthquake", "Fire", 
    "Oil Spill", "Landslide", "Storm Surge", "Coastal Erosion"
  ];

  final List<String> severityLevels = ["Low", "Medium", "High", "Critical"];

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

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
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
    if (selectedDisaster == null) { _showError("Select a disaster type"); return false; }
    if (_descriptionController.text.isEmpty) { _showError("Provide description"); return false; }
    if (uploadedFiles.isEmpty) { _showError("Upload at least one photo/video"); return false; }
    if (_currentPosition == null) { _showError("Fetch current location"); return false; }
    return true;
  }

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );

  void _showSuccess(String message) => ScaffoldMessenger.of(context).showSnackBar(
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
      appBar: AppBar(title: const Text("Report Hazard"), centerTitle: true, backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle("Hazard Type"),
            _buildDisasterTypeSelector(),
            const SizedBox(height: 16),
            _buildSectionTitle("Severity"),
            _buildSeveritySelector(),
            const SizedBox(height: 16),
            _buildSectionTitle("Description"),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildSectionTitle("Upload Photos/Videos"),
            _buildMediaUpload(),
            const SizedBox(height: 16),
            _buildSectionTitle("Location"),
            _buildLocationField(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal.shade800));

  Widget _buildDisasterTypeSelector() => Wrap(
        spacing: 8,
        children: disasterTypes.map((type) {
          final isSelected = selectedDisaster == type;
          return ChoiceChip(
            label: Text(type),
            selected: isSelected,
            onSelected: (_) => setState(() => selectedDisaster = type),
            selectedColor: Colors.teal,
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          );
        }).toList(),
      );

  Widget _buildSeveritySelector() => Wrap(
        spacing: 8,
        children: severityLevels.map((level) {
          final isSelected = selectedSeverity == level;
          final color = _getSeverityColor(level);
          return ChoiceChip(
            label: Text(level),
            selected: isSelected,
            onSelected: (_) => setState(() => selectedSeverity = level),
            selectedColor: color,
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          );
        }).toList(),
      );

  Color _getSeverityColor(String level) {
    switch (level) {
      case "Critical": return Colors.red;
      case "High": return Colors.orange;
      case "Medium": return Colors.yellow;
      case "Low": return Colors.green;
      default: return Colors.teal;
    }
  }

  Widget _buildDescriptionField() => TextField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: "Describe the situation...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      );

  Widget _buildMediaUpload() => Column(
        children: [
          ElevatedButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.upload),
            label: Text("UPLOAD (${uploadedFiles.length})"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade800,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          if (uploadedFiles.isNotEmpty) const SizedBox(height: 8),
          if (uploadedFiles.isNotEmpty) SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: uploadedFiles.length,
              itemBuilder: (context, index) {
                final file = uploadedFiles[index];
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                      child: _buildMediaThumbnail(file),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => uploadedFiles.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );

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

  Widget _buildLocationField() => Row(
        children: [
          Expanded(
            child: TextField(
              controller: _locationController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "Current location",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: _isGettingLocation ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _isGettingLocation ? null : _getCurrentLocation,
            style: IconButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
          ),
        ],
      );

  Widget _buildSubmitButton() => ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSubmitting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("SUBMIT REPORT", style: TextStyle(fontSize: 16)),
      );
}
