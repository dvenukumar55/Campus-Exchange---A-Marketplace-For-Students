import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/theme/app_theme.dart';
import '../models/report.dart';
import '../providers/auth_provider.dart';
import '../services/report_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ReportService _reportService = ReportService();
  final ApiClient _apiClient = ApiClient();

  List<Report> _reports = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _auditLogs = [];
  List<Map<String, dynamic>> _adminListings = [];

  bool _isLoadingDashboard = true;
  bool _isLoadingStudents = true;
  bool _isLoadingReports = false;
  bool _isLoadingAuditLogs = true;
  bool _isLoadingListings = true;

  String? _errorMessage;

  int _totalStudents = 0;
  int _verifiedStudents = 0;
  int _activeListings = 0;
  int _soldListings = 0;
  int _closedListings = 0;
  int _pendingReports = 0;
  double _marketVolume = 0;

  Map<String, dynamic>? _college;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 6,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllAdminData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // LOAD EVERYTHING
  // ---------------------------------------------------------------------------

  Future<void> _loadAllAdminData() async {
    await Future.wait([
      _loadDashboard(),
      _loadStudents(),
      _loadReports(),
      _loadAuditLogs(),
      _loadListings(),
    ]);
  }

  // ---------------------------------------------------------------------------
  // DASHBOARD
  // ---------------------------------------------------------------------------

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _isLoadingDashboard = true;
      });
    }

    try {
      final response = await _apiClient.get(
        '/admin/dashboard',
      );

      final data = response['data'] ?? {};

      if (!mounted) return;

      setState(() {
        _college = data['college'];

        final students = data['students'] ?? {};
        _totalStudents = students['total'] ?? 0;
        _verifiedStudents = students['verified'] ?? 0;

        final listings = data['listings'] ?? {};
        _activeListings = listings['active'] ?? 0;
        _soldListings = listings['sold'] ?? 0;
        _closedListings = listings['closed'] ?? 0;

        final reports = data['reports'] ?? {};
        _pendingReports = reports['pending'] ?? 0;

        final market = data['market'] ?? {};
        _marketVolume = (market['volume'] ?? 0).toDouble();

        _isLoadingDashboard = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingDashboard = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ---------------------------------------------------------------------------
  // STUDENTS
  // ---------------------------------------------------------------------------

  Future<void> _loadStudents() async {
    if (mounted) {
      setState(() {
        _isLoadingStudents = true;
      });
    }

    try {
      final response = await _apiClient.get(
        '/admin/students',
      );

      final List<dynamic> data = response['data'] ?? [];

      if (!mounted) return;

      setState(() {
        _students = data
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

        _isLoadingStudents = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingStudents = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // REPORTS
  // ---------------------------------------------------------------------------

  Future<void> _loadReports() async {
    if (mounted) {
      setState(() {
        _isLoadingReports = true;
      });
    }

    try {
      final reports = await _reportService.getReports();

      if (!mounted) return;

      setState(() {
        _reports = reports;
        _isLoadingReports = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingReports = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // AUDIT LOGS
  // ---------------------------------------------------------------------------

  Future<void> _loadAuditLogs() async {
    if (mounted) {
      setState(() {
        _isLoadingAuditLogs = true;
      });
    }

    try {
      final response = await _apiClient.get(
        '/admin/audit-logs',
      );

      final List<dynamic> data = response['data'] ?? [];

      if (!mounted) return;

      setState(() {
        _auditLogs = data
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

        _isLoadingAuditLogs = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingAuditLogs = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // LISTINGS
  // ---------------------------------------------------------------------------

  Future<void> _loadListings() async {
    if (mounted) {
      setState(() {
        _isLoadingListings = true;
      });
    }

    try {
      final response = await _apiClient.get(
        '/admin/listings',
      );

      final List<dynamic> data = response['data'] ?? [];

      if (!mounted) return;

      setState(() {
        _adminListings = data
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

        _isLoadingListings = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingListings = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final student = authProvider.currentStudent;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          tooltip: 'Back to Marketplace',
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: Row(

          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Admin Command Center',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: const Color(0xFF334155),
                          ),
                        ),
                        child: const Text(
                          'MODERATION',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF38BDF8),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${student?.fullName ?? "Administrator"} • ${student?.officialEmail ?? ""}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF94A3B8),
          indicatorColor: const Color(0xFF38BDF8),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(
              icon: Icon(
                Icons.dashboard_outlined,
                size: 18,
              ),
              text: 'Overview',
            ),
            Tab(
              icon: Icon(
                Icons.people_outline_rounded,
                size: 18,
              ),
              text: 'Students',
            ),
            Tab(
              icon: Icon(
                Icons.inventory_2_outlined,
                size: 18,
              ),
              text: 'Listings',
            ),
            Tab(
              icon: Icon(
                Icons.flag_outlined,
                size: 18,
              ),
              text: 'Reports',
            ),
            Tab(
              icon: Icon(
                Icons.history_rounded,
                size: 18,
              ),
              text: 'Audit Logs',
            ),
            Tab(
              icon: Icon(
                Icons.settings_outlined,
                size: 18,
              ),
              text: 'Settings',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildUsersTab(),
          _buildListingsTab(),
          _buildReportsTab(),
          _buildAuditLogsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OVERVIEW TAB
  // ---------------------------------------------------------------------------

  Widget _buildOverviewTab() {
    if (_isLoadingDashboard) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllAdminData,
      color: AppTheme.royalBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null) _buildErrorCard(),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.35,
              children: [
                _buildKpiCard(
                  title: 'Verified Students',
                  value: '$_verifiedStudents',
                  subtitle: 'Registered AVIH peers',
                  icon: Icons.verified_user_outlined,
                  color: AppTheme.royalBlue,
                ),
                _buildKpiCard(
                  title: 'Active Items',
                  value: '$_activeListings',
                  subtitle: 'Currently available',
                  icon: Icons.storefront_outlined,
                  color: AppTheme.successColor,
                ),
                _buildKpiCard(
                  title: 'Pending Reports',
                  value: '$_pendingReports',
                  subtitle: 'Requires action',
                  icon: Icons.flag_outlined,
                  color: AppTheme.errorColor,
                ),
                _buildKpiCard(
                  title: 'Market Volume',
                  value:
                      '₹${_marketVolume.toStringAsFixed(0)}',
                  subtitle: 'Total listed value',
                  icon: Icons.currency_rupee_rounded,
                  color: AppTheme.cyanAccent,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.dividerColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A)
                        .withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Campus Pilot Scope',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _college?['name'] ??
                        'Avanthi Institute of Engineering and Technology (AVIH), Gunthapalli',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'College ID: ${_college?['collegeId'] ?? "avih-gunthapalli"}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verified Students: $_verifiedStudents of $_totalStudents registered',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.dividerColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A)
                        .withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Marketplace Statistics',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _statRow(
                    'Active Listings',
                    '$_activeListings',
                  ),
                  _statRow(
                    'Sold / Exchanged Listings',
                    '$_soldListings',
                  ),
                  _statRow(
                    'Closed Listings',
                    '$_closedListings',
                  ),
                  _statRow(
                    'Pending Incident Reports',
                    '$_pendingReports',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildRecentAuditStrip(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAuditStrip() {
    final logs = _auditLogs.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A)
                .withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Audit Log Activity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingAuditLogs)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          else if (logs.isEmpty)
            const Text(
              'No audit activity recorded yet.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            )
          else
            ...logs.map(
              (log) => Padding(
                padding:
                    const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 6,
                      color: AppTheme.royalBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            log['eventType']
                                    ?.toString() ??
                                'EVENT',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _eventDescription(log),
                            style: const TextStyle(
                              fontSize: 11,
                              color:
                                  AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _eventDescription(
    Map<String, dynamic> log,
  ) {
    final metadata = log['metadata'];

    if (metadata is Map &&
        metadata['reason'] != null) {
      return metadata['reason'].toString();
    }

    if (metadata is Map &&
        metadata['warningCount'] != null) {
      return 'Warning count: ${metadata['warningCount']}';
    }

    return 'Campus activity recorded.';
  }

  // ---------------------------------------------------------------------------
  // USERS TAB
  // ---------------------------------------------------------------------------

  Widget _buildUsersTab() {
    if (_isLoadingStudents) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
        ),
      );
    }

    if (_students.isEmpty) {
      return _emptyState(
        Icons.people_outline,
        'No students found',
        'There are currently no registered students in this campus.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStudents,
      color: AppTheme.royalBlue,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final st = _students[index];

          final name =
              st['fullName']?.toString() ?? 'Student';
          final email =
              st['officialEmail']?.toString() ?? '';
          final rollNumber =
              st['rollNumber']?.toString() ?? '';
          final department =
              st['department']?.toString() ??
                  'General Engineering';
          final role =
              st['role']?.toString() ?? 'student';
          final status =
              st['accountStatus']?.toString() ??
                  'active';
          final warningCount =
              st['warningCount'] ?? 0;

          final isAdmin = role == 'admin';

          return Container(
            margin: const EdgeInsets.only(
              bottom: 10,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.dividerColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A)
                      .withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration:
                          const BoxDecoration(
                        gradient:
                            AppTheme.heroCardGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty
                              ? name
                                  .substring(0, 1)
                                  .toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            email,
                            style:
                                const TextStyle(
                              fontSize: 12,
                              color: AppTheme
                                  .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _roleBadge(role),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  rollNumber.isNotEmpty
                      ? 'Roll No: $rollNumber • Dept: $department'
                      : 'Dept: $department',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'Status: ${status.toUpperCase()} • Warnings: $warningCount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                    color: status == 'suspended'
                        ? AppTheme.errorColor
                        : AppTheme.textSecondary,
                  ),
                ),

                if (!isAdmin) ...[
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () =>
                            _warnStudent(
                          st['studentId'].toString(),
                          name,
                          rollNumber: rollNumber,
                        ),
                        child: const Text(
                          'Issue Warning',
                          style: TextStyle(
                            color:
                                AppTheme.warningColor,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed:
                            status == 'suspended'
                                ? null
                                : () =>
                                    _blockStudent(
                                  st['studentId']
                                      .toString(),
                                  name,
                                  rollNumber: rollNumber,
                                ),
                        style:
                            OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(
                              0xFFFECACA,
                            ),
                          ),
                          backgroundColor:
                              const Color(
                            0xFFFEF2F2,
                          ),
                          minimumSize:
                              const Size(90, 36),
                        ),
                        child: const Text(
                          'Block User',
                          style: TextStyle(
                            color:
                                AppTheme.errorColor,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w700,
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

  Widget _roleBadge(String role) {
    Color background;
    Color textColor;
    String label;

    switch (role) {
      case 'admin':
        background =
            const Color(0xFFEFF6FF);
        textColor = AppTheme.royalBlue;
        label = 'ADMIN';
        break;

      case 'moderator':
        background =
            const Color(0xFFEFF6FF);
        textColor = AppTheme.cyanAccent;
        label = 'MODERATOR';
        break;

      default:
        background =
            const Color(0xFFF1F5F9);
        textColor =
            AppTheme.textSecondary;
        label = 'STUDENT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WARN / BLOCK ACTIONS
  // ---------------------------------------------------------------------------

  Future<void> _warnStudent(
    String studentId,
    String name, {
    String? rollNumber,
  }) async {
    try {
      await _reportService.issueWarning(
        studentId,
        rollNumber: rollNumber,
      );

      await _loadStudents();
      await _loadAuditLogs();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('Warning issued to $name'),
          backgroundColor:
              AppTheme.warningColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('Failed to issue warning: $e'),
          backgroundColor:
              AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _blockStudent(
    String studentId,
    String name, {
    String? rollNumber,
  }) async {
    try {
      await _reportService.blockStudent(
        studentId,
        rollNumber: rollNumber,
      );

      await _loadStudents();
      await _loadAuditLogs();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('$name has been blocked'),
          backgroundColor:
              AppTheme.errorColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('Failed to block user: $e'),
          backgroundColor:
              AppTheme.errorColor,
        ),
      );
    }
  }


  // ---------------------------------------------------------------------------
  // LISTINGS TAB
  // ---------------------------------------------------------------------------

  Widget _buildListingsTab() {
    if (_isLoadingListings) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
        ),
      );
    }

    if (_adminListings.isEmpty) {
      return _emptyState(
        Icons.inventory_2_outlined,
        'No listings found',
        'There are currently no listings in this campus.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadListings,
      color: AppTheme.royalBlue,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        itemCount: _adminListings.length,
        itemBuilder: (context, index) {
          final l = _adminListings[index];

          final title =
              l['title']?.toString() ??
                  'Untitled';
          final seller =
              l['sellerName']?.toString() ??
                  'Unknown seller';
          final status =
              l['status']?.toString() ??
                  'unknown';
          final price =
              (l['price'] ?? 0).toDouble();

          return Container(
            margin: const EdgeInsets.only(
              bottom: 10,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.dividerColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A)
                      .withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w900,
                        color:
                            AppTheme.primaryColor,
                      ),
                    ),
                    _statusBadge(status),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Seller: $seller',
                  style: const TextStyle(
                    fontSize: 12,
                    color:
                        AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    final active = status == 'active';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFECFDF5)
            : const Color(0xFFF1F5F9),
        borderRadius:
            BorderRadius.circular(5),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: active
              ? const Color(0xFF047857)
              : AppTheme.textSecondary,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REPORTS TAB
  // ---------------------------------------------------------------------------

  Widget _buildReportsTab() {
    if (_isLoadingReports) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
        ),
      );
    }

    if (_reports.isEmpty) {
      return _emptyState(
        Icons.check_circle_outline,
        'Moderation Queue Clean',
        'No incident reports currently pending review for this campus.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      color: AppTheme.royalBlue,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final r = _reports[index];

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showReportDetails(r),
            child: Container(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFECACA),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444)
                        .withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _showReportDetails(r),
                  borderRadius: BorderRadius.circular(16),
                  splashColor: const Color(0xFFFEF2F2),
                  highlightColor: const Color(0xFFFFF1F2),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Report: ${r.reason}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w800,
                                  color:
                                      AppTheme.errorColor,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  r.status.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.w800,
                                    color:
                                        AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: AppTheme.textSecondary,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          r.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color:
                                AppTheme.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Created: ${DateFormat('dd MMM yyyy, HH:mm').format(r.createdAt)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color:
                              AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showReportDetails(Report r) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) {
        final isOpen = r.status.toLowerCase() == 'open';
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Incident Report Details',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOpen ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isOpen ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0),
                        ),
                      ),
                      child: Text(
                        r.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isOpen ? AppTheme.errorColor : const Color(0xFF047857),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _reportDetailRow('Report ID', r.reportId),
                _reportDetailRow('Reason', r.reason),
                _reportDetailRow('Created', DateFormat('dd MMM yyyy, HH:mm').format(r.createdAt)),
                _reportDetailRow('Listing ID', r.listingId),
                _reportDetailRow('Reporter ID', r.reporterId),
                if (r.sellerId.isNotEmpty) _reportDetailRow('Reported Seller', r.sellerId),
                const SizedBox(height: 12),
                const Text(
                  'Report Description & Explanation:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Text(
                    r.description.isNotEmpty ? r.description : 'No description provided.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
                if (r.reviewNotes != null && r.reviewNotes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Review Notes:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      r.reviewNotes!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (isOpen) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _dismissReport(r.reportId);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Dismiss Report', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _resolveReport(r.reportId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Resolve Report', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _dismissReport(String reportId) async {
    try {
      await _reportService.reviewReport(
        reportId: reportId,
        status: 'dismissed',
        reviewNotes: 'Dismissed by administrator',
      );
      await _loadReports();
      await _loadAuditLogs();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report dismissed'),
          backgroundColor: AppTheme.textSecondary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to dismiss report: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _resolveReport(String reportId) async {
    try {
      await _reportService.reviewReport(
        reportId: reportId,
        status: 'resolved',
        reviewNotes: 'Resolved by administrator',
        actionTaken: 'listing_removed',
      );
      await _loadReports();
      await _loadListings();
      await _loadAuditLogs();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report resolved & action recorded'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resolve report: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Widget _reportDetailRow(String label, String value) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // AUDIT LOGS TAB
  // ---------------------------------------------------------------------------

  Widget _buildAuditLogsTab() {
    if (_isLoadingAuditLogs) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
        ),
      );
    }

    if (_auditLogs.isEmpty) {
      return _emptyState(
        Icons.history,
        'No Audit Logs',
        'No moderation or administration activity has been recorded yet.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAuditLogs,
      color: AppTheme.royalBlue,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        itemCount: _auditLogs.length,
        itemBuilder: (context, index) {
          final log = _auditLogs[index];

          final eventType =
              log['eventType']?.toString() ??
                  'EVENT';

          final occurredAt =
              log['occurredAt'] != null
                  ? DateTime.tryParse(
                      log['occurredAt']
                          .toString(),
                    )
                  : null;

          return Container(
            margin: const EdgeInsets.only(
              bottom: 8,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.dividerColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A)
                      .withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(0xFFEFF6FF),
                        borderRadius:
                            BorderRadius.circular(
                          4,
                        ),
                      ),
                      child: Text(
                        eventType,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              AppTheme.royalBlue,
                        ),
                      ),
                    ),
                    if (occurredAt != null)
                      Text(
                        DateFormat(
                          'dd MMM yyyy, HH:mm',
                        ).format(occurredAt),
                        style:
                            const TextStyle(
                          fontSize: 10,
                          color: AppTheme
                              .textSecondary,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  _eventDescription(log),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Student: ${log['studentId'] ?? "—"}',
                  style: const TextStyle(
                    fontSize: 10,
                    color:
                        AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SETTINGS TAB
  // ---------------------------------------------------------------------------

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'System Security & Campus Policy',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.dividerColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A)
                      .withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding:
                      EdgeInsets.zero,
                  title: const Text(
                    'Campus Name',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    _college?['name'] ??
                        'Avanthi Institute of Engineering and Technology (AVIH), Gunthapalli',
                  ),
                ),

                const Divider(),

                ListTile(
                  contentPadding:
                      EdgeInsets.zero,
                  title: const Text(
                    'Verification Domain',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    _college?[
                            'verificationDomain'] ??
                        'avih.edu.in',
                  ),
                ),

                const Divider(),

                ListTile(
                  contentPadding:
                      EdgeInsets.zero,
                  title: const Text(
                    'Enrolled Students',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    '$_totalStudents students registered',
                  ),
                ),

                const Divider(),

                ListTile(
                  contentPadding:
                      EdgeInsets.zero,
                  title: const Text(
                    'Verified Students',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    '$_verifiedStudents verified',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A)
                .withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color:
                        AppTheme.textSecondary,
                    fontWeight:
                        FontWeight.w700,
                  ),
                  overflow:
                      TextOverflow.ellipsis,
                ),
              ),
              Icon(
                icon,
                size: 18,
                color: color,
              ),
            ],
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w900,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color:
                      AppTheme.textSecondary,
                ),
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color:
                  AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w800,
              color:
                  AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFECACA),
        ),
      ),
      child: const Text(
        'Unable to load some admin data. Please check the server connection.',
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.errorColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _emptyState(
    IconData icon,
    String title,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
                color:
                    AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color:
                    AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}