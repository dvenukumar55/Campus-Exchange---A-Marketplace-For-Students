class Student {
  final String studentId;
  final String collegeId;
  final String collegeName;
  final String officialEmail;
  final String fullName;
  final String department;
  final String verificationStatus;
  final String accountStatus;
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
    this.verifiedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] ?? '',
      collegeId: json['collegeId'] ?? '',
      collegeName: json['collegeName'] ?? 'Avanthi Institute of Engineering and Technology',
      officialEmail: json['officialEmail'] ?? '',
      fullName: json['fullName'] ?? 'Verified Student',
      department: json['department'] ?? 'Engineering',
      verificationStatus: json['verificationStatus'] ?? 'pending',
      accountStatus: json['accountStatus'] ?? 'active',
      verifiedAt: json['verifiedAt'] != null ? DateTime.tryParse(json['verifiedAt']) : null,
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
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }

  bool get isVerified => verificationStatus == 'verified';
}
