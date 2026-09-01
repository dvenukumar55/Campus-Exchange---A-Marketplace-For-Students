import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

    _resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
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
      },
    );
  }

  // ============================================================
  // STEP 1 - SEND OTP
  // ============================================================

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
          content: Text(
            'Verification code sent to $email',
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      _showError(
        authProvider.errorMessage ?? 'Failed to send OTP code',
      );
    }
  }

  // ============================================================
  // RESEND OTP
  // ============================================================

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
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _showError(
        authProvider.errorMessage ?? 'Failed to resend code',
      );
    }
  }

  // ============================================================
  // STEP 2 - VERIFY OTP
  // ============================================================

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
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _showError(
        authProvider.errorMessage ?? 'Invalid verification code',
      );
    }
  }

  // ============================================================
  // STEP 3 - COMPLETE LOGIN
  // ============================================================

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
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.marketplace,
      );
    } else {
      if (authProvider.conflictMessage != null) {
        _showDeviceConflictDialog(
          authProvider.conflictMessage!,
        );
      } else {
        _showError(
          authProvider.errorMessage ?? 'Authentication failed',
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE11D48),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // DEVICE CONFLICT
  // ============================================================

  void _showDeviceConflictDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111936),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.devices_rounded,
                color: Color(0xFFFBBF24),
                size: 24,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Account Already Signed In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF60A5FA),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1128),
      body: Stack(
        children: [
          Positioned(
            top: -130,
            right: -100,
            child: _glowCircle(
              300,
              const Color(0xFF4338CA),
              0.18,
            ),
          ),
          Positioned(
            bottom: -150,
            left: -120,
            child: _glowCircle(
              320,
              const Color(0xFF2563EB),
              0.12,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                22,
                30,
                22,
                28,
              ),
              child: Column(
                children: [
                  _buildBrandHeader(),
                  const SizedBox(height: 28),
                  _buildMainCard(authProvider),
                  const SizedBox(height: 20),
                  _buildSecurityFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(
    double size,
    Color color,
    double opacity,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }

  // ============================================================
  // BRAND HEADER
  // ============================================================

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF38BDF8),
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.30),
                blurRadius: 28,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF111936),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        ),
        const SizedBox(height: 17),
        const Text(
          'Campus Exchange',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Buy • Sell • Connect',
          style: TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_rounded,
                size: 15,
                color: Color(0xFF38BDF8),
              ),
              SizedBox(width: 7),
              Text(
                'Verified Student Marketplace',
                style: TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MAIN CARD
  // ============================================================

  Widget _buildMainCard(AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111936),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: _buildCurrentStage(authProvider),
    );
  }

  // ============================================================
  // CURRENT AUTH STAGE
  // ============================================================

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

  // ============================================================
  // EMAIL STAGE
  // ============================================================

  Widget _buildEmailStage(AuthProvider authProvider) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your official college email to continue.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          _fieldLabel(
            'OFFICIAL EMAIL',
            Icons.email_rounded,
          ),
          const SizedBox(height: 8),
          _darkTextField(
            controller: _emailController,
            hint: 'Enter Your Mail',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email address is required';
              }

              final email = value.trim().toLowerCase();

              if (!RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              ).hasMatch(email)) {
                return 'Enter a valid email address';
              }

              return null;
            },
            onSubmitted: (_) {
              if (!authProvider.isLoading) {
                _handleSendOtp();
              }
            },
          ),
          const SizedBox(height: 22),
          _gradientButton(
            label: 'Send Verification OTP',
            loading: authProvider.isLoading,
            onPressed: _handleSendOtp,
          ),
          const SizedBox(height: 16),
          _infoText(
            Icons.shield_rounded,
            'Only verified campus members can access the marketplace.',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OTP STAGE
  // ============================================================

  Widget _buildOtpStage(AuthProvider authProvider) {
    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verify your email',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter the 6-digit verification code sent to your email.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1228),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.mark_email_read_rounded,
                  color: Color(0xFF38BDF8),
                  size: 18,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    _emailController.text.trim().toLowerCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _fieldLabel(
            '6-DIGIT OTP',
            Icons.lock_rounded,
          ),
          const SizedBox(height: 8),
          _darkTextField(
            controller: _otpController,
            hint: '••••••',
            icon: Icons.security_rounded,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF60A5FA),
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: 7,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (value) {
              if (value == null || value.trim().length != 6) {
                return 'Enter the 6-digit OTP';
              }

              return null;
            },
            onSubmitted: (_) {
              if (!authProvider.isLoading) {
                _handleVerifyOtp();
              }
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  authProvider.resetFlow();
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 15,
                  color: Color(0xFF94A3B8),
                ),
                label: const Text(
                  'Change Email',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
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
                    color: _resendCountdown > 0
                        ? const Color(0xFF64748B)
                        : const Color(0xFF60A5FA),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _gradientButton(
            label: 'Verify OTP',
            loading: authProvider.isLoading,
            onPressed: _handleVerifyOtp,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ROLL NUMBER STAGE
  // ============================================================

  Widget _buildRollNumberStage(AuthProvider authProvider) {
    return Form(
      key: _rollNumberFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Almost there!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your college roll number to complete verification.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1228),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF22C55E),
                  size: 18,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    _emailController.text.trim().toLowerCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _fieldLabel(
            'COLLEGE ROLL NUMBER',
            Icons.badge_rounded,
          ),
          const SizedBox(height: 8),
          _darkTextField(
            controller: _rollNumberController,
            hint: 'Enter Your Roll No',
            icon: Icons.badge_outlined,
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Roll number is required';
              }

              return null;
            },
            onSubmitted: (_) {
              if (!authProvider.isLoading) {
                _handleCompleteLogin();
              }
            },
          ),
          const SizedBox(height: 22),
          _gradientButton(
            label: 'Continue to Campus Exchange',
            loading: authProvider.isLoading,
            onPressed: _handleCompleteLogin,
          ),
          const SizedBox(height: 16),
          _infoText(
            Icons.verified_user_rounded,
            'Your account is protected by verified campus authentication.',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIELD LABEL
  // ============================================================

  Widget _fieldLabel(
    String label,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFF60A5FA),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DARK TEXT FIELD
  // ============================================================

  Widget _darkTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextAlign textAlign = TextAlign.start,
    TextStyle? style,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textAlign: textAlign,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      style: style ??
          const TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
      cursorColor: const Color(0xFF60A5FA),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12.5,
        ),
        filled: true,
        fillColor: const Color(0xFF0B1228),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF60A5FA),
          size: 19,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Color(0xFF6366F1),
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Color(0xFFE11D48),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Color(0xFFE11D48),
            width: 1.3,
          ),
        ),
      ),
      validator: validator,
      onFieldSubmitted: onSubmitted,
    );
  }

  // ============================================================
  // GRADIENT BUTTON
  // ============================================================

  Widget _gradientButton({
    required String label,
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2563EB),
              Color(0xFF6366F1),
              Color(0xFF7C3AED),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ============================================================
  // INFO TEXT
  // ============================================================

  Widget _infoText(
    IconData icon,
    String text,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF38BDF8),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10.5,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECURITY FOOTER
  // ============================================================

  Widget _buildSecurityFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_rounded,
            size: 18,
            color: Color(0xFF38BDF8),
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'SECURE • VERIFIED • CAMPUS ONLY\n'
              'Your account is protected by campus verification.',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
