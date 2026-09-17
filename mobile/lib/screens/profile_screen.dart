import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/display_utils.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final student = authProvider.currentStudent;

    final bool canAccessAdmin = student?.canAccessAdminPanel ?? false;
    final bool isAdmin = student?.isAdmin == true;

    final String displayName =
        student?.fullName ?? (isAdmin ? 'Administrator' : 'Student Member');

    final String email = student?.officialEmail ?? '';

    final String initial = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : (isAdmin ? 'A' : 'S');

    return Scaffold(
      backgroundColor: const Color(0xFF0B1128),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1128),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          isAdmin ? 'Admin Profile' : 'My Profile',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                children: [
                  _buildProfileHero(
                    displayName: displayName,
                    email: formatDisplayEmail(email),
                    initial: initial,
                    isAdmin: isAdmin,
                    isVerified: student?.isVerified == true,
                  ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Campus Information',
              icon: Icons.school_rounded,
              iconColor: const Color(0xFF60A5FA),
              children: [
                _buildInfoRow(
                  icon: Icons.account_balance_rounded,
                  iconColor: const Color(0xFF60A5FA),
                  label: 'Institution',
                  value: student?.collegeName ?? AppConstants.pilotCollegeName,
                ),
                _buildDivider(),
                _buildInfoRow(
                  icon: Icons.category_rounded,
                  iconColor: const Color(0xFF2DD4BF),
                  label: 'Department',
                  value:
                      student?.department ?? 'Computer Science & Engineering',
                ),
                _buildDivider(),
                _buildInfoRow(
                  icon: Icons.badge_rounded,
                  iconColor: const Color(0xFF38BDF8),
                  label: 'Roll Number',
                  value: student?.rollNumber != null &&
                          student!.rollNumber!.isNotEmpty
                      ? student.rollNumber!
                      : (isAdmin ? 'ADMINISTRATOR' : 'STUDENT'),
                ),
                _buildDivider(),
                _buildInfoRow(
                  icon: Icons.verified_user_rounded,
                  iconColor: const Color(0xFF22C55E),
                  label: 'Account Status',
                  value: student?.accountStatus.toUpperCase() ?? 'ACTIVE',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Marketplace',
              icon: Icons.storefront_rounded,
              iconColor: const Color(0xFF818CF8),
              children: [
                _buildActionTile(
                  icon: Icons.inventory_2_rounded,
                  title: 'My Listings',
                  subtitle: 'Manage items you posted',
                  color: const Color(0xFF60A5FA),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.myListings,
                    );
                  },
                ),
                if (canAccessAdmin) ...[
                  _buildDivider(),
                  _buildActionTile(
                    icon: Icons.insights_rounded,
                    title: 'Marketplace Metrics',
                    subtitle: 'View marketplace performance',
                    color: const Color(0xFF2DD4BF),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.metricsDashboard,
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildActionTile(
                    icon: Icons.admin_panel_settings_rounded,
                    title: 'Admin Command Center',
                    subtitle: 'Moderation and governance',
                    color: const Color(0xFFA78BFA),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.adminPanel,
                      );
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Account',
              icon: Icons.manage_accounts_rounded,
              iconColor: const Color(0xFF2DD4BF),
              children: [
                _buildActionTile(
                  icon: Icons.notifications_rounded,
                  title: 'Notifications',
                  subtitle: 'View your latest updates',
                  color: const Color(0xFF38BDF8),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.notifications,
                    );
                  },
                ),
                _buildDivider(),
                _buildActionTile(
                  icon: Icons.logout_rounded,
                  title: 'Sign Out',
                  subtitle: 'End your current session',
                  color: const Color(0xFFFB7185),
                  onTap: () {
                    _confirmLogout(context, authProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Campus Exchange',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Verified student-to-student marketplace',
              style: TextStyle(
                fontSize: 10.5,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),
);
}

  Widget _buildProfileHero({
    required String displayName,
    required String email,
    required String initial,
    required bool isAdmin,
    required bool isVerified,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        color: const Color(0xFF111936),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isAdmin
                    ? const [
                        Color(0xFFFBBF24),
                        Color(0xFFF59E0B),
                        Color(0xFFEA580C),
                      ]
                    : const [
                        Color(0xFF38BDF8),
                        Color(0xFF6366F1),
                        Color(0xFF8B5CF6),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isAdmin
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF6366F1))
                      .withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0B1128),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            email,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isAdmin
                  ? const Color(0x2BFBBF24)
                  : const Color(0x2B22C55E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAdmin
                    ? const Color(0x59FBBF24)
                    : const Color(0x5922C55E),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAdmin ? Icons.shield_rounded : Icons.verified_rounded,
                  size: 14,
                  color: isAdmin
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFF22C55E),
                ),
                const SizedBox(width: 6),
                Text(
                  isAdmin ? 'ADMIN' : 'STUDENT',
                  style: TextStyle(
                    color: isAdmin
                        ? const Color(0xFFFDE68A)
                        : const Color(0xFF86EFAC),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF111936),
        borderRadius: BorderRadius.circular(20),
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
      child: Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      icon,
                      size: 17,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 11,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 15,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFFCBD5E1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }

  void _confirmLogout(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    showDialog<void>(
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
          title: const Text(
            'Sign Out?',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out of Campus Exchange? You will need to sign in again with your email and roll number.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFCBD5E1),
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);

                await authProvider.logout();

                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.verification,
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(90, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
