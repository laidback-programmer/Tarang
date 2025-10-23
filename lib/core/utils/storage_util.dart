import 'package:shared_preferences/shared_preferences.dart';
import '../enums/user_role.dart';

class StorageUtil {
  static Future<void> saveUserRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role.name);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<void> removeUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
  }
}
