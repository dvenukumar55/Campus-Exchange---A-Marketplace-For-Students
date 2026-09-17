import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/student.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> getColleges() async {
    final response = await _apiClient.get('/auth/colleges');
    final collegesData = response['colleges'] as List;

    return collegesData.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Step 1: Request 6-digit OTP to institutional email address.
  Future<Map<String, dynamic>> requestOtp(String email) async {
    final response = await _apiClient.post(
      ApiConstants.requestOtp,
      body: {
        'officialEmail': email.trim().toLowerCase(),
      },
      requiresAuth: false,
    );

    return response as Map<String, dynamic>;
  }

  /// Step 2: Verify 6-digit OTP and store short-lived verification token.
  Future<String> verifyOtp(String email, String otp) async {
    final response = await _apiClient.post(
      ApiConstants.verifyOtp,
      body: {
        'officialEmail': email.trim().toLowerCase(),
        'otp': otp.trim(),
      },
      requiresAuth: false,
    );

    final verificationToken = response['verificationToken'] as String;
    await SecureStorage.saveVerificationToken(verificationToken);
    return verificationToken;
  }

  /// Step 3: Submit roll number along with verified OTP token and device ID.
  Future<Student> completeRegistration({
    required String email,
    required String rollNumber,
  }) async {
    final verificationToken = await SecureStorage.getVerificationToken();
    final deviceId = await SecureStorage.getDeviceId();

    final response = await _apiClient.post(
      ApiConstants.completeRegistration,
      body: {
        'officialEmail': email.trim().toLowerCase(),
        'rollNumber': rollNumber.trim().toUpperCase(),
        'verificationToken': verificationToken ?? '',
        'deviceId': deviceId,
      },
      requiresAuth: false,
    );

    final token = response['token'] as String;
    final sessionId = response['sessionId'] as String?;
    final studentData = response['student'] as Map<String, dynamic>;
    final student = Student.fromJson(studentData);

    await SecureStorage.saveAuthSession(
      token: token,
      studentId: student.studentId,
      collegeId: student.collegeId,
      email: student.officialEmail,
      fullName: student.fullName,
      verificationStatus: student.verificationStatus,
      sessionId: sessionId,
    );

    // Clean up temporary verification token
    await SecureStorage.clearVerificationToken();

    return student;
  }

  /// Legacy compatibility method
  Future<Student> authenticate({
    required String email,
    required String rollNumber,
  }) async {
    return completeRegistration(email: email, rollNumber: rollNumber);
  }


  Future<Student?> getCurrentStudent() async {
    final token = await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await _apiClient.get(
        ApiConstants.getProfile,
      );

      final studentData = response['student'] as Map<String, dynamic>;

      return Student.fromJson(studentData);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (_) {}

    await SecureStorage.clearSession();
  }
}
