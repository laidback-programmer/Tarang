# 🌊 Tarang - Maritime Hazard Management System

A comprehensive Flutter application for maritime disaster management, enabling citizens to report hazards and officials to manage emergency responses in real-time.

## 📱 Features

### For Citizens
- **Report Hazards**: Submit maritime incidents with location, photos, and severity levels
- **Live Hazard Map**: Interactive map showing all active reports with color-coded severity markers
- **Real-time Status Tracking**: Track your submitted reports from pending to resolution
- **Community Reports**: View recent hazards reported by other citizens
- **AI Assistant**: Get AI-powered guidance during emergencies
- **Emergency SOS**: Quick access to emergency services
- **News Feed**: Stay updated with maritime safety news

### For Maritime Officials
- **Real-time Dashboard**: Live overview of all reported incidents with statistics
- **Reports Management**: Review, verify, update status, and manage hazard reports
- **Analytics**: Data visualization and trend analysis
- **Alert Management**: Monitor and respond to critical situations
- **Profile Management**: Secure official accounts with role-based access

## 🎨 Design Features

Beautiful **ocean-themed UI** with:
- Gradient backgrounds and modern card designs
- Real-time data updates via Firebase streams
- Interactive maps with custom markers
- Smooth animations and transitions
- Color-coded severity indicators (Critical, High, Medium, Low)
- Enhanced navigation with floating action buttons

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/Tarang.git
cd Tarang
```

2. Install dependencies
```bash
flutter pub get
```

3. Set up Firebase
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add Android/iOS apps to your Firebase project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place config files in appropriate directories
   - Enable Authentication (Email/Password) and Firestore Database

4. Configure Firestore Rules
   - Copy rules from `firestore.rules` to your Firebase Console
   - Deploy the rules to enable proper security

5. Run the app
```bash
flutter run
```

## 📦 Key Dependencies

- **Firebase Suite**: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- **Maps**: `flutter_map`, `latlong2`, `geolocator`
- **UI**: `cached_network_image`, `intl`
- **Media**: `image_picker`, `file_picker`

See `pubspec.yaml` for complete dependency list.

## 🗂️ Project Structure

```
lib/
├── core/              # Constants, styles, colors
├── models/            # Data models (HazardReport, User, etc.)
├── screens/           # UI screens
│   ├── auth/         # Login, signup screens
│   ├── citizen/      # Citizen features (home, report, profile)
│   ├── official/     # Official features (dashboard, management)
│   └── common/       # Shared screens (intro, role selection)
├── services/          # API and business logic
├── widgets/          # Reusable components
└── live_osm_map.dart # Interactive map component
```

## 🔐 Authentication

Two role-based authentication systems:

### Citizens
- Email/password registration
- Profile with personal information
- Submit and track reports

### Officials
- Pre-configured official accounts


## 🗺️ Map Features

- **Interactive OpenStreetMap** integration
- **Color-coded markers** by severity:
  - 🔴 Critical
  - 🟠 High
  - 🟡 Medium
  - 🟢 Low
- **Tap markers** to view report details
- **Current location** tracking
- **Real-time updates** as new reports come in

## 📊 Report Workflow

1. **Citizen submits report** with disaster type, location, severity, description, and photo
2. **Status: Pending** - Awaiting official review
3. **Status: In Progress** - Official is working on it
4. **Status: Resolved** - Issue has been addressed
5. **Citizen can submit new report** once previous one is resolved

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Building for Production

```bash
# Android APK with optimization
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=./debug-info

# Android App Bundle (recommended for Play Store)
flutter build appbundle --release --obfuscate --split-debug-info=./debug-info

# iOS
flutter build ios --release
```

### Code Optimization
- Enable code shrinking in `android/app/build.gradle.kts`
- Use app bundles for 40-50% size reduction
- Optimize images (use WebP format)
- Remove unused dependencies

## 🔥 Firebase Setup

1. **Authentication**: Enable Email/Password sign-in method
2. **Firestore Database**: Create database in production mode
3. **Storage**: Enable Firebase Storage for image uploads
4. **Security Rules**: Deploy the rules from `firestore.rules`

### Firestore Collections
- `users`: User profiles and roles
- `reports`: Hazard reports with location, images, status

## 🌟 Key Features Implementation

### Real-time Updates
All data uses Firebase streams for instant synchronization between citizens and officials.

### Status Tracking
Citizens see real-time status updates without manual refresh when officials change report status.

### Location-based Filtering
Query reports by status, severity, and geographic location.

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web (with limitations on location services)
- ✅ Windows (development)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 👥 Contributors

- [@ArushRastogi47](https://github.com/ArushRastogi47) - Project Developer

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

Built with 💙 for Maritime Safety

---

**Note**: This is an educational project demonstrating Flutter, Firebase, and real-time data management for disaster response systems.
