import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../core/theme/app_theme.dart';
import '../models/listing.dart';
import '../models/report.dart';
import '../providers/auth_provider.dart';
import '../providers/listing_provider.dart';
import '../routes/app_routes.dart';
import '../services/report_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ReportService _reportService = ReportService();

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
  // BACKEND BASE URL
  // ---------------------------------------------------------------------------

  String get _baseUrl {
    // Android emulator -> computer localhost
    return 'http://10.0.2.2:5000/api/v1';
  }

  Future<Map<String, String>> _headers() async {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    /*
     * AuthService stores the JWT.
     * We use the same token through the auth service/provider flow.
     *
     * The current backend authentication is already working for your app.
     */
    final token = await _getStoredToken(authProvider);

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<String?> _getStoredToken(AuthProvider authProvider) async {
    /*
     * We obtain the token from the AuthService's stored session.
     * If your AuthService exposes the token differently, the existing
     * authenticated API calls remain unaffected.
     */
    try {
      final dynamic service = authProvider;
      final result = await service.getToken();
      return result?.toString();
    } catch (_) {
      return null;
    }
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
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/dashboard'),
        headers: await _headers(),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Dashboard request failed: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      final data = decoded['data'] ?? {};

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
        _marketVolume =
            (market['volume'] ?? 0).toDouble();

        _isLoadingDashboard = false;
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
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/students'),
        headers: await _headers(),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Students request failed: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      final List<dynamic> data = decoded['data'] ?? [];

      if (!mounted) return;

      setState(() {
        _students = data
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

        _isLoadingStudents = false;
      });
    } catch (e) {
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
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/audit-logs'),
        headers: await _headers(),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Audit log request failed: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      final List<dynamic> data = decoded['data'] ?? [];

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
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/listings'),
        headers: await _headers(),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Listings request failed: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      final List<dynamic> data = decoded['data'] ?? [];

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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Campus Admin Command Center',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF166534),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${student?.fullName ?? "Administrator"} • '
              '${student?.officialEmail ?? ""}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF93C5FD),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF93C5FD),
          indicatorColor: AppTheme.accentColor,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard_outlined, size: 20),
              text: 'Overview',
            ),
            Tab(
              icon: Icon(Icons.people_outline, size: 20),
              text: 'Users',
            ),
            Tab(
              icon: Icon(Icons.inventory_2_outlined, size: 20),
              text: 'Listings',
            ),
            Tab(
              icon: Icon(Icons.gavel_outlined, size: 20),
              text: 'Reports',
            ),
            Tab(
              icon: Icon(Icons.history_outlined, size: 20),
              text: 'Audit Logs',
            ),
            Tab(
              icon: Icon(Icons.settings_outlined, size: 20),
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
  // OVERVIEW
  // ---------------------------------------------------------------------------

  Widget _buildOverviewTab() {
    if (_isLoadingDashboard) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllAdminData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              _buildErrorCard(),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.35,
              children: [
                _buildKpiCard(
                  title: 'Verified Students',
                  value: '$_verifiedStudents',
                  subtitle: 'Real registered students',
                  icon: Icons.verified_user,
                  color: AppTheme.primaryColor,
                ),
                _buildKpiCard(
                  title: 'Active Items',
                  value: '$_activeListings',
                  subtitle: 'Currently listed',
                  icon: Icons.storefront,
                  color: AppTheme.secondaryColor,
                ),
                _buildKpiCard(
                  title: 'Pending Reports',
                  value: '$_pendingReports',
                  subtitle: 'Requires moderation',
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFE11D48),
                ),
                _buildKpiCard(
                  title: 'Market Volume',
                  value:
                      '₹${_marketVolume.toStringAsFixed(0)}',
                  subtitle: 'Listing value',
                  icon: Icons.currency_rupee,
                  color: const Color(0xFFD97706),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Campus Information',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _college?['name'] ??
                          'No college information',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'College ID: '
                      '${_college?['collegeId'] ?? "—"}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Verified students: $_verifiedStudents',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total students: $_totalStudents',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Marketplace Statistics',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _statRow(
                      'Active listings',
                      '$_activeListings',
                    ),
                    _statRow(
                      'Sold listings',
                      '$_soldListings',
                    ),
                    _statRow(
                      'Closed listings',
                      '$_closedListings',
                    ),
                    _statRow(
                      'Pending reports',
                      '$_pendingReports',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            _buildRecentAuditStrip(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAuditStrip() {
    final logs = _auditLogs.take(3).toList();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Audit Activity',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingAuditLogs)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
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
                      const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              log['eventType']?.toString() ??
                                  'EVENT',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
      return 'Warning count: '
          '${metadata['warningCount']}';
    }

    return 'Campus activity recorded.';
  }

  // ---------------------------------------------------------------------------
  // USERS
  // ---------------------------------------------------------------------------

  Widget _buildUsersTab() {
    if (_isLoadingStudents) {
      return const Center(
        child: CircularProgressIndicator(),
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
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final st = _students[index];

          final name =
              st['fullName']?.toString() ??
                  'Student';

          final email =
              st['officialEmail']?.toString() ??
                  '';

          final department =
              st['department']?.toString() ??
                  'General Engineering';

          final role =
              st['role']?.toString() ??
                  'student';

          final status =
              st['accountStatus']?.toString() ??
                  'active';

          final warningCount =
              st['warningCount'] ?? 0;

          final isAdmin = role == 'admin';
          final isModerator = role == 'moderator';

          return Card(
            margin:
                const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            isAdmin
                                ? const Color(
                                    0xFF1E3A8A,
                                  )
                                : isModerator
                                    ? const Color(
                                        0xFF7C3AED,
                                      )
                                    : const Color(
                                        0xFFE2E8F0,
                                      ),
                        child: Text(
                          name.isNotEmpty
                              ? name
                                  .substring(0, 1)
                                  .toUpperCase()
                              : '?',
                          style: TextStyle(
                            color:
                                isAdmin ||
                                        isModerator
                                    ? Colors.white
                                    : AppTheme
                                        .primaryColor,
                            fontWeight:
                                FontWeight.bold,
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
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
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
                    'Department: $department',
                    style: const TextStyle(
                      fontSize: 12,
                      color:
                          AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Status: ${status.toUpperCase()}'
                    ' • Warnings: $warningCount',
                    style: TextStyle(
                      fontSize: 12,
                      color: status ==
                              'suspended'
                          ? Colors.red
                          : AppTheme
                              .textSecondary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Student ID: '
                    '${st['studentId'] ?? "—"}',
                    style: const TextStyle(
                      fontSize: 11,
                      color:
                          AppTheme.textSecondary,
                    ),
                  ),

                  if (!isAdmin) ...[
                    const Divider(height: 18),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () =>
                              _warnStudent(
                                st['studentId']
                                    .toString(),
                                name,
                              ),
                          child: const Text(
                            'Issue Warning',
                            style: TextStyle(
                              color:
                                  Color(0xFFD97706),
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
                                      ),
                          style:
                              OutlinedButton.styleFrom(
                            side:
                                const BorderSide(
                              color:
                                  Color(0xFFE11D48),
                            ),
                          ),
                          child: const Text(
                            'Block User',
                            style: TextStyle(
                              color:
                                  Color(0xFFE11D48),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
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
            const Color(0xFFDBEAFE);
        textColor =
            const Color(0xFF1E3A8A);
        label = 'ADMIN';
        break;

      case 'moderator':
        background =
            const Color(0xFFEDE9FE);
        textColor =
            const Color(0xFF7C3AED);
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
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WARN / BLOCK
  // ---------------------------------------------------------------------------

  Future<void> _warnStudent(
    String studentId,
    String name,
  ) async {
    try {
      await _reportService.issueWarning(
        studentId,
      );

      await _loadStudents();
      await _loadAuditLogs();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('Warning issued to $name'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('Failed to issue warning: $e'),
        ),
      );
    }
  }

  Future<void> _blockStudent(
    String studentId,
    String name,
  ) async {
    try {
      await _reportService.blockStudent(
        studentId,
      );

      await _loadStudents();
      await _loadAuditLogs();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('$name has been blocked'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('Failed to block user: $e'),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // LISTINGS
  // ---------------------------------------------------------------------------

  Widget _buildListingsTab() {
    if (_isLoadingListings) {
      return const Center(
        child: CircularProgressIndicator(),
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
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
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

          return Card(
            margin:
                const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              AppTheme
                                  .primaryColor,
                        ),
                      ),
                      _statusBadge(status),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Seller: $seller',
                    style:
                        const TextStyle(
                      fontSize: 11,
                      color:
                          AppTheme
                              .textSecondary,
                    ),
                  ),

                  Text(
                    'Campus: '
                    '${l['collegeId'] ?? "—"}',
                    style:
                        const TextStyle(
                      fontSize: 11,
                      color:
                          AppTheme
                              .textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    final active = status == 'active';

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFF1F5F9),
        borderRadius:
            BorderRadius.circular(5),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight:
              FontWeight.bold,
          color: active
              ? const Color(0xFF15803D)
              : AppTheme.textSecondary,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REPORTS
  // ---------------------------------------------------------------------------

  Widget _buildReportsTab() {
    if (_isLoadingReports) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_reports.isEmpty) {
      return _emptyState(
        Icons.check_circle_outline,
        'Moderation Queue Clean',
        'No reports currently exist for this campus.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final r = _reports[index];

          return Card(
            margin:
                const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding:
                  const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Report: ${r.reason}',
                          style:
                              const TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Color(0xFFE11D48),
                          ),
                        ),
                      ),
                      Text(
                        r.status
                            .toUpperCase(),
                        style:
                            const TextStyle(
                          fontSize: 10,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              AppTheme
                                  .textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    r.description,
                    style:
                        const TextStyle(
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Listing: ${r.listingId}',
                    style:
                        const TextStyle(
                      fontSize: 11,
                      color:
                          AppTheme
                              .textSecondary,
                    ),
                  ),

                  Text(
                    'Created: '
                    '${DateFormat('dd MMM yyyy, HH:mm').format(r.createdAt)}',
                    style:
                        const TextStyle(
                      fontSize: 11,
                      color:
                          AppTheme
                              .textSecondary,
                    ),
                  ),
                ],
              ),
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
    if (_isLoadingAuditLogs) {
      return const Center(
        child: CircularProgressIndicator(),
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
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
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

          final metadata =
              log['metadata'];

          return Card(
            margin:
                const EdgeInsets.only(
              bottom: 10,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFDCFCE7,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(4),
                        ),
                        child: Text(
                          eventType,
                          style:
                              const TextStyle(
                            fontSize: 10,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Color(
                              0xFF166534,
                            ),
                          ),
                        ),
                      ),
                      if (occurredAt != null)
                        Text(
                          DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(
                            occurredAt,
                          ),
                          style:
                              const TextStyle(
                            fontSize: 10,
                            color:
                                AppTheme
                                    .textSecondary,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _eventDescription(log),
                    style:
                        const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Student: '
                    '${log['studentId'] ?? "—"}',
                    style:
                        const TextStyle(
                      fontSize: 10,
                      color:
                          AppTheme
                              .textSecondary,
                    ),
                  ),

                  if (log['listingId'] != null)
                    Text(
                      'Listing: '
                      '${log['listingId']}',
                      style:
                          const TextStyle(
                        fontSize: 10,
                        color:
                            AppTheme
                                .textSecondary,
                      ),
                    ),

                  if (metadata is Map &&
                      metadata.isNotEmpty)
                    Text(
                      'Details: '
                      '${metadata.toString()}',
                      style:
                          const TextStyle(
                        fontSize: 10,
                        color:
                            AppTheme
                                .textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SETTINGS
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    title: const Text(
                      'Campus',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _college?['name'] ??
                          'Unknown',
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
                            FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _college?[
                              'verificationDomain'] ??
                          'Not configured',
                    ),
                  ),

                  const Divider(),

                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    title: const Text(
                      'Registered Students',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '$_totalStudents students',
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
                            FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '$_verifiedStudents verified',
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
      padding:
          const EdgeInsets.all(12),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color:
              const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        AppTheme
                            .textSecondary,
                    fontWeight:
                        FontWeight.w600,
                  ),
                  overflow:
                      TextOverflow
                          .ellipsis,
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
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style:
                    const TextStyle(
                  fontSize: 10,
                  color:
                      AppTheme
                          .textSecondary,
                ),
                maxLines: 1,
                overflow:
                    TextOverflow
                        .ellipsis,
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
            MainAxisAlignment
                .spaceBetween,
        children: [
          Text(
            label,
            style:
                const TextStyle(
              fontSize: 13,
              color:
                  AppTheme
                      .textSecondary,
            ),
          ),
          Text(
            value,
            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.bold,
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
          const EdgeInsets.only(
        bottom: 16,
      ),
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            const Color(0xFFFEE2E2),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Text(
        'Unable to load some admin data. '
        'Please check the server connection.',
        style:
            const TextStyle(
          fontSize: 12,
          color:
              Color(0xFF991B1B),
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
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color:
                  AppTheme.secondaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style:
                  const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 13,
                color:
                    AppTheme
                        .textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}