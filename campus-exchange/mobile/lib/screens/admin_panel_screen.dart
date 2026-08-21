import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/listing.dart';
import '../models/report.dart';
import '../models/student.dart';
import '../providers/auth_provider.dart';
import '../providers/listing_provider.dart';
import '../services/listing_service.dart';
import '../services/report_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ListingService _listingService = ListingService();
  final ReportService _reportService = ReportService();

  List<Report> _reports = [];
  bool _isLoadingReports = false;

  // Mocked state for interactive admin testing
  bool _maintenanceMode = false;
  double _maxPriceLimit = 50000;
  int _autoFlagThreshold = 3;

  final List<Map<String, dynamic>> _auditLogs = [
    {
      'id': 'log_101',
      'action': 'LISTING_DELETED',
      'target': 'l_avih_1 (Engineering Drawing Kit)',
      'actor': 'Dr. Rajesh Sharma (admin@avih.edu.in)',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'details': 'Soft-deleted listing due to item description clarification request.',
    },
    {
      'id': 'log_102',
      'action': 'USER_WARNED',
      'target': 's_jntuh_101 (Rahul Sharma)',
      'actor': 'Prof. Ananya Rao (mod@jntuh.edu.in)',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'details': 'Issued official academic marketplace policy reminder.',
    },
    {
      'id': 'log_103',
      'action': 'REPORT_RESOLVED',
      'target': 'rep_101',
      'actor': 'Dr. Rajesh Sharma (admin@avih.edu.in)',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'details': 'Report resolved: Verified seller compliance with campus safety guidelines.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoadingReports = true);
    try {
      final reports = await _reportService.getReports();
      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoadingReports = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingReports = false);
      }
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  'Campus Admin Command Center',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      'ADMIN',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${student?.fullName ?? "Administrator"} • ${student?.officialEmail ?? "admin@campus.edu.in"}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF93C5FD)),
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
            Tab(icon: Icon(Icons.dashboard_outlined, size: 20), text: 'Overview'),
            Tab(icon: Icon(Icons.people_outline, size: 20), text: 'Users'),
            Tab(icon: Icon(Icons.inventory_2_outlined, size: 20), text: 'Listings'),
            Tab(icon: Icon(Icons.gavel_outlined, size: 20), text: 'Reports'),
            Tab(icon: Icon(Icons.history_outlined, size: 20), text: 'Audit Logs'),
            Tab(icon: Icon(Icons.settings_outlined, size: 20), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(listingProvider),
          _buildUsersTab(authProvider),
          _buildListingsTab(listingProvider),
          _buildReportsTab(),
          _buildAuditLogsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  // 1. Overview Tab
  Widget _buildOverviewTab(ListingProvider listingProvider) {
    final listings = listingProvider.listings;
    final totalListings = listings.length;
    final soldListings = listings.where((l) => l.status == 'sold').length;
    final totalVolume = listings.fold<double>(0, (sum, l) => sum + l.price);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Metric Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.35,
            children: [
              _buildKpiCard(
                title: 'Total Verified',
                value: '42 Students',
                subtitle: 'Active campus domain',
                icon: Icons.verified_user,
                color: AppTheme.primaryColor,
              ),
              _buildKpiCard(
                title: 'Active Items',
                value: '$totalListings Items',
                subtitle: '$soldListings completed sales',
                icon: Icons.storefront,
                color: AppTheme.secondaryColor,
              ),
              _buildKpiCard(
                title: 'Pending Reports',
                value: '${_reports.where((r) => r.status == 'pending').length}',
                subtitle: 'Requires moderator SLA',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFE11D48),
              ),
              _buildKpiCard(
                title: 'Market Volume',
                value: '₹${totalVolume.toStringAsFixed(0)}',
                subtitle: 'Peer-to-peer campus volume',
                icon: Icons.currency_rupee,
                color: const Color(0xFFD97706),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Campus Partition Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Campus Partition Distribution',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  _buildPartitionRow('Avanthi Institute of Tech (AVIH)', 0.65, '28 items', AppTheme.primaryColor),
                  const SizedBox(height: 10),
                  _buildPartitionRow('Jawaharlal Nehru Tech Univ (JNTUH)', 0.35, '14 items', AppTheme.secondaryColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recent Audit Strip
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Audit Activity',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      Text(
                        'Live Record',
                        style: TextStyle(fontSize: 12, color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  ..._auditLogs.take(2).map((log) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.circle, size: 8, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${log['action']} • ${log['target']}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    log['details'] as String,
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(12),
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
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartitionRow(String campus, double progress, String countLabel, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                campus,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              countLabel,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  // 2. Users Tab
  Widget _buildUsersTab(AuthProvider authProvider) {
    final mockStudents = [
      {
        'name': 'Dr. Rajesh Sharma',
        'email': 'admin@avih.edu.in',
        'dept': 'Faculty of Engineering',
        'role': 'CHIEF ADMINISTRATOR',
        'trust': 100,
        'status': 'ACTIVE',
      },
      {
        'name': 'Prof. Ananya Rao',
        'email': 'mod@jntuh.edu.in',
        'dept': 'Student Welfare & Moderation',
        'role': 'CAMPUS MODERATOR',
        'trust': 98,
        'status': 'ACTIVE',
      },
      {
        'name': 'Venu Madhav',
        'studentId': 'std_6296801a-e',
        'email': 'venumadhav@avih.edu.in',
        'dept': 'Computer Science',
        'role': 'STUDENT',
        'trust': 95,
        'status': 'ACTIVE',
      },
      {
        'name': 'Rahul Sharma',
        'email': 'rahul.s@jntuh.edu.in',
        'dept': 'Mechanical Engineering',
        'role': 'STUDENT',
        'trust': 90,
        'status': 'ACTIVE',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockStudents.length,
      itemBuilder: (context, index) {
        final st = mockStudents[index];
        final isStaff = st['role'] != 'STUDENT';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: isStaff ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
                          child: Text(
                            (st['name'] as String).substring(0, 1),
                            style: TextStyle(
                              color: isStaff ? Colors.white : AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              st['name'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              st['email'] as String,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isStaff ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        st['role'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isStaff ? const Color(0xFF15803D) : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Department: ${st['dept']} • Trust Rating: ${st['trust']}/100',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                    try {
                      await _reportService.issueWarning(
                        st['studentId'] as String,
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Warning issued to ${st['name']}'),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to issue warning: $e'),
                        ),
                      );
                    }
                  },
                      child: const Text('Issue Warning', style: TextStyle(fontSize: 12, color: Color(0xFFD97706))),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          await _reportService.blockStudent(
                            st['studentId'] as String,
                          );

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('User ${st['name']} has been blocked'),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to block user: $e'),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE11D48)),
                        minimumSize: const Size(60, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text('Block User', style: TextStyle(fontSize: 11, color: Color(0xFFE11D48))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 3. Listings Tab
  Widget _buildListingsTab(ListingProvider listingProvider) {
    final listings = listingProvider.listings;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final l = listings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${l.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: l.status == 'active' ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: l.status == 'active' ? const Color(0xFF15803D) : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Seller: ${l.sellerName} • Campus: ${l.collegeId}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Flagged "${l.title}" for review')),
                        );
                      },
                      child: const Text('Flag', style: TextStyle(fontSize: 12, color: Color(0xFFD97706))),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _showSoftDeleteDialog(l);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE11D48),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text('Soft-Delete', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSoftDeleteDialog(Listing listing) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Soft-Delete Listing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to take down "${listing.title}"? It will be archived for audit compliance.'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Takedown Reason',
                hintText: 'e.g. Prohibited item or commercial advertisement',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _auditLogs.insert(0, {
                  'id': 'log_${DateTime.now().millisecondsSinceEpoch}',
                  'action': 'LISTING_SOFT_DELETED',
                  'target': '${listing.listingId} (${listing.title})',
                  'actor': 'Administrator',
                  'timestamp': DateTime.now(),
                  'details': reasonController.text.isNotEmpty ? reasonController.text : 'Policy compliance enforcement',
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Listing "${listing.title}" soft-deleted and logged.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            child: const Text('Confirm Soft-Delete'),
          ),
        ],
      ),
    );
  }

  // 4. Reports Tab
  Widget _buildReportsTab() {
    if (_isLoadingReports) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reports.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 48, color: AppTheme.secondaryColor),
              SizedBox(height: 12),
              Text(
                'Moderation Queue Clean',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              SizedBox(height: 4),
              Text(
                'No pending student incident reports at this moment.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final r = _reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Report: ${r.reason}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE11D48)),
                    ),
                    Text(
                      r.status.toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '"${r.description}"',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Listing: ${r.listingId} • Created: ${DateFormat('dd MMM, HH:mm').format(r.createdAt)}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Report marked as dismissed.')),
                        );
                      },
                      child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Report resolved and seller warned.')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        minimumSize: const Size(70, 32),
                      ),
                      child: const Text('Resolve Action', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 5. Audit Logs Tab
  Widget _buildAuditLogsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _auditLogs.length,
      itemBuilder: (context, index) {
        final log = _auditLogs[index];
        final timestamp = log['timestamp'] as DateTime;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log['action'] as String,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(timestamp),
                      style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  log['details'] as String,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Actor: ${log['actor']} • Target: ${log['target']}',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 6. Settings & Security Policies Tab
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Security & Campus Policy',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Emergency Maintenance Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Temporarily halts new listings and active chats across all campus partitions.', style: TextStyle(fontSize: 12)),
                    value: _maintenanceMode,
                    onChanged: (val) => setState(() => _maintenanceMode = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Maximum Item Listing Price Limit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Current threshold: ₹${_maxPriceLimit.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                    contentPadding: EdgeInsets.zero,
                  ),
                  Slider(
                    value: _maxPriceLimit,
                    min: 5000,
                    max: 100000,
                    divisions: 19,
                    label: '₹${_maxPriceLimit.toStringAsFixed(0)}',
                    onChanged: (val) => setState(() => _maxPriceLimit = val),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Auto-Flag Trigger Threshold', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Items are auto-quarantined after $_autoFlagThreshold user reports.', style: const TextStyle(fontSize: 12)),
                    contentPadding: EdgeInsets.zero,
                  ),
                  Slider(
                    value: _autoFlagThreshold.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '$_autoFlagThreshold Reports',
                    onChanged: (val) => setState(() => _autoFlagThreshold = val.toInt()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Allowed Email Domain Whitelist',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text('• @avih.edu.in (Avanthi Institute of Tech)', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 4),
                  Text('• @jntuh.edu.in (JNTUH Campus)', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 4),
                  Text('• @campus.edu.in (System Admins & Faculty)', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Campus security governance settings saved successfully!')),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Security Configuration'),
          ),
        ],
      ),
    );
  }
}
