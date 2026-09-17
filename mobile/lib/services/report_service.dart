import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/report.dart';

class ReportService {
  final ApiClient _apiClient = ApiClient();

  Future<void> issueWarning(String studentId, {String? rollNumber}) async {
    await _apiClient.post(
      '${ApiConstants.admin}/students/$studentId/warn',
      body: rollNumber != null && rollNumber.isNotEmpty ? {'rollNumber': rollNumber} : null,
    );
  }

  Future<void> blockStudent(String studentId, {String? rollNumber}) async {
    await _apiClient.post(
      '${ApiConstants.admin}/students/$studentId/block',
      body: rollNumber != null && rollNumber.isNotEmpty ? {'rollNumber': rollNumber} : null,
    );
  }

  Future<Report> createReport({
    required String listingId,
    required String reason,
    required String description,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.reports,
      body: {
        'listingId': listingId,
        'reason': reason,
        'description': description,
      },
    );

    return Report.fromJson(response['report'] as Map<String, dynamic>);
  }

  Future<List<Report>> getReports({String? status}) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;

    final response = await _apiClient.get(ApiConstants.reports, queryParams: query);
    final items = response['items'] as List? ?? response['data'] as List? ?? [];
    return items.map((json) => Report.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> reviewReport({
    required String reportId,
    required String status,
    String? reviewNotes,
    String? actionTaken,
  }) async {
    await _apiClient.post(
      '${ApiConstants.reports}/$reportId/review',
      body: {
        'status': status,
        if (reviewNotes != null) 'reviewNotes': reviewNotes,
        if (actionTaken != null) 'actionTaken': actionTaken,
      },
    );
  }
}
