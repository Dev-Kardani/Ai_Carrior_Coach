import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/core/utils/error_handler.dart';
import 'package:ai_career_coach/models/job_application_model.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';

class JobEntryScreen extends StatefulWidget {
  final JobApplicationModel? job;
  const JobEntryScreen({super.key, this.job});

  @override
  State<JobEntryScreen> createState() => _JobEntryScreenState();
}

class _JobEntryScreenState extends State<JobEntryScreen> {
  final _supabaseService = SupabaseService();
  late final TextEditingController companyController;
  late final TextEditingController roleController;
  late final TextEditingController urlController;
  late final TextEditingController notesController;
  late final TextEditingController locationController;
  late final TextEditingController salaryController;

  late String selectedStatus;
  bool isSaving = false;

  final List<String> _statuses = [
    'Wishlist',
    'Applied',
    'Interview',
    'Offer',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    companyController =
        TextEditingController(text: widget.job?.companyName ?? '');
    roleController = TextEditingController(text: widget.job?.roleTitle ?? '');
    urlController = TextEditingController(text: widget.job?.jobUrl ?? '');
    notesController = TextEditingController(text: widget.job?.notes ?? '');
    locationController =
        TextEditingController(text: widget.job?.location ?? '');
    salaryController =
        TextEditingController(text: widget.job?.salaryRange ?? '');
    selectedStatus = widget.job?.status ?? 'Wishlist';
  }

  @override
  void dispose() {
    companyController.dispose();
    roleController.dispose();
    urlController.dispose();
    notesController.dispose();
    locationController.dispose();
    salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.job != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.slate600),
          onPressed: () {
            DebugLogger.info('JOB_ENTRY_UI', 'ROUTING', 'Closed entry screen');
            Navigator.pop(context);
          },
        ),
        title: Text(isEditing ? 'Edit Job' : 'Add New Job',
            style: const TextStyle(
                color: AppColors.slate900, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  LayoutBuilder(builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 450;
                    final children = [
                      Expanded(
                        flex: isSmall ? 0 : 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('Company Name'),
                            _buildFormTextField(
                                companyController,
                                'e.g. Google',
                                Icons.business_rounded,
                                const ValueKey('job_company_field')),
                          ],
                        ),
                      ),
                      SizedBox(
                          width: isSmall ? 0 : 16, height: isSmall ? 16 : 0),
                      Expanded(
                        flex: isSmall ? 0 : 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('Job Title'),
                            _buildFormTextField(
                                roleController,
                                'e.g. Senior Designer',
                                Icons.work_outline_rounded,
                                const ValueKey('job_role_field')),
                          ],
                        ),
                      ),
                    ];

                    if (isSmall) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    );
                  }),
                  const SizedBox(height: 16),
                  LayoutBuilder(builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 450;
                    final children = [
                      Expanded(
                        flex: isSmall ? 0 : 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('Location'),
                            _buildFormTextField(
                                locationController,
                                'e.g. Remote',
                                Icons.location_on_outlined,
                                const ValueKey('job_location_field')),
                          ],
                        ),
                      ),
                      SizedBox(
                          width: isSmall ? 0 : 16, height: isSmall ? 16 : 0),
                      Expanded(
                        flex: isSmall ? 0 : 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('Salary'),
                            _buildFormTextField(
                                salaryController,
                                'e.g. \$120k',
                                Icons.attach_money_rounded,
                                const ValueKey('job_salary_field')),
                          ],
                        ),
                      ),
                    ];

                    if (isSmall) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      );
                    }
                    return Row(
                      children: children,
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildFormLabel('Job Posting URL'),
                  _buildFormTextField(urlController, 'https://...',
                      Icons.link_rounded, const ValueKey('job_url_field')),
                  const SizedBox(height: 16),
                  _buildFormLabel('Application Status'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slate300),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedStatus,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.slate400),
                        style: const TextStyle(
                            color: AppColors.slate900, fontSize: 14),
                        items: _statuses
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedStatus = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFormLabel('Notes'),
                  TextField(
                    key: const ValueKey('job_notes_field'),
                    controller: notesController,
                    maxLines: 4,
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText:
                          'Any notes about the role, company culture, etc.',
                      hintStyle: const TextStyle(
                          color: AppColors.slate400, fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.slate300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.slate300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              DebugLogger.info(
                                  'JOB_ENTRY_UI', 'SAVE_JOB_CLICKED');
                              if (companyController.text.isEmpty ||
                                  roleController.text.isEmpty) {
                                DebugLogger.warning(
                                    'JOB_ENTRY',
                                    'VALIDATION_FAILED',
                                    'Company name and Role are required');
                                return;
                              }
                              setState(() => isSaving = true);

                              final navigator = Navigator.of(context);

                              try {
                                if (isEditing) {
                                  DebugLogger.info('JOB_ENTRY', 'UPDATE_JOB',
                                      'Updating job ${widget.job!.id}');
                                  await _supabaseService.updateJobApplication(
                                    id: widget.job!.id,
                                    companyName: companyController.text,
                                    roleTitle: roleController.text,
                                    status: selectedStatus,
                                    location: locationController.text,
                                    salaryRange: salaryController.text,
                                    jobUrl: urlController.text,
                                    notes: notesController.text,
                                  );
                                  DebugLogger.success('JOB_ENTRY', 'UPDATE_JOB',
                                      'Job updated successfully');
                                } else {
                                  DebugLogger.info('JOB_ENTRY', 'CREATE_JOB',
                                      'Creating new job entry for ${companyController.text}');
                                  await _supabaseService.addJobApplication(
                                    companyName: companyController.text,
                                    roleTitle: roleController.text,
                                    status: selectedStatus,
                                    location: locationController.text,
                                    salaryRange: salaryController.text,
                                    jobUrl: urlController.text,
                                    notes: notesController.text,
                                  );
                                  DebugLogger.success('JOB_ENTRY', 'CREATE_JOB',
                                      'New job created successfully');
                                }
                                if (!mounted) return;
                                navigator.pop(true);
                              } catch (e) {
                                DebugLogger.failed(
                                    'JOB_ENTRY',
                                    isEditing ? 'UPDATE_JOB' : 'CREATE_JOB',
                                    e.toString(),
                                    error: e);
                                if (!context.mounted) return;
                                ErrorHandler.showError(
                                    context, ErrorHandler.formatError(e));
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Save Job',
                              key: ValueKey('job_save_button'),
                              style: TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.slate700)),
    );
  }

  Widget _buildFormTextField(
      TextEditingController controller, String hint, IconData icon,
      [Key? key]) {
    return TextField(
      key: key,
      controller: controller,
      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.slate400, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
