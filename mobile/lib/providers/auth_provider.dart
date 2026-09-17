import 'package:flutter/material.dart';
import '../core/error/app_exception.dart';
import '../models/student.dart';
import '../services/auth_service.dart';

enum AuthFlowStep { email, otp, rollNumber }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  Student? _currentStudent;
  bool _isLoading = false;
  String? _errorMessage;
  String? _conflictMessage;

  AuthFlowStep _currentStep = AuthFlowStep.email;
  String _pendingEmail = '';
  bool _isOtpSent = false;
  bool _isOtpVerified = false;

  Student? get currentStudent => _currentStudent;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentStudent != null;
  bool get isVerified => _currentStudent?.isVerified ?? false;
  String? get errorMessage => _errorMessage;
  String? get conflictMessage => _conflictMessage;

  AuthFlowStep get currentStep => _currentStep;
  String get pendingEmail => _pendingEmail;
  bool get isOtpSent => _isOtpSent;
  bool get isOtpVerified => _isOtpVerified;

  void clearError() {
    _errorMessage = null;
    _conflictMessage = null;
    notifyListeners();
  }

  void resetFlow() {
    _currentStep = AuthFlowStep.email;
    _pendingEmail = '';
    _isOtpSent = false;
    _isOtpVerified = false;
    _errorMessage = null;
    _conflictMessage = null;
    notifyListeners();
  }

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

  Future<List<Map<String, dynamic>>> getColleges() async {
    try {
      return await _authService.getColleges();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Step 1: Send OTP to official email
  Future<bool> requestOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _conflictMessage = null;
    _pendingEmail = email.trim().toLowerCase();
    notifyListeners();

    try {
      await _authService.requestOtp(_pendingEmail);
      _isOtpSent = true;
      _currentStep = AuthFlowStep.otp;
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

  /// Step 2: Verify 6-digit OTP
  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    _conflictMessage = null;
    notifyListeners();

    try {
      await _authService.verifyOtp(_pendingEmail, otp);
      _isOtpVerified = true;
      _currentStep = AuthFlowStep.rollNumber;
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

  /// Step 3: Complete authentication with verified email + roll number
  Future<bool> completeAuthentication({
    required String rollNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _conflictMessage = null;
    notifyListeners();

    try {
      _currentStudent = await _authService.completeRegistration(
        email: _pendingEmail,
        rollNumber: rollNumber,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on ConflictException catch (e) {
      _conflictMessage = e.message;
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Legacy authentication method fallback
  Future<bool> authenticate({
    required String email,
    required String rollNumber,
  }) async {
    _pendingEmail = email;
    return completeAuthentication(rollNumber: rollNumber);
  }


  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();

    _currentStudent = null;
    resetFlow();
    _isLoading = false;
    notifyListeners();
  }
}
