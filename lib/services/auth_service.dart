import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    String? photoUrl,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);
      if (photoUrl != null) {
        await userCredential.user?.updatePhotoURL(photoUrl);
      }

      // Create user profile in Firestore
      if (userCredential.user != null) {
        await _createUserProfile(
          userId: userCredential.user!.uid,
          email: email,
          name: name,
          phone: phone,
          address: address,
          photoUrl: photoUrl,
        );
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String name,
    required String phone,
    required String address,
    String? photoUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'email': email,
        'name': name,
        'phone': phone,
        'address': address,
        'photo_url': photoUrl,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? address,
    String? photoUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (name != null) {
        updates['name'] = name;
        // Also update Firebase Auth display name
        await _auth.currentUser?.updateDisplayName(name);
      }
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;
      if (photoUrl != null) {
        updates['photo_url'] = photoUrl;
        // Also update Firebase Auth photo URL
        await _auth.currentUser?.updatePhotoURL(photoUrl);
      }

      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      rethrow;
    }
  }

  // Upload profile photo to Firebase Storage
  Future<String> uploadProfilePhoto(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final fileName = 'profile_$userId.jpg';
      final ref = _storage.ref().child('avatars').child(fileName);

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }
}
