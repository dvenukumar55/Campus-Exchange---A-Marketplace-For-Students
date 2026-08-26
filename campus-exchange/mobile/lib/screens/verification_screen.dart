import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _rollNumberController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _rollNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final email = _emailController.text.trim().toLowerCase();
    final rollNumber = _rollNumberController.text.trim().toUpperCase();

    final success = await authProvider.authenticate(
      email: email,
      rollNumber: rollNumber,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome to Campus Exchange!'),
          backgroundColor: Color(0xFF10B981),
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
            authProvider.errorMessage ?? 'Authentication failed',
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color iconColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 14,
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(
          left: 10,
          right: 8,
          top: 9,
          bottom: 9,
        ),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFF),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: iconColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFEF4444),
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFEF4444),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: Stack(
        children: [
          // TOP PURPLE / BLUE GRADIENT
          Container(
            height: 330,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6D28D9),
                  Color(0xFF4F46E5),
                  Color(0xFF2563EB),
                  Color(0xFF0891B2),
                ],
                stops: [0.0, 0.35, 0.70, 1.0],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(48),
                bottomRight: Radius.circular(48),
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),

          Positioned(
            top: 100,
            left: -80,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          Positioned(
            top: 220,
            right: 25,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFBBF24).withValues(alpha: 0.20),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                28,
                20,
                30,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // BRAND ICON
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 44,
                        color: Color(0xFF4F46E5),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Campus Exchange',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      'BUY  •  SELL  •  EXCHANGE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),

                    const SizedBox(height: 34),

                    // LOGIN CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        22,
                        25,
                        22,
                        22,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF312E81).withValues(alpha: 0.15),
                            blurRadius: 35,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome row
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFEEF2FF),
                                      Color(0xFFE0E7FF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.waving_hand_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 25,
                                ),
                              ),
                              const SizedBox(width: 13),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back!',
                                      style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Sign in to your campus marketplace',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // EMAIL LABEL
                          const Text(
                            'EMAIL ADDRESS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: Color(0xFF6B7280),
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hint: 'student@gmail.com',
                              icon: Icons.email_rounded,
                              iconColor: const Color(0xFF4F46E5),
                            ),
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
                          ),

                          const SizedBox(height: 21),

                          // ROLL NUMBER LABEL
                          const Text(
                            'ROLL NUMBER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: Color(0xFF6B7280),
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _rollNumberController,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            decoration: _inputDecoration(
                              hint: '23Q61A0530',
                              icon: Icons.badge_rounded,
                              iconColor: const Color(0xFF0891B2),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Roll number is required';
                              }

                              return null;
                            },
                            onFieldSubmitted: (_) {
                              if (!authProvider.isLoading) {
                                _handleLogin();
                              }
                            },
                          ),

                          const SizedBox(height: 27),

                          // GRADIENT BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7C3AED),
                                    Color(0xFF4F46E5),
                                    Color(0xFF2563EB),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(17),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4F46E5)
                                        .withValues(alpha: 0.30),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(17),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        width: 23,
                                        height: 23,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Continue',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 21,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // SECURITY MESSAGE
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFF0FDFA),
                                  Color(0xFFECFDF5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFFA7F3D0),
                              ),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.verified_user_rounded,
                                  size: 20,
                                  color: Color(0xFF059669),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Secure access • One roll number can have only one account.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF047857),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // BOTTOM FEATURES
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MiniFeature(
                          icon: Icons.shopping_bag_rounded,
                          color: Color(0xFF7C3AED),
                          label: 'Buy',
                        ),
                        SizedBox(width: 28),
                        _MiniFeature(
                          icon: Icons.sell_rounded,
                          color: Color(0xFF0891B2),
                          label: 'Sell',
                        ),
                        SizedBox(width: 28),
                        _MiniFeature(
                          icon: Icons.swap_horiz_rounded,
                          color: Color(0xFFF59E0B),
                          label: 'Exchange',
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'A safer marketplace built for students',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniFeature extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _MiniFeature({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 19,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
