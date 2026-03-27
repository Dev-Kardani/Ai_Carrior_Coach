import 'dart:ui';

import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/core/utils/error_handler.dart';
import 'package:ai_career_coach/core/utils/validators.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Login screen with premium Figma-inspired design
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabaseService = SupabaseService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    DebugLogger.info('AUTH_UI', 'LOGIN_BUTTON_CLICKED');
    if (!_formKey.currentState!.validate()) {
      DebugLogger.failed(
          'AUTH_UI', 'VALIDATION_FAILED', 'Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _supabaseService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        final profile = await _supabaseService.getUserProfile();

        if (mounted) {
          if (profile == null || !profile.onboardingCompleted) {
            DebugLogger.success('AUTH_UI', 'ROUTING', 'Navigating to setup');
            Navigator.of(context).pushReplacementNamed('/auth/setup');
          } else {
            DebugLogger.success('AUTH_UI', 'ROUTING', 'Navigating to app');
            Navigator.of(context).pushReplacementNamed('/app');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        DebugLogger.failed('AUTH_UI', 'LOGIN_FAILED', e.toString(), error: e);
        ErrorHandler.showError(context, ErrorHandler.formatError(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      body: Stack(
        children: [
          // Background Decoration (Skewed Indigo Box)
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            height: 400,
            child: Transform(
              transform: Matrix4.skewY(0.05)..translate(0.0, -24.0),
              child: Container(
                color: const Color(0xFF4F46E5), // Indigo 600
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.work_rounded,
                            size: 24,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Sign in to CareerAI',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Continue your journey to your dream job',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFE0E7FF), // Indigo 100
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 32),

                    // Login Card (Glassmorphism)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildFieldLabel('Email address'),
                                const SizedBox(height: 4),
                                _buildTextField(
                                  key: const ValueKey('login_email'),
                                  controller: _emailController,
                                  hint: 'you@example.com',
                                  icon: Icons.mail_outline_rounded,
                                  validator: Validators.validateEmail,
                                ),
                                const SizedBox(height: 24),
                                _buildFieldLabel('Password'),
                                const SizedBox(height: 4),
                                _buildTextField(
                                  key: const ValueKey('login_password'),
                                  controller: _passwordController,
                                  hint: '••••••••',
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  validator: Validators.validatePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                      color:
                                          const Color(0xFF94A3B8), // Slate 400
                                    ),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(
                                          () => _rememberMe = !_rememberMe),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() =>
                                                      _rememberMe = value);
                                                }
                                              },
                                              activeColor:
                                                  const Color(0xFF4F46E5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Remember me',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(
                                                  0xFF0F172A), // Slate 900
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () => Navigator.pushNamed(
                                          context, '/auth/forgot-password'),
                                      child: const Text(
                                        'Forgot your password?',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF4F46E5),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Login Button
                                SizedBox(
                                  height: 44,
                                  child: ElevatedButton(
                                    key: const ValueKey('login_button'),
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 16),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Sign in',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.arrow_forward_rounded,
                                                  size: 16),
                                            ],
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Divider
                                const Row(
                                  children: [
                                    Expanded(
                                        child:
                                            Divider(color: Color(0xFFE2E8F0))),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'New to CareerAI?',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF64748B), // Slate 500
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child:
                                            Divider(color: Color(0xFFE2E8F0))),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Signup Link
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, '/auth/signup'),
                                  child: const Text(
                                    'Create an account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF4F46E5),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF334155), // Slate 700
      ),
    );
  }

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        suffixIcon: suffixIcon,
        fillColor: Colors.white,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)), // Slate 300
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1),
        ),
      ),
    );
  }
}
