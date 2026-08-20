import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  static const String _keyToken = 'auth_jwt_token';
  static const String _keyStudentId = 'auth_student_id';
  static const String _keyCollegeId = 'auth_college_id';
  static const String _keyEmail = 'auth_email';
  static const String _keyFullName = 'auth_full_name';
  static const String _keyVerificationStatus = 'auth_verification_status';

  static Future<void> saveAuthSession({
    required String token,
    required String studentId,
    required String collegeId,
    required String email,
    required String fullName,
    required String verificationStatus,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyStudentId, studentId);
    await prefs.setString(_keyCollegeId, collegeId);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyFullName, fullName);
    await prefs.setString(_keyVerificationStatus, verificationStatus);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<String?> getStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStudentId);
  }

  static Future<String?> getCollegeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCollegeId);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFullName);
  }

  static Future<String?> getVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVerificationStatus);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyStudentId);
    await prefs.remove(_keyCollegeId);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyFullName);
    await prefs.remove(_keyVerificationStatus);
  }
}
