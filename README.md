# 🌊 Tarang - Maritime Hazard Management System

A comprehensive Flutter application for maritime disaster management, enabling citizens to report hazards and officials to manage emergency responses.

## 📱 Features

### For Citizens
- **Report Hazards**: Submit maritime incidents with location, photos, and details
- **AI-Powered Disaster News**: Real-time disaster alerts using Gemini AI with web scraping & NLP
- **Location-Based Alerts**: Get notified about disasters within 500km radius
- **AI Assistant**: Get AI-powered guidance during emergencies
- **Emergency SOS**: Quick access to emergency services

### For Maritime Officials
- **Dashboard**: Overview of all reported incidents and analytics
- **Reports Management**: Review, verify, and update hazard reports
- **Alert System**: Send warnings and alerts to affected areas
- **Analytics**: Data visualization and trend analysis

## 🎨 Design Theme

Beautiful **ocean-themed UI** with:
- Animated wave backgrounds
- Smooth transitions and ripple effects
- Enhanced ocean navigation bar
- Gradient overlays and water-inspired animations

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Supabase account (for authentication)

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

3. Set up Supabase (see [AUTHENTICATION_SETUP.md](AUTHENTICATION_SETUP.md))

4. Set up Gemini API (see [GEMINI_SETUP.md](GEMINI_SETUP.md))

5. Run the app
```bash
flutter run
```

## 📦 Dependencies

- `cached_network_image` - Image caching
- `intl` - Internationalization
- `geolocator` - Location services
- `image_picker` - Photo uploads
- `supabase_flutter` - Backend & authentication
- `http` - API requests & Gemini AI integration
- `file_picker` - Media file selection

## 🗂️ Project Structure

```
lib/
├── core/              # Core utilities, constants, enums
├── models/            # Data models
├── providers/         # State management
├── screens/           # UI screens
│   ├── auth/         # Login, signup, forgot password
│   ├── citizen/      # Citizen-specific screens
│   ├── official/     # Official-specific screens
│   └── common/       # Shared screens
├── services/          # API and business logic
└── widgets/          # Reusable UI components
```

## 🔐 Authentication

The app includes a complete authentication system:
- Email/Password login
- User registration with profile photo
- Password reset
- Role-based access (Citizen/Official)

See [AUTHENTICATION_SETUP.md](AUTHENTICATION_SETUP.md) for detailed setup instructions.

## 🌐 API Integration

- **Supabase**: Backend, database, and authentication
- **Gemini AI**: AI-powered disaster news with web scraping & NLP analysis
- **Geocoding**: Location-based services and reverse geocoding
- **Real-time Alerts**: Location-based disaster monitoring (500km radius)

See [GEMINI_SETUP.md](GEMINI_SETUP.md) for Gemini API configuration.

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📄 License

This project is open source and available under the MIT License.

## 👥 Contributors

- [Your Name]

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for backend infrastructure
- OpenStreetMap for mapping services

---

**Made with 💙 for Maritime Safety**
