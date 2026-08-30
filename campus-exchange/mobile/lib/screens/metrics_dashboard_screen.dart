import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/pilot_metrics.dart';
import '../providers/metrics_provider.dart';
import '../widgets/error_state_view.dart';

class MetricsDashboardScreen extends StatefulWidget {
  const MetricsDashboardScreen({super.key});

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
        title: const Text('Pilot Acceptance Metrics', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Metrics',
            onPressed: () => metricsProvider.fetchMetrics(),
          ),
          const SizedBox(width: 6),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppTheme.dividerColor),
        ),
      ),
      body: metricsProvider.isLoading && metricsProvider.metrics == null
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
          : metricsProvider.errorMessage != null && metricsProvider.metrics == null
              ? ErrorStateView(
                  message: metricsProvider.errorMessage!,
                  onRetry: () => metricsProvider.fetchMetrics(),
                )
              : RefreshIndicator(
                  onRefresh: () => metricsProvider.fetchMetrics(),
                  color: AppTheme.royalBlue,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pilot Target Hero Card
                        _buildPilotTargetSummary(metricsProvider.metrics!),
                        const SizedBox(height: 20),

                        const Text(
                          'Marketplace Performance Indicators',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Metric Stat Cards Grid
                        _buildStatsGrid(metricsProvider.metrics!),
                        const SizedBox(height: 20),

                        // SLA & Technical NFR Monitoring Card
                        _buildSlaCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPilotTargetSummary(PilotMetrics m) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2744), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pilot Acceptance Criteria',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              Icon(Icons.verified_rounded, color: Color(0xFF38BDF8), size: 22),
            ],
          ),
          const SizedBox(height: 16),
          _buildTargetRow('Verified Sign-ups (≥ 100)', '${m.verifiedSignups} / 100', m.verifiedSignupsMet),
          const Divider(color: Color(0xFF334155), height: 16),
          _buildTargetRow('Active Listings (≥ 50)', '${m.activeListings} / 50', m.activeListingsMet),
          const Divider(color: Color(0xFF334155), height: 16),
          _buildTargetRow('Listing-to-Chat (≥ 50%)', m.listingToChatConversionRate, m.listingToChatMet),
          const Divider(color: Color(0xFF334155), height: 16),
          _buildTargetRow('Listing-to-Sale (≥ 30%)', m.listingToSaleConversionRate, m.listingToSaleMet),
        ],
      ),
    );
  }

  Widget _buildTargetRow(String label, String value, bool isMet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isMet ? AppTheme.successColor.withValues(alpha: 0.25) : AppTheme.warningColor.withValues(alpha: 0.25),
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
    );
  }

  Widget _buildStatsGrid(PilotMetrics m) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: [
        _buildMetricBox('Total Listings', m.totalListings.toString(), Icons.inventory_2_outlined, AppTheme.royalBlue),
        _buildMetricBox('Active Listings', m.activeListings.toString(), Icons.storefront_outlined, AppTheme.successColor),
        _buildMetricBox('Completed Sales', m.soldListings.toString(), Icons.check_circle_outline_rounded, AppTheme.cyanAccent),
        _buildMetricBox('Listings with Chat', m.listingsWithChat.toString(), Icons.forum_outlined, AppTheme.warningColor),
      ],
    );
  }

  Widget _buildMetricBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w700),
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operational & NFR Benchmarks',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 10),
          Text('• Action Response Time: ≤ 3.0s (via X-Request-Id audit)',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
          SizedBox(height: 4),
          Text('• Pilot Availability SLA: 99.0% (via /api/v1/health)',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
          SizedBox(height: 4),
          Text('• College Isolation Boundary: Server-Side Enforced',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
        ],
      ),
    );
  }
}
