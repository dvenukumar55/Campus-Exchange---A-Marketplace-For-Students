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
    final bool canAccessAdminPanel = student?.canAccessAdminPanel ?? false;

    // Role-based profile badge
    String roleBadgeText;
    Color roleBadgeColor;
    Color roleBadgeBackground;
    IconData roleBadgeIcon;

    if (isAdmin) {
      roleBadgeText = 'Campus Administrator';
      roleBadgeColor = AppTheme.primaryColor;
      roleBadgeBackground = AppTheme.primaryColor.withOpacity(0.1);
      roleBadgeIcon = Icons.admin_panel_settings_rounded;
    } else if (isModerator) {
      roleBadgeText = 'Campus Moderator';
      roleBadgeColor = AppTheme.violetAccent;
      roleBadgeBackground = AppTheme.violetAccent.withOpacity(0.1);
      roleBadgeIcon = Icons.shield_rounded;
    } else {
      roleBadgeText = 'Verified College Student';
      roleBadgeColor = AppTheme.successColor;
      roleBadgeBackground = AppTheme.successColor.withOpacity(0.1);
      roleBadgeIcon = Icons.verified_rounded;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          isAdmin
              ? 'Administrator Profile'
              : isModerator
                  ? 'Moderator Profile'
                  : 'Student Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Hero Card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: roleBadgeColor.withOpacity(0.3), width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: roleBadgeBackground,
                      child: Icon(
                        roleBadgeIcon,
                        size: 48,
                        color: roleBadgeColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    student?.fullName ?? 'Verified Student',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    student?.officialEmail ?? 'student@example.com',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: roleBadgeBackground,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(roleBadgeIcon, color: roleBadgeColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          roleBadgeText,
                          style: TextStyle(
                            fontSize: 13,
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
            const SizedBox(height: 32),
            
            // College Information Card
            _buildSectionHeader('Campus Membership'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Column(
                children: [
                  _buildProfileRow(Icons.account_balance_rounded, 'Institution', student?.collegeName ?? 'My College'),
                  const Divider(height: 24),
                  _buildProfileRow(Icons.badge_rounded, 'College ID', student?.collegeId ?? 'college-id'),
                  const Divider(height: 24),
                  _buildProfileRow(Icons.domain_rounded, 'Department', student?.department ?? 'Engineering'),
                  const Divider(height: 24),
                  _buildProfileRow(Icons.check_circle_rounded, 'Status', student?.accountStatus.toUpperCase() ?? 'ACTIVE', valueColor: AppTheme.successColor),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Actions
            _buildSectionHeader('Account Actions'),
            const SizedBox(height: 16),
            _buildActionTile(
              context,
              icon: Icons.list_alt_rounded,
              color: AppTheme.primaryColor,
              title: 'My Listed Items',
              onTap: () => Navigator.pushNamed(context, AppRoutes.myListings),
            ),
            const SizedBox(height: 12),
            if (canAccessAdminPanel) ...[
              _buildActionTile(
                context,
                icon: isAdmin ? Icons.admin_panel_settings_rounded : Icons.shield_rounded,
                color: AppTheme.violetAccent,
                title: isAdmin ? 'Admin Panel' : 'Moderation Panel',
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminPanel),
              ),
              const SizedBox(height: 12),
            ],
            
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.verification, (r) => false);
                }
              },
              icon: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
              label: const Text('Logout Session', style: TextStyle(color: AppTheme.errorColor)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.errorColor, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value, {Color valueColor = AppTheme.textPrimary}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, {required IconData icon, required Color color, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}