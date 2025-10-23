import 'package:flutter/material.dart';
import 'storage_util.dart';
import '../enums/user_role.dart';

class RoleManager with ChangeNotifier {
  static UserRole? _currentRole;

  static UserRole? get currentRole => _currentRole;

  static Future<void> setUserRole(UserRole role) async {
    _currentRole = role;
    await StorageUtil.saveUserRole(role);
  }
}
