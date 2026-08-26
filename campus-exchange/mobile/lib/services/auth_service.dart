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

  Future<Student> authenticate({
    required String email,
    required String rollNumber,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.verifyAuth,
      body: {
        'officialEmail': email.trim().toLowerCase(),
        'rollNumber': rollNumber.trim().toUpperCase(),
      },
      requiresAuth: false,
    );

    final token = response['token'] as String;
    final studentData = response['student'] as Map<String, dynamic>;
    final student = Student.fromJson(studentData);

    await SecureStorage.saveAuthSession(
      token: token,
      studentId: student.studentId,
      collegeId: student.collegeId,
      email: student.officialEmail,
      fullName: student.fullName,
      verificationStatus: student.verificationStatus,
    );

    return student;
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
