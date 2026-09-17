import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/display_utils.dart';
import '../models/listing.dart';
import '../models/report.dart';
import '../providers/auth_provider.dart';
import '../providers/listing_provider.dart';
import '../services/admin_service.dart';
import '../services/report_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final AdminService _adminService = AdminService();
  final ReportService _reportService = ReportService();

  AdminDashboardData? _dashboardData;
  List<Map<String, dynamic>> _students = [];
  List<Report> _reports = [];
  List<Map<String, dynamic>> _auditLogs = [];
  bool _isLoading = true;

  bool _maintenanceMode = false;
  double _maxPriceLimit = 50000;
  int _autoFlagThreshold = 3;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 6,
      vsync: this,
    );

    _loadAllAdminData();
  }

  Future<void> _loadAllAdminData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _adminService.getDashboard(),
        _adminService.getStudents(),
        _adminService.getReports(),
        _adminService.getAuditLogs(),
      ]);

      if (!mounted) return;

      setState(() {
        _dashboardData = results[0] as AdminDashboardData;
        _students = results[1] as List<Map<String, dynamic>>;
        _reports = results[2] as List<Report>;
        _auditLogs = results[3] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading admin dashboard data: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _warnStudent(String studentId, String studentName) async {
    try {
      await _reportService.issueWarning(studentId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Issued official warning to $studentName'),
          backgroundColor: const Color(0xFFFBBF24),
        ),
      );
      _loadAllAdminData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to warn student: $e'),
          backgroundColor: const Color(0xFFE11D48),
        ),
      );
    }
  }

  Future<void> _blockStudent(String studentId, String studentName) async {
    try {
      await _reportService.blockStudent(studentId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Suspended account for $studentName'),
          backgroundColor: const Color(0xFFE11D48),
        ),
      );
      _loadAllAdminData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to block student: $e'),
          backgroundColor: const Color(0xFFE11D48),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final listingProvider = Provider.of<ListingProvider>(context);
    final student = authProvider.currentStudent;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1128),
      appBar: _buildAppBar(student),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(listingProvider),
              _buildUsersTab(),
              _buildListingsTab(listingProvider),
              _buildReportsTab(),
              _buildAuditLogsTab(),
              _buildSettingsTab(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(dynamic student) {
    return AppBar(
      backgroundColor: const Color(0xFF0B1128),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 16,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Admin Command Center',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Campus governance & monitoring',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF17224D),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            ),
          ),
          child: IconButton(
            tooltip: 'Refresh Admin Data',
            onPressed: _isLoading ? null : _loadAllAdminData,
            icon: Icon(
              Icons.refresh_rounded,
              size: 19,
              color: _isLoading
                  ? const Color(0xFF64748B)
                  : const Color(0xFF60A5FA),
            ),
          ),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: const Color(0xFF60A5FA),
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF94A3B8),
        labelStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          const Tab(text: 'Overview'),
          Tab(
            text: _students.isNotEmpty
                ? 'Users (${_students.length})'
                : 'Users',
          ),
          const Tab(text: 'Listings'),
          Tab(
            text: _reports.isNotEmpty
                ? 'Reports (${_reports.length})'
                : 'Reports',
          ),
          const Tab(text: 'Audit Logs'),
          const Tab(text: 'Settings'),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OVERVIEW
  // ---------------------------------------------------------------------------

  Widget _buildOverviewTab(ListingProvider listingProvider) {
    final verifiedStudents = _dashboardData?.verifiedStudents ?? 0;
    final totalStudents = _dashboardData?.totalStudents ?? 0;
    final activeListings = _dashboardData?.activeListings ?? 0;
    final totalListings = _dashboardData?.totalListings ?? 0;
    final soldListings = _dashboardData?.soldListings ?? 0;
    final pendingReports = _dashboardData?.pendingReports ?? 0;
    final totalVolume = _dashboardData?.marketVolume ?? 0.0;
    final campuses = _dashboardData?.campuses ?? [];
    final recentEvents = _dashboardData?.recentEvents ?? [];

    return RefreshIndicator(
      onRefresh: _loadAllAdminData,
      color: const Color(0xFF60A5FA),
      backgroundColor: const Color(0xFF111936),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(),
            const SizedBox(height: 18),
            _buildSectionHeader(
              'Marketplace Overview',
              'Real-time campus activity',
              Icons.analytics_rounded,
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 11,
              mainAxisSpacing: 11,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.22,
              children: [
                _buildKpiCard(
                  title: 'Verified Students',
                  value: '$verifiedStudents',
                  subtitle: '$totalStudents total accounts',
                  icon: Icons.verified_rounded,
                  color: const Color(0xFF60A5FA),
                ),
                _buildKpiCard(
                  title: 'Active Listings',
                  value: '$activeListings',
                  subtitle: '$totalListings total items',
                  icon: Icons.storefront_rounded,
                  color: const Color(0xFF2DD4BF),
                ),
                _buildKpiCard(
                  title: 'Pending Reports',
                  value: '$pendingReports',
                  subtitle: pendingReports == 0 ? 'Queue clean' : 'Needs attention',
                  icon: Icons.report_problem_rounded,
                  color: const Color(0xFFFB7185),
                ),
                _buildKpiCard(
                  title: 'Market Volume',
                  value: '₹${totalVolume.toStringAsFixed(0)}',
                  subtitle: '$soldListings completed sales',
                  icon: Icons.currency_rupee_rounded,
                  color: const Color(0xFFFBBF24),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionHeader(
              'Campus Activity',
              'Dynamic listing distribution',
              Icons.account_balance_rounded,
            ),
            const SizedBox(height: 10),
            _buildCampusActivitySection(campuses, totalListings),
            const SizedBox(height: 20),
            _buildSectionHeader(
              'Recent Activity',
              'Latest administrative actions',
              Icons.bolt_rounded,
            ),
            const SizedBox(height: 10),
            _buildRecentActivitySection(recentEvents),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusActivitySection(
    List<CampusStat> campuses,
    int totalListings,
  ) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF2DD4BF),
      const Color(0xFF38BDF8),
      const Color(0xFFFBBF24),
    ];

    return _buildDarkCard(
      child: campuses.isEmpty
          ? const Text(
              'No campus listing activity recorded yet in the database.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...campuses.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final campus = entry.value;
                  final color = colors[idx % colors.length];
                  final ratio = totalListings > 0
                      ? (campus.listingCount / totalListings).clamp(0.0, 1.0)
                      : (campus.listingCount > 0 ? 1.0 : 0.0);

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: idx == campuses.length - 1 ? 0 : 18,
                    ),
                    child: _buildPartitionRow(
                      campus.name,
                      ratio,
                      '${campus.listingCount} items',
                      color,
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildRecentActivitySection(List<Map<String, dynamic>> events) {
    if (events.isEmpty) {
      return _buildDarkCard(
        child: const Text(
          'No recent administrative activity recorded in database.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
          ),
        ),
      );
    }

    return _buildDarkCard(
      child: Column(
        children: [
          ...events.take(5).toList().asMap().entries.map(
                (entry) => _buildRecentAuditItem(
                  entry.value,
                  isLast: entry.key ==
                      (events.length > 5 ? 4 : events.length - 1),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111936),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Live Campus Telemetry',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    _StatusIndicator(),
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  '100% verified student activity with strict college isolation.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF17224D),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF60A5FA),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111936),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 19,
                ),
              ),
              Icon(
                Icons.trending_up_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFCBD5E1),
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDarkCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111936),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPartitionRow(
    String campus,
    double progress,
    String count,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                campus,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFF0B1228),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAuditItem(
    Map<String, dynamic> log, {
    required bool isLast,
  }) {
    final action = log['eventType']?.toString() ??
        log['action']?.toString() ??
        'EVENT';
    final target = log['target']?.toString() ??
        log['listingId']?.toString() ??
        log['studentId']?.toString() ??
        log['collegeId']?.toString() ??
        'Campus';
    final details =
        log['details']?.toString() ?? _getEventDescription(action, log);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF60A5FA),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 42,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$action • $target',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  details,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    height: 1.35,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getEventDescription(String action, Map<String, dynamic> log) {
    final meta = log['metadata'] is Map<String, dynamic>
        ? log['metadata'] as Map<String, dynamic>
        : (log['metadata'] is Map
            ? Map<String, dynamic>.from(log['metadata'] as Map)
            : <String, dynamic>{});
    final studentId = log['studentId']?.toString();
    final listingId = log['listingId']?.toString();

    switch (action) {
      case 'STUDENT_LOGIN':
        return studentId != null && studentId.isNotEmpty
            ? 'Student $studentId authenticated successfully.'
            : 'Student authenticated successfully.';
      case 'STUDENT_LOGOUT':
        return studentId != null && studentId.isNotEmpty
            ? 'Student $studentId signed out securely.'
            : 'Student signed out securely.';
      case 'STUDENT_SIGNUP_VERIFIED':
        final domain = meta['emailDomain']?.toString() ?? '';
        return domain.isNotEmpty
            ? 'New student registered and verified with @$domain.'
            : 'New student verified institutional identity.';
      case 'LISTING_CREATED':
        final category = meta['category']?.toString();
        final price = meta['price'];
        if (category != null && price != null) {
          return 'New listing published in $category for ₹$price.';
        }
        return 'New marketplace listing published.';
      case 'LISTING_UPDATED':
        return listingId != null
            ? 'Listing $listingId details updated.'
            : 'Listing details updated.';
      case 'LISTING_CLOSED_SOLD':
        final price = meta['price'];
        return price != null
            ? 'Listing marked SOLD for ₹$price.'
            : 'Listing marked as sold.';
      case 'LISTING_CLOSED_CANCELLED':
        return 'Listing closed or withdrawn from marketplace.';
      case 'CHAT_CONVERSATION_INITIATED':
        return 'Peer student started new chat conversation.';
      case 'CHAT_MESSAGE_SENT':
        return 'Direct buyer-seller chat message sent.';
      case 'REPORT_SUBMITTED':
        final reason = meta['reason']?.toString();
        return reason != null && reason.isNotEmpty
            ? 'Incident report submitted: $reason.'
            : 'Incident report submitted for moderation.';
      case 'REPORT_RESOLVED':
        final actionTaken = meta['actionTaken']?.toString();
        return actionTaken != null && actionTaken.isNotEmpty
            ? 'Report reviewed and resolved: $actionTaken.'
            : 'Moderation report marked resolved.';
      case 'USER_WARNED':
        final reviewer = meta['reviewerId']?.toString();
        return reviewer != null
            ? 'Official moderation warning issued by $reviewer.'
            : 'Official moderation warning issued to student.';
      case 'USER_BLOCKED':
        return 'Student account suspended due to policy violations.';
      default:
        return 'System administrative telemetry logged.';
    }
  }

  // ---------------------------------------------------------------------------
  // USERS
  // ---------------------------------------------------------------------------

  Widget _buildUsersTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF60A5FA),
          strokeWidth: 2.5,
        ),
      );
    }

    if (_students.isEmpty) {
      return _buildEmptyAdminState(
        icon: Icons.people_outline_rounded,
        title: 'No Registered Students',
        message:
            'No student accounts currently exist in the database for this campus.',
        success: true,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllAdminData,
      color: const Color(0xFF60A5FA),
      backgroundColor: const Color(0xFF111936),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 25),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final st = _students[index];
          final name = st['fullName']?.toString() ??
              st['name']?.toString() ??
              'Student Member';
          final email = st['officialEmail']?.toString() ??
              st['email']?.toString() ??
              '';
          final dept = st['department']?.toString() ?? 'General Engineering';
          final role =
              (st['role']?.toString().toUpperCase() ?? 'STUDENT');
          final isStaff = role != 'STUDENT';
          final accountStatus =
              (st['accountStatus']?.toString().toUpperCase() ?? 'ACTIVE');
          final warningCount = (st['warningCount'] as num?)?.toInt() ?? 0;
          final trust = (100 - (warningCount * 10)).clamp(0, 100);
          final studentId = st['studentId']?.toString() ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF111936),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: isStaff
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF6366F1),
                                  Color(0xFF8B5CF6),
                                ],
                              )
                            : const LinearGradient(
                                colors: [
                                  Color(0xFF38BDF8),
                                  Color(0xFF60A5FA),
                                ],
                              ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty
                              ? name.substring(0, 1).toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            formatDisplayEmail(email),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusPill(
                      accountStatus,
                      accountStatus == 'ACTIVE'
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFFB7185),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1228),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSmallInfo(
                          'ROLE',
                          role,
                          isStaff
                              ? const Color(0xFFA78BFA)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      Expanded(
                        child: _buildSmallInfo(
                          'TRUST',
                          '$trust / 100',
                          trust >= 90
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFFBBF24),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dept,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    if (!isStaff && studentId.isNotEmpty) ...[
                      InkWell(
                        onTap: () => _warnStudent(studentId, name),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFBBF24).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFFBBF24)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'Warn',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFBBF24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _blockStudent(studentId, name),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFE11D48).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFE11D48)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'Block',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFB7185),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LISTINGS
  // ---------------------------------------------------------------------------

  Widget _buildListingsTab(ListingProvider listingProvider) {
    final listings = listingProvider.listings;

    if (listings.isEmpty) {
      return _buildEmptyAdminState(
        icon: Icons.inventory_2_outlined,
        title: 'No Marketplace Listings',
        message: 'No active or closed listings found in the database.',
        success: true,
      );
    }

    return RefreshIndicator(
      onRefresh: () => listingProvider.fetchListings(),
      color: const Color(0xFF60A5FA),
      backgroundColor: const Color(0xFF111936),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 25),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final listing = listings[index];
          final isClosed =
              listing.status.toLowerCase() == 'closed' ||
              listing.status.toLowerCase() == 'sold';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF111936),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF17224D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.category_rounded,
                        color: Color(0xFF60A5FA),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Seller: ${listing.sellerName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusPill(
                      listing.status.toUpperCase(),
                      isClosed
                          ? const Color(0xFF64748B)
                          : const Color(0xFF22C55E),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1228),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetaChip(
                        Icons.currency_rupee_rounded,
                        '₹${listing.price.toStringAsFixed(0)}',
                      ),
                      _buildMetaChip(
                        Icons.check_circle_outline_rounded,
                        listing.condition,
                      ),
                      _buildMetaChip(
                        Icons.remove_red_eye_outlined,
                        '${listing.viewCount} views',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isClosed)
                      TextButton.icon(
                        onPressed: () => _showSoftDeleteDialog(listing),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: Color(0xFFFB7185),
                        ),
                        label: const Text(
                          'Soft Delete',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFB7185),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFCBD5E1),
            ),
          ),
        ),
      ],
    );
  }

  void _showSoftDeleteDialog(Listing listing) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111936),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFFB7185),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Soft-Delete Listing',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Take down "${listing.title}" from the marketplace?',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFFCBD5E1),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  labelText: 'Takedown Reason',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  hintText: 'Enter the reason for moderation...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF0B1228),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  final lp =
                      Provider.of<ListingProvider>(context, listen: false);
                  await lp.closeListing(listing.listingId, 'closed');
                  _loadAllAdminData();

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Listing "${listing.title}" soft-deleted and logged.',
                      ),
                      backgroundColor: const Color(0xFF22C55E),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete listing: $e'),
                      backgroundColor: const Color(0xFFE11D48),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // REPORTS
  // ---------------------------------------------------------------------------

  Widget _buildReportsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF60A5FA),
          strokeWidth: 2.5,
        ),
      );
    }

    if (_reports.isEmpty) {
      return _buildEmptyAdminState(
        icon: Icons.verified_rounded,
        title: 'Moderation Queue Clean',
        message:
            'There are no pending student incident reports at this moment.',
        success: true,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllAdminData,
      color: const Color(0xFF60A5FA),
      backgroundColor: const Color(0xFF111936),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 25),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          final isPending = report.status.toLowerCase() == 'pending' ||
              report.status.toLowerCase() == 'open';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF111936),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isPending
                    ? const Color(0xFFFB7185).withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPending
                            ? const Color(0xFFFB7185).withValues(alpha: 0.18)
                            : const Color(0xFF22C55E).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isPending
                            ? Icons.report_problem_rounded
                            : Icons.check_circle_rounded,
                        color: isPending
                            ? const Color(0xFFFB7185)
                            : const Color(0xFF22C55E),
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.reason,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Listing: ${report.listingId}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusPill(
                      report.status.toUpperCase(),
                      isPending
                          ? const Color(0xFFFB7185)
                          : const Color(0xFF22C55E),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1228),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Text(
                    report.description,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.4,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ),
                if (isPending) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await _reportService.reviewReport(
                            reportId: report.reportId,
                            status: 'resolved',
                            actionTaken: 'seller_warned',
                            reviewNotes: 'Resolved by Admin review',
                          );
                          _loadAllAdminData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Resolve Report',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AUDIT LOGS
  // ---------------------------------------------------------------------------

  Widget _buildAuditLogsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF60A5FA),
          strokeWidth: 2.5,
        ),
      );
    }

    if (_auditLogs.isEmpty) {
      return _buildEmptyAdminState(
        icon: Icons.history_edu_rounded,
        title: 'No Audit Records',
        message: 'No audit activity yet.',
        success: true,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllAdminData,
      color: const Color(0xFF60A5FA),
      backgroundColor: const Color(0xFF111936),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 25),
        itemCount: _auditLogs.length,
        itemBuilder: (context, index) {
          final log = _auditLogs[index];
          final action = log['eventType']?.toString() ??
              log['action']?.toString() ??
              'SYSTEM_EVENT';
          final target = log['target']?.toString() ??
              log['listingId']?.toString() ??
              log['reportId']?.toString() ??
              log['studentId']?.toString() ??
              'Campus';
          final actor =
              log['actor']?.toString() ?? log['studentId']?.toString() ?? 'System';
          final details =
              log['details']?.toString() ?? _getEventDescription(action, log);
          final rawTime =
              log['occurredAt'] ?? log['createdAt'] ?? log['timestamp'];
          final parsedTime =
              rawTime != null ? DateTime.tryParse(rawTime.toString()) : null;
          final timeDisplay = parsedTime != null
              ? DateFormat('dd MMM, HH:mm').format(parsedTime)
              : 'Unknown time';

          return Container(
            margin: const EdgeInsets.only(bottom: 11),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF111936),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF17224D),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    _getAuditIcon(action),
                    color: const Color(0xFF60A5FA),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF17224D),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                action,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF818CF8),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeDisplay,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        details,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Actor: $actor',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Target: $target',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getAuditIcon(String action) {
    if (action.contains('DELETE') || action.contains('BLOCKED')) {
      return Icons.delete_outline_rounded;
    }

    if (action.contains('WARN')) {
      return Icons.warning_amber_rounded;
    }

    if (action.contains('REPORT')) {
      return Icons.flag_outlined;
    }

    if (action.contains('LOGIN') || action.contains('SIGNUP')) {
      return Icons.verified_user_rounded;
    }

    return Icons.security_rounded;
  }

  // ---------------------------------------------------------------------------
  // SETTINGS
  // ---------------------------------------------------------------------------

  Widget _buildSettingsTab() {
    final collegeName = _dashboardData?.collegeName.isNotEmpty == true
        ? _dashboardData!.collegeName
        : (_dashboardData?.campuses.isNotEmpty == true
            ? _dashboardData!.campuses.first.name
            : 'Campus Marketplace');
    final domain = _dashboardData?.verificationDomain.isNotEmpty == true
        ? '@${_dashboardData!.verificationDomain}'
        : '@edu.in';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Security & Governance',
            'Control campus marketplace policies',
            Icons.security_rounded,
          ),
          const SizedBox(height: 11),
          _buildDarkCard(
            child: Column(
              children: [
                _buildMaintenanceTile(),
                Divider(
                  height: 25,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                _buildPriceLimitControl(),
                Divider(
                  height: 25,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                _buildAutoFlagControl(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(
            'Email Security',
            'Verified email domains',
            Icons.mark_email_read_rounded,
          ),
          const SizedBox(height: 11),
          _buildDarkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDomainRow(
                  domain,
                  collegeName,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1B4B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.35),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.policy_rounded,
                  color: Color(0xFF818CF8),
                  size: 20,
                ),
                SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Closed-Network Enforcement Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Strict cryptographic college isolation is enforced at the database and network layer. All cross-campus marketplace queries are rejected.',
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 10.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maintenance Mode',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Temporarily disable student transactions',
              style: TextStyle(
                fontSize: 10.5,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        Switch(
          value: _maintenanceMode,
          activeThumbColor: const Color(0xFF60A5FA),
          activeTrackColor: const Color(0xFF2563EB),
          inactiveThumbColor: const Color(0xFF64748B),
          inactiveTrackColor: const Color(0xFF0B1228),
          onChanged: (val) {
            setState(() => _maintenanceMode = val);
          },
        ),
      ],
    );
  }

  Widget _buildPriceLimitControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maximum Price Ceiling',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Prevent unrealistic or commercial listings',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF17224D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '₹${_maxPriceLimit.toInt()}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF60A5FA),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF6366F1),
            inactiveTrackColor: const Color(0xFF0B1228),
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: _maxPriceLimit,
            min: 5000,
            max: 100000,
            divisions: 19,
            onChanged: (val) {
              setState(() => _maxPriceLimit = val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAutoFlagControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auto-Moderation Threshold',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Reports before auto-hide triggers',
              style: TextStyle(
                fontSize: 10.5,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildIncDecButton(
              Icons.remove_rounded,
              () {
                if (_autoFlagThreshold > 1) {
                  setState(() => _autoFlagThreshold--);
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '$_autoFlagThreshold',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            _buildIncDecButton(
              Icons.add_rounded,
              () {
                if (_autoFlagThreshold < 10) {
                  setState(() => _autoFlagThreshold++);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncDecButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF17224D),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 15,
          color: const Color(0xFF60A5FA),
        ),
      ),
    );
  }

  Widget _buildDomainRow(String domain, String campus) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: const Color(0xFF22C55E).withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            domain,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF86EFAC),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            campus,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const Icon(
          Icons.lock_outline_rounded,
          size: 14,
          color: Color(0xFF64748B),
        ),
      ],
    );
  }

  Widget _buildSmallInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildEmptyAdminState({
    required IconData icon,
    required String title,
    required String message,
    required bool success,
  }) {
    final color =
        success ? const Color(0xFF22C55E) : const Color(0xFF60A5FA);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 42,
                color: color,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF22C55E).withValues(alpha: 0.35),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 5,
            color: Color(0xFF22C55E),
          ),
          SizedBox(width: 4),
          Text(
            'ONLINE',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF86EFAC),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
