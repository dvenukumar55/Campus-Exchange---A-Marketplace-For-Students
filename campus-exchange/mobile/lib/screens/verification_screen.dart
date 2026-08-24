import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_text_field.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController(
    text: 'kittud0005@gmail.com',
  );

  final _codeController = TextEditingController();

  bool _codeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerification() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final email = _emailController.text.trim();

    // Step 1: Send OTP
    if (!_codeSent) {
      final sent = await authProvider.sendVerificationCode(email);

      if (!mounted) return;

      if (sent) {
        setState(() {
          _codeSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Verification code sent. Check your email.',
            ),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ??
                  'Failed to send verification code',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }

      return;
    }

    // Step 2: Verify OTP
    final success = await authProvider.verifyOfficialEmail(
      email,
      verificationCode: _codeController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification successful! Welcome to Campus Exchange.',
          ),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.marketplace,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Verification failed',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Campus Pilot Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'AVIH Closed Campus Pilot',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Student Verification',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Campus Exchange is restricted to verified students. '
                    'Enter your email address to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Email Input
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'e.g. kittud0005@gmail.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email address is required';
                      }

                      final email = val.trim().toLowerCase();

                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(email)) {
                        return 'Enter a valid email address';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // OTP Input
                  if (_codeSent) ...[
                    CustomTextField(
                      controller: _codeController,
                      label: 'Verification Code',
                      hint: 'Enter 6-digit code',
                      prefixIcon: Icons.lock_outline,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Verification code is required';
                        }

                        if (!RegExp(
                          r'^\d{6}$',
                        ).hasMatch(val.trim())) {
                          return 'Enter the 6-digit verification code';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                  ],

                  // Send / Verify Button
                  ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : _handleVerification,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _codeSent
                                ? 'Complete Verification'
                                : 'Send Verification Code',
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Trust & Privacy Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(
                          Icons.shield_outlined,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your student data is strictly isolated within '
                            'Avanthi Institute. Public marketplace access '
                            'and cross-college visibility are prohibited.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
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
}