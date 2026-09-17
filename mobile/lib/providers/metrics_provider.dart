import 'package:flutter/material.dart';
import '../models/pilot_metrics.dart';
import '../services/metrics_service.dart';

class MetricsProvider with ChangeNotifier {
  final MetricsService _metricsService = MetricsService();

  PilotMetrics? _metrics;
  bool _isLoading = false;
  String? _errorMessage;

  PilotMetrics? get metrics => _metrics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMetrics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _metrics = await _metricsService.getMetrics();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
