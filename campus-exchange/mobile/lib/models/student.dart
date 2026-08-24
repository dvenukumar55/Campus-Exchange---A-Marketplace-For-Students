class Student {
  final String studentId;
  final String collegeId;
  final String collegeName;
  final String officialEmail;
  final String fullName;
  final String department;
  final String verificationStatus;
  final String accountStatus;
  final String role;
  final DateTime? verifiedAt;

  Student({
    required this.studentId,
    required this.collegeId,
    required this.collegeName,
    required this.officialEmail,
    required this.fullName,
    required this.department,
    required this.verificationStatus,
    required this.accountStatus,
    required this.role,
    this.verifiedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] ?? '',
      collegeId: json['collegeId'] ?? '',
      collegeName: json['collegeName'] ??
          'Avanthi Institute of Engineering and Technology',
      officialEmail: json['officialEmail'] ?? '',
      fullName: json['fullName'] ?? 'Verified Student',
      department: json['department'] ?? 'Engineering',
      verificationStatus: json['verificationStatus'] ?? 'pending',
      accountStatus: json['accountStatus'] ?? 'active',
      role: json['role'] ?? 'student',
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'collegeId': collegeId,
      'collegeName': collegeName,
      'officialEmail': officialEmail,
      'fullName': fullName,
      'department': department,
      'verificationStatus': verificationStatus,
      'accountStatus': accountStatus,
      'role': role,
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }

  bool get isVerified => verificationStatus == 'verified';

  bool get isAdmin => role == 'admin';

  bool get isModerator => role == 'moderator';

  bool get canAccessAdminPanel => isAdmin || isModerator;
}