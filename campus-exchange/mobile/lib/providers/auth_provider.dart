import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  Student? _currentStudent;
  bool _isLoading = false;
  String? _errorMessage;

  Student? get currentStudent => _currentStudent;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentStudent != null;
  bool get isVerified => _currentStudent?.isVerified ?? false;
  String? get errorMessage => _errorMessage;

  Future<bool> checkInitialAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentStudent = await _authService.getCurrentStudent();
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return _currentStudent != null;
    } catch (_) {
      _currentStudent = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOfficialEmail(String email, {String? verificationCode}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentStudent = await _authService.verifyOfficialEmail(
        officialEmail: email,
        verificationCode: verificationCode,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _currentStudent = null;
    _isLoading = false;
    notifyListeners();
  }
}
