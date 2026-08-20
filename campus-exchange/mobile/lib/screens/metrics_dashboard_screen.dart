import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/pilot_metrics.dart';
import '../providers/metrics_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';

class MetricsDashboardScreen extends StatefulWidget {
  const MetricsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MetricsDashboardScreen> createState() => _MetricsDashboardScreenState();
}

class _MetricsDashboardScreenState extends State<MetricsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MetricsProvider>(context, listen: false).fetchMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final metricsProvider = Provider.of<MetricsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Pilot Metrics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => metricsProvider.fetchMetrics(),
          ),
        ],
      ),
      body: metricsProvider.isLoading && metricsProvider.metrics == null
          ? const Center(child: CircularProgressIndicator())
          : metricsProvider.errorMessage != null && metricsProvider.metrics == null
              ? ErrorStateView(
                  message: metricsProvider.errorMessage!,
                  onRetry: () => metricsProvider.fetchMetrics(),
                )
              : RefreshIndicator(
                  onRefresh: () => metricsProvider.fetchMetrics(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pilot Target Card
                        _buildPilotTargetSummary(metricsProvider.metrics!),
                        const SizedBox(height: 20),

                        const Text(
                          'Conversion Funnel & Performance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Metric Stat Cards Grid
                        _buildStatsGrid(metricsProvider.metrics!),
                        const SizedBox(height: 20),

                        // SLA & Technical NFR Monitoring Card
                        _buildSlaCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPilotTargetSummary(PilotMetrics m) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Pilot Acceptance Targets',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.flag, color: AppTheme.accentColor, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          _buildTargetRow(
            'Verified Student Sign-ups (≥ 100)',
            '${m.verifiedSignups} / 100',
            m.verifiedSignupsMet,
          ),
          _buildTargetRow(
            'Active Listings / Semester (≥ 50)',
            '${m.activeListings} / 50',
            m.activeListingsMet,
          ),
          _buildTargetRow(
            'Listing-to-Chat Conversion (≥ 50%)',
            m.listingToChatConversionRate,
            m.listingToChatMet,
          ),
          _buildTargetRow(
            'Listing-to-Sale Conversion (≥ 30%)',
            m.listingToSaleConversionRate,
            m.listingToSaleMet,
          ),
        ],
      ),
    );
  }

  Widget _buildTargetRow(String label, String value, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 6),
              Icon(
                isMet ? Icons.check_circle : Icons.pending,
                color: isMet ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(PilotMetrics m) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildMetricBox('Total Listings', m.totalListings.toString(), Icons.inventory, const Color(0xFF3B82F6)),
        _buildMetricBox('Active Listings', m.activeListings.toString(), Icons.storefront, const Color(0xFF10B981)),
        _buildMetricBox('Completed Sales', m.soldListings.toString(), Icons.verified, const Color(0xFF8B5CF6)),
        _buildMetricBox('Listings with Chat', m.listingsWithChat.toString(), Icons.forum, const Color(0xFFF59E0B)),
      ],
    );
  }

  Widget _buildMetricBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              Icon(icon, size: 20, color: color),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSlaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Operational & NFR Targets',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 8),
          Text('• Normal User Action Response Time: ≤ 3.0 seconds (Tracked via X-Request-Id & Latency Logs)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
          SizedBox(height: 4),
          Text('• Pilot Availability SLA Target: 99.0% (Monitored via /api/v1/health)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
          SizedBox(height: 4),
          Text('• Logical College Data Separation: Enforced Server-Side', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
        ],
      ),
    );
  }
}
