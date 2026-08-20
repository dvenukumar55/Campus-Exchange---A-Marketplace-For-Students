import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/pilot_metrics.dart';

class MetricsService {
  final ApiClient _apiClient = ApiClient();

  Future<PilotMetrics> getMetrics() async {
    final response = await _apiClient.get(ApiConstants.metrics);
    final metricsData = response['metrics'] as Map<String, dynamic>;
    return PilotMetrics.fromJson(metricsData);
  }
}
