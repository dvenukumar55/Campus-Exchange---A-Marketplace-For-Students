import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/pilot_metrics.dart';
import '../providers/metrics_provider.dart';
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Pilot Metrics', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
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
                  color: AppTheme.primaryColor,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pilot Target Card
                        _buildPilotTargetSummary(metricsProvider.metrics!),
                        const SizedBox(height: 32),

                        const Text(
                          'Conversion Funnel & Performance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Metric Stat Cards Grid
                        _buildStatsGrid(metricsProvider.metrics!),
                        const SizedBox(height: 32),

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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryVariant, AppTheme.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
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
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.flag_rounded, color: AppTheme.warningColor, size: 24),
            ],
          ),
          const SizedBox(height: 20),
          _buildTargetRow('Verified Sign-ups (≥ 100)', '${m.verifiedSignups} / 100', m.verifiedSignupsMet),
          _buildTargetRow('Active Listings (≥ 50)', '${m.activeListings} / 50', m.activeListingsMet),
          _buildTargetRow('Listing-to-Chat (≥ 50%)', m.listingToChatConversionRate, m.listingToChatMet),
          _buildTargetRow('Listing-to-Sale (≥ 30%)', m.listingToSaleConversionRate, m.listingToSaleMet),
        ],
      ),
    );
  }

  Widget _buildTargetRow(String label, String value, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isMet ? AppTheme.successColor.withOpacity(0.2) : AppTheme.warningColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isMet ? Icons.check_circle_rounded : Icons.pending_rounded,
                  color: isMet ? AppTheme.successColor : AppTheme.warningColor,
                  size: 16,
                ),
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
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildMetricBox('Total Listings', m.totalListings.toString(), Icons.inventory_2_rounded, AppTheme.blueAccent),
        _buildMetricBox('Active Listings', m.activeListings.toString(), Icons.storefront_rounded, AppTheme.successColor),
        _buildMetricBox('Completed Sales', m.soldListings.toString(), Icons.verified_rounded, AppTheme.violetAccent),
        _buildMetricBox('Listings with Chat', m.listingsWithChat.toString(), Icons.forum_rounded, AppTheme.warningColor),
      ],
    );
  }

  Widget _buildMetricBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600))),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSlaCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Operational & NFR Targets',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 12),
          Text('• Action Response Time: ≤ 3.0s (via X-Request-Id)', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
          SizedBox(height: 6),
          Text('• Pilot Availability SLA: 99.0% (via /api/v1/health)', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
          SizedBox(height: 6),
          Text('• College Data Separation: Server-Side Enforced', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}
