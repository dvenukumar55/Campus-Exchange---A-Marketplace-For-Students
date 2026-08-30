import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _rollNumberFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _rollNumberController = TextEditingController();

  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _rollNumberController.dispose();
    super.dispose();
  }

  void _startResendCountdown([int seconds = 60]) {
    _resendTimer?.cancel();
    setState(() {
      _resendCountdown = seconds;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 1) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _resendCountdown = 0;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _handleSendOtp() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim().toLowerCase();

    final success = await authProvider.requestOtp(email);

    if (!mounted) return;

    if (success) {
      _startResendCountdown(60);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification code sent to $email'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to send OTP code'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _handleResendOtp() async {
    if (_resendCountdown > 0) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim().toLowerCase();

    final success = await authProvider.requestOtp(email);

    if (!mounted) return;

    if (success) {
      _otpController.clear();
      _startResendCountdown(60);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new 6-digit code has been sent.'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to resend code'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final otp = _otpController.text.trim();

    final success = await authProvider.verifyOtp(otp);

    if (!mounted) return;

    if (success) {
      _resendTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified! Please enter your roll number.'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Invalid verification code'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _handleCompleteLogin() async {
    if (!_rollNumberFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rollNumber = _rollNumberController.text.trim().toUpperCase();

    final success = await authProvider.completeAuthentication(
      rollNumber: rollNumber,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome to Campus Exchange!'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.marketplace,
      );
    } else {
      if (authProvider.conflictMessage != null) {
        _showDeviceConflictDialog(authProvider.conflictMessage!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Authentication failed',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showDeviceConflictDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Row(
          children: [
            Icon(Icons.devices_rounded, color: AppTheme.warningColor, size: 24),
            SizedBox(width: 10),
            Text(
              'Account Already Signed In',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.royalBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Branded Icon
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F2744), Color(0xFF1E3A8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Campus Exchange',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),

                const SizedBox(height: 24),

                // Main Form Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.dividerColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildCurrentStage(authProvider),
                ),

                const SizedBox(height: 24),

                // Mini Features Row
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _VerificationFeatureItem(
                      icon: Icons.menu_book_rounded,
                      label: 'Academic Items',
                    ),
                    SizedBox(width: 24),
                    _VerificationFeatureItem(
                      icon: Icons.verified_user_rounded,
                      label: 'Peer Verified',
                    ),
                    SizedBox(width: 24),
                    _VerificationFeatureItem(
                      icon: Icons.handshake_rounded,
                      label: 'Safe Exchange',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStage(AuthProvider authProvider) {
    switch (authProvider.currentStep) {
      case AuthFlowStep.email:
        return _buildEmailStage(authProvider);
      case AuthFlowStep.otp:
        return _buildOtpStage(authProvider);
      case AuthFlowStep.rollNumber:
        return _buildRollNumberStage(authProvider);
    }
  }

  // STAGE 1: EMAIL ENTRY
  Widget _buildEmailStage(AuthProvider authProvider) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Official Email Address',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'e.g. student@gmail.com',
              hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: const Icon(Icons.email_outlined, size: 18, color: AppTheme.royalBlue),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email address is required';
              }
              final email = value.trim().toLowerCase();
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return 'Enter a valid email address';
              }
              return null;
            },
            onFieldSubmitted: (_) {
              if (!authProvider.isLoading) {
                _handleSendOtp();
              }
            },
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.glowButtonShadow,
            ),
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleSendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Send Verification OTP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // STAGE 2: OTP VERIFICATION
  Widget _buildOtpStage(AuthProvider authProvider) {
    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verification Code',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 8,
              color: AppTheme.royalBlue,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '••••••',
              hintStyle: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 20,
                letterSpacing: 8,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: const Icon(Icons.security_rounded, size: 18, color: AppTheme.royalBlue),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            validator: (value) {
              if (value == null || value.trim().length != 6) {
                return 'Enter the 6-digit OTP';
              }
              return null;
            },
            onFieldSubmitted: (_) {
              if (!authProvider.isLoading) {
                _handleVerifyOtp();
              }
            },
          ),

          const SizedBox(height: 12),

          // Resend Code and Change Email actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  authProvider.resetFlow();
                },
                icon: const Icon(Icons.arrow_back, size: 14, color: AppTheme.textSecondary),
                label: const Text(
                  'Change Email',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: _resendCountdown > 0 || authProvider.isLoading
                    ? null
                    : _handleResendOtp,
                child: Text(
                  _resendCountdown > 0
                      ? 'Resend in ${_resendCountdown}s'
                      : 'Resend OTP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _resendCountdown > 0 ? AppTheme.textMuted : AppTheme.royalBlue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.glowButtonShadow,
            ),
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleVerifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Verify OTP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // STAGE 3: ROLL NUMBER ENTRY
  Widget _buildRollNumberStage(AuthProvider authProvider) {
    return Form(
      key: _rollNumberFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email verified pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.royalBlue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _emailController.text.trim().toLowerCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A8A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'College Roll Number',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _rollNumberController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Enter your roll number',
              hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: const Icon(Icons.badge_outlined, size: 18, color: AppTheme.royalBlue),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Roll number is required';
              }
              return null;
            },
            onFieldSubmitted: (_) {
              if (!authProvider.isLoading) {
                _handleCompleteLogin();
              }
            },
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.glowButtonShadow,
            ),
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleCompleteLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationFeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _VerificationFeatureItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppTheme.royalBlue),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
