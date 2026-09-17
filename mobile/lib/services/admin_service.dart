import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/listing.dart';
import '../models/report.dart';

class CampusStat {
  final String collegeId;
  final String name;
  final int listingCount;
  final int activeCount;

  CampusStat({
    required this.collegeId,
    required this.name,
    required this.listingCount,
    required this.activeCount,
  });

  factory CampusStat.fromJson(Map<String, dynamic> json) {
    return CampusStat(
      collegeId: json['collegeId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Campus',
      listingCount: (json['listingCount'] as num?)?.toInt() ?? 0,
      activeCount: (json['activeCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminDashboardData {
  final String collegeName;
  final String verificationDomain;

  final int totalStudents;
  final int verifiedStudents;
  final int activeStudents;
  final int suspendedStudents;

  final int activeListings;
  final int soldListings;
  final int closedListings;
  final int totalListings;

  final int pendingReports;
  final int totalReports;

  final double marketVolume;
  final List<CampusStat> campuses;
  final List<Map<String, dynamic>> recentEvents;

  AdminDashboardData({
    this.collegeName = 'Campus',
    this.verificationDomain = 'edu.in',
    required this.totalStudents,
    required this.verifiedStudents,
    required this.activeStudents,
    required this.suspendedStudents,
    required this.activeListings,
    required this.soldListings,
    required this.closedListings,
    required this.totalListings,
    required this.pendingReports,
    required this.totalReports,
    required this.marketVolume,
    required this.campuses,
    required this.recentEvents,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    final college = json['college'] as Map<String, dynamic>? ?? {};
    final students = json['students'] as Map<String, dynamic>? ?? {};
    final listings = json['listings'] as Map<String, dynamic>? ?? {};
    final reports = json['reports'] as Map<String, dynamic>? ?? {};
    final market = json['market'] as Map<String, dynamic>? ?? {};
    final rawCampuses = json['campuses'] as List? ?? [];
    final rawEvents = json['recentEvents'] as List? ?? [];

    return AdminDashboardData(
      collegeName: college['name']?.toString() ?? 'Campus',
      verificationDomain: college['verificationDomain']?.toString() ?? 'edu.in',
      totalStudents: (students['total'] as num?)?.toInt() ?? 0,
      verifiedStudents: (students['verified'] as num?)?.toInt() ?? 0,
      activeStudents: (students['active'] as num?)?.toInt() ?? 0,
      suspendedStudents: (students['suspended'] as num?)?.toInt() ?? 0,
      activeListings: (listings['active'] as num?)?.toInt() ?? 0,
      soldListings: (listings['sold'] as num?)?.toInt() ?? 0,
      closedListings: (listings['closed'] as num?)?.toInt() ?? 0,
      totalListings: (listings['total'] as num?)?.toInt() ?? 0,
      pendingReports: (reports['pending'] as num?)?.toInt() ?? 0,
      totalReports: (reports['total'] as num?)?.toInt() ?? 0,
      marketVolume: (market['volume'] as num?)?.toDouble() ?? 0.0,
      campuses: rawCampuses
          .map((c) => CampusStat.fromJson(c as Map<String, dynamic>))
          .toList(),
      recentEvents: rawEvents
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}

class AdminService {
  final ApiClient _apiClient = ApiClient();

  Future<AdminDashboardData> getDashboard() async {
    final response = await _apiClient.get('${ApiConstants.admin}/dashboard');
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return AdminDashboardData.fromJson(data);
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    final response = await _apiClient.get('${ApiConstants.admin}/students');
    final items = response['data'] as List? ?? [];
    return items.map((i) => Map<String, dynamic>.from(i as Map)).toList();
  }

  Future<List<Report>> getReports({String? status}) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;

    final response = await _apiClient.get(
      '${ApiConstants.admin}/reports',
      queryParams: query,
    );
    final items = response['data'] as List? ?? [];
    return items
        .map((json) => Report.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAuditLogs() async {
    final response = await _apiClient.get('${ApiConstants.admin}/audit-logs');
    final items = response['data'] as List? ?? [];
    return items.map((i) => Map<String, dynamic>.from(i as Map)).toList();
  }

  Future<List<Listing>> getListings() async {
    final response = await _apiClient.get('${ApiConstants.admin}/listings');
    final items = response['data'] as List? ?? [];
    return items
        .map((json) => Listing.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
