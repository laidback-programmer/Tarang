# Authentication System Setup Guide

This guide explains how to set up the complete authentication system with Supabase for the Tarang app.

## 📦 Required Dependencies

Add these dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Existing dependencies
  cached_network_image: ^3.3.0
  intl: ^0.18.1
  
  # NEW - Authentication & Database
  supabase_flutter: ^2.0.0
  
  # NEW - Image Picker
  image_picker: ^1.0.4
```

Run `flutter pub get` after adding these dependencies.

## 🗄️ Supabase Setup

### 1. Create a Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in
3. Click "New Project"
4. Fill in your project details
5. Wait for the project to be created

### 2. Get Your Supabase Credentials

From your Supabase project dashboard:
1. Go to Project Settings (gear icon)
2. Click on "API"
3. Copy your:
   - Project URL (anon/public key)
   - anon/public API key

### 3. Initialize Supabase in Your App

Update your `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(const MyApp());
}
```

### 4. Create Database Tables

In your Supabase dashboard, go to the SQL Editor and run this SQL:

```sql
-- Create users table
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies
-- Users can read their own data
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Users can insert their own data
CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);
```

### 5. Create Storage Bucket for Profile Photos

In your Supabase dashboard:

1. Go to Storage
2. Click "Create bucket"
3. Name it `avatars`
4. Make it **public** (so profile photos can be accessed)
5. Click "Save"

Set up storage policies:

```sql
-- Allow authenticated users to upload their own profile photos
CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow public read access to avatars
CREATE POLICY "Avatars are publicly accessible"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'avatars');

-- Allow users to update their own avatar
CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
```

### 6. Enable Email Authentication

In Supabase dashboard:
1. Go to Authentication → Settings
2. Ensure "Enable Email Signup" is checked
3. Configure email templates if needed
4. Set up SMTP (optional, for custom emails)

## 📱 App Flow

### Current Authentication Flow:

1. **Intro Screen** → User sees app introduction
2. **Role Selection Screen** → User selects Citizen or Official role
3. **Login Screen** → User logs in with email & password
   - Or clicks "Sign Up" to create account
   - Or clicks "Forgot Password" to reset
4. **Signup Screen** → New users register with:
   - Full Name
   - Email
   - Phone Number
   - Address
   - Password
   - Profile Photo (optional)
5. **Home Screen** → User accesses app features
6. **Profile Screen** → User can view details and logout

## 🎨 UI Theme

All authentication screens follow the **ocean and sea theme**:
- Animated wave backgrounds
- Blue gradient overlays (primary + secondary colors)
- White text for contrast
- Ocean-themed icons (waves, sailing, etc.)
- Smooth animations and transitions

## 🔐 Features Implemented

### ✅ Login Screen
- Email and password fields
- Password visibility toggle
- Form validation
- "Forgot Password" link
- "Sign Up" link
- Ocean-themed animated background
- Loading state during authentication

### ✅ Signup Screen
- Full name field
- Email field
- Phone number field (with validation)
- Address field (multiline)
- Password field with confirmation
- Profile photo upload
- Form validation
- Ocean-themed animated background
- Loading state during registration

### ✅ Forgot Password Screen
- Email field
- Send reset link functionality
- Success confirmation screen
- Ocean-themed animated background

### ✅ Profile Screen
- Display user information:
  - Profile photo
  - Name
  - Email
  - Phone number
  - Address
  - Member since date
- Edit profile button (placeholder)
- Logout button with confirmation dialog
- Ocean-themed animated background
- Loading states

### ✅ Auth Service
- Sign up with email/password
- Sign in with email/password
- Sign out
- Password reset
- Get user profile
- Update user profile
- Upload profile photo
- Current user management

## 🔧 Required Fixes

### Minor Styling Issues:

Some style properties might not exist in your current `AppStyles` class. You may need to add:

```dart
// In lib/core/constants/app_styles.dart
class AppStyles {
  // ... existing styles ...
  
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
  );
}
```

Also add to `AppColors`:

```dart
// In lib/core/constants/app_colors.dart
class AppColors {
  // ... existing colors ...
  
  static const Color secondary = Color(0xFF006994);
}
```

## 📝 Route Configuration

Make sure to add routes in your app's route configuration:

```dart
MaterialApp(
  // ... other properties ...
  routes: {
    '/': (context) => const IntroScreen(),
    '/role-selection': (context) => const RoleSelectionScreen(),
    '/login': (context) => const LoginScreen(),
    '/signup': (context) => const SignupScreen(),
    '/forgot-password': (context) => const ForgotPasswordScreen(),
    '/citizen-home': (context) => const CitizenHomeScreen(),
    '/profile': (context) => const ProfileScreen(),
    // ... other routes ...
  },
);
```

## 🚀 Testing the App

### 1. Test User Registration:
- Run the app
- Select "Citizen" role
- Click "Sign Up"
- Fill in all fields
- Upload a photo (optional)
- Click "Sign Up"
- Check if you're redirected to login

### 2. Test Login:
- Enter registered email and password
- Click "Login"
- Should redirect to home screen

### 3. Test Profile:
- Navigate to profile screen
- Verify all user data is displayed
- Try the logout button

### 4. Test Forgot Password:
- On login screen, click "Forgot Password?"
- Enter your email
- Check your email for reset link

## 📊 Database Schema

### users table:
```
id: UUID (primary key, references auth.users)
email: TEXT (not null, unique)
name: TEXT (not null)
phone: TEXT (not null)
address: TEXT (not null)
photo_url: TEXT (nullable)
created_at: TIMESTAMP (default: now())
updated_at: TIMESTAMP (default: now())
```

## 🔒 Security Notes

1. **Row Level Security (RLS)** is enabled on the users table
2. Users can only read/update their own data
3. Profile photos are stored in a public bucket
4. Authentication uses Supabase's built-in security
5. Passwords are never stored in plain text
6. API keys should be kept secure (consider using environment variables in production)

## 🎯 Next Steps

1. Add password requirements validation
2. Implement email verification
3. Add social auth (Google, Apple)
4. Add edit profile functionality
5. Add user avatar cropping
6. Implement offline support
7. Add biometric authentication
8. Create admin panel for official users

## 🐛 Troubleshooting

### Common Issues:

**"Target of URI doesn't exist: 'package:supabase_flutter'"**
- Run `flutter pub get`
- Make sure dependency is added to pubspec.yaml

**"Unable to load profile"**
- Check Supabase connection
- Verify database table exists
- Check RLS policies are set correctly

**"Image picker not working"**
- Add platform-specific permissions:
  - iOS: Update Info.plist
  - Android: Update AndroidManifest.xml

**Authentication errors**
- Verify Supabase URL and API key
- Check internet connection
- Ensure email authentication is enabled in Supabase

## 📞 Support

For issues or questions:
- Check Supabase documentation: https://supabase.com/docs
- Flutter documentation: https://flutter.dev/docs
- Image Picker: https://pub.dev/packages/image_picker

---

**Created for Tarang - Maritime Hazard Management App** 🌊
