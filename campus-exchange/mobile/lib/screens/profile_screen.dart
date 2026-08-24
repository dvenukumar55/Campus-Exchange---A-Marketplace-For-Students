import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final student = authProvider.currentStudent;

    final bool isAdmin = student?.isAdmin ?? false;
    final bool isModerator = student?.isModerator ?? false;
    final bool canAccessAdminPanel =
        student?.canAccessAdminPanel ?? false;

    // Role-based profile badge
    String roleBadgeText;
    Color roleBadgeColor;
    Color roleBadgeBackground;
    IconData roleBadgeIcon;

    if (isAdmin) {
      roleBadgeText = 'Campus Administrator';
      roleBadgeColor = const Color(0xFF1E3A8A);
      roleBadgeBackground = const Color(0xFFDBEAFE);
      roleBadgeIcon = Icons.admin_panel_settings;
    } else if (isModerator) {
      roleBadgeText = 'Campus Moderator';
      roleBadgeColor = const Color(0xFF7C3AED);
      roleBadgeBackground = const Color(0xFFEDE9FE);
      roleBadgeIcon = Icons.shield;
    } else {
      roleBadgeText = 'Verified College Student';
      roleBadgeColor = const Color(0xFF15803D);
      roleBadgeBackground = const Color(0xFFDCFCE7);
      roleBadgeIcon = Icons.verified;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAdmin
              ? 'Administrator Profile & Status'
              : isModerator
                  ? 'Moderator Profile & Status'
                  : 'Student Profile & Status',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                        AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      isAdmin
                          ? Icons.admin_panel_settings
                          : isModerator
                              ? Icons.shield
                              : Icons.person,
                      size: 42,
                      color: AppTheme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    student?.fullName ?? 'Verified Student',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    student?.officialEmail ?? 'student@avih.edu.in',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ROLE BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: roleBadgeBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          roleBadgeIcon,
                          color: roleBadgeColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          roleBadgeText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: roleBadgeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // College Context Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Campus Membership',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _buildProfileRow(
                    'Institution',
                    student?.collegeName ??
                        'AVIH, Gunthapalli',
                  ),

                  _buildProfileRow(
                    'College ID',
                    student?.collegeId ??
                        'avih-gunthapalli',
                  ),

                  _buildProfileRow(
                    'Department',
                    student?.department ??
                        'Engineering',
                  ),

                  _buildProfileRow(
                    'Account Status',
                    student?.accountStatus.toUpperCase() ??
                        'ACTIVE',
                  ),

                  // Show role in membership details
                  _buildProfileRow(
                    'Account Role',
                    student?.role.toUpperCase() ??
                        'STUDENT',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // My Listed Items
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.white,
              leading: const Icon(
                Icons.list_alt,
                color: AppTheme.primaryColor,
              ),
              title: const Text(
                'My Listed Items',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.myListings,
                );
              },
            ),

            const SizedBox(height: 10),

            // Pilot Metrics
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.white,
              leading: const Icon(
                Icons.bar_chart,
                color: AppTheme.secondaryColor,
              ),
              title: const Text(
                'Pilot Conversion Metrics',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.metricsDashboard,
                );
              },
            ),

            // ADMIN / MODERATOR PANEL
            //
            // This entire ListTile is hidden from normal students.
            if (canAccessAdminPanel) ...[
              const SizedBox(height: 10),

              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.white,
                leading: Icon(
                  isAdmin
                      ? Icons.admin_panel_settings
                      : Icons.shield,
                  color: const Color(0xFF1E3A8A),
                ),
                title: Text(
                  isAdmin
                      ? 'Admin & Moderation Panel'
                      : 'Moderation Panel',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  isAdmin
                      ? 'Campus governance & safety controls'
                      : 'Campus moderation & safety controls',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.adminPanel,
                  );
                },
              ),
            ],

            const SizedBox(height: 32),

            // Logout
            OutlinedButton.icon(
              onPressed: () async {
                await authProvider.logout();

                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.verification,
                    (r) => false,
                  );
                }
              },
              icon: const Icon(
                Icons.logout,
                color: AppTheme.errorColor,
              ),
              label: const Text(
                'Logout Session',
                style: TextStyle(
                  color: AppTheme.errorColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppTheme.errorColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}