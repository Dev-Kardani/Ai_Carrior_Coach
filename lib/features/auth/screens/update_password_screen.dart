import 'dart:ui';

import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/core/utils/error_handler.dart';
import 'package:ai_career_coach/core/utils/validators.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Screen for updating the user's password after recovery redirect
class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _supabaseService = SupabaseService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    DebugLogger.info('AUTH_UI', 'UPDATE_PASSWORD_BUTTON_CLICKED');
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ErrorHandler.showError(context, 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _supabaseService.updatePassword(_passwordController.text);

      if (mounted) {
        DebugLogger.success(
            'AUTH_UI', 'PASSWORD_UPDATED', 'Successfully updated');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
        Navigator.of(context).pushReplacementNamed('/auth/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        DebugLogger.failed('AUTH_UI', 'UPDATE_PASSWORD_FAILED', e.toString());
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
          // Background Decoration
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
                    // Header Section
                    Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            size: 28,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Update Password',
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
                          'Set a strong password to secure your account',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFE0E7FF), // Indigo 100
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 32),

                    // Update Card
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
                                _buildFieldLabel('New Password'),
                                const SizedBox(height: 4),
                                _buildTextField(
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
                                      color: const Color(0xFF94A3B8),
                                    ),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildFieldLabel('Confirm Password'),
                                const SizedBox(height: 4),
                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  hint: '••••••••',
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  validator: (v) => v!.isEmpty
                                      ? 'Please confirm password'
                                      : null,
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _handleUpdatePassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
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
                                        : const Text(
                                            'Update Password',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
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
        color: Color(0xFF334155),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
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
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1),
        ),
      ),
    );
  }
}
