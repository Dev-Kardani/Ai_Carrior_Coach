import 'dart:ui';

import 'package:ai_career_coach/core/utils/error_handler.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _supabaseService = SupabaseService();
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _targetRoleController = TextEditingController();
  final _bioController = TextEditingController();
  final _yearsExpController = TextEditingController(text: '0');
  final _careerGoalsController = TextEditingController();
  final _countriesController = TextEditingController();

  String _experienceLevel = 'Entry Level';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.text =
        _supabaseService.currentUser?.userMetadata?['full_name'] ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _targetRoleController.dispose();
    _bioController.dispose();
    _yearsExpController.dispose();
    _careerGoalsController.dispose();
    _countriesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final countries = _countriesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await _supabaseService.updateUserProfile(
        fullName: _fullNameController.text.trim(),
        targetRole: _targetRoleController.text.trim(),
        experienceLevel: _experienceLevel,
        yearsExperience: int.tryParse(_yearsExpController.text) ?? 0,
        bio: _bioController.text.trim(),
        careerGoals: _careerGoalsController.text.trim(),
        preferredCountries: countries,
        onboardingCompleted: true,
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/app');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, ErrorHandler.formatError(e));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
              transform: Matrix4.skewY(0.05)
                ..setTranslationRaw(0.0, -24.0, 0.0),
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
                    // Setup Card (Glassmorphism)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 672),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
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
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Let's set up your profile",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A), // Slate 900
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Help us personalize your career journey",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B), // Slate 500
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Grid for Role and Location
                                    LayoutBuilder(
                                        builder: (context, constraints) {
                                      final isSmall =
                                          constraints.maxWidth < 450;
                                      final children = [
                                        Expanded(
                                          flex: isSmall ? 0 : 1,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildFieldLabel('Target Role'),
                                              const SizedBox(height: 4),
                                              _buildTextField(
                                                key: const ValueKey(
                                                    'setup_target_role'),
                                                controller:
                                                    _targetRoleController,
                                                hint: 'e.g. Product Designer',
                                                icon:
                                                    Icons.work_outline_rounded,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                            width: isSmall ? 0 : 16,
                                            height: isSmall ? 16 : 0),
                                        Expanded(
                                          flex: isSmall ? 0 : 1,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildFieldLabel(
                                                  'Preferred Location'),
                                              const SizedBox(height: 4),
                                              _buildTextField(
                                                controller:
                                                    _countriesController,
                                                hint: 'e.g. Remote, NY',
                                                icon: Icons.map_outlined,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ];

                                      if (isSmall) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: children,
                                        );
                                      }

                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: children,
                                      );
                                    }),
                                    const SizedBox(height: 24),

                                    _buildFieldLabel('Experience Level'),
                                    const SizedBox(height: 8),
                                    _buildExperienceSelector(),
                                    const SizedBox(height: 24),

                                    _buildFieldLabel(
                                        'What are your goals? (Select all that apply)'),
                                    const SizedBox(height: 8),
                                    _buildGoalSelector(),
                                    const SizedBox(height: 32),

                                    const Divider(
                                        color: Color(0xFFF1F5F9)), // Slate 100
                                    const SizedBox(height: 16),

                                    // Action Button
                                    SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        key: const ValueKey(
                                            'setup_complete_button'),
                                        onPressed:
                                            _isSaving ? null : _saveProfile,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF4F46E5),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _isSaving
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(
                                                'Complete Setup',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
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
    String? Function(String?)? validator,
    int? maxLines,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
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
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1),
        ),
      ),
    );
  }

  Widget _buildExperienceSelector() {
    final levels = ['Entry Level', 'Mid Level', 'Senior Level'];
    return Row(
      children: levels.map((level) {
        final isSelected = _experienceLevel == level;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: level == levels.last ? 0 : 12),
            child: InkWell(
              onTap: () => setState(() => _experienceLevel = level),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 1 : 1, // tailwind 'ring-1' is 1px
                  ),
                ),
                child: Text(
                  level,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF4338CA)
                        : const Color(0xFF334155),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalSelector() {
    final goalsList = [
      "Find a new job",
      "Switch careers",
      "Improve resume",
      "Practice interviewing",
      "Networking"
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: goalsList.map((goal) {
        // Simple logic for toggle since we use controller to store string for now
        final isSelected = _careerGoalsController.text.contains(goal);
        return InkWell(
          onTap: () {
            setState(() {
              List<String> current = _careerGoalsController.text.isNotEmpty
                  ? _careerGoalsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList()
                  : [];
              if (current.contains(goal)) {
                current.remove(goal);
              } else {
                current.add(goal);
              }
              _careerGoalsController.text = current.join(', ');
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  goal,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF4338CA)
                        : const Color(0xFF334155),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_rounded,
                      size: 16, color: Color(0xFF4F46E5)),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
