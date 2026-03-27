import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/features/tracker/screens/job_board_screen.dart';
import 'package:ai_career_coach/models/job_application_model.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';

class JobTrackerScreen extends StatefulWidget {
  const JobTrackerScreen({super.key});

  @override
  State<JobTrackerScreen> createState() => _JobTrackerScreenState();
}

class _JobTrackerScreenState extends State<JobTrackerScreen> {
  final _supabaseService = SupabaseService();

  List<JobApplicationModel> _jobs = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    DebugLogger.info('JOB_TRACKER', 'FETCH_JOBS', 'Loading job applications');
    try {
      final jobs = await _supabaseService.getJobApplications();
      if (mounted) {
        DebugLogger.success('JOB_TRACKER', 'FETCH_JOBS',
            'Successfully loaded ${jobs.length} applications');
        for (var job in jobs) {
          DebugLogger.info('JOB_TRACKER', 'DEBUG',
              'Job ID: ${job.id}, Company: ${job.companyName}, UserID: ${job.userId}');
        }
        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      }
    } catch (e) {
      DebugLogger.failed('JOB_TRACKER', 'FETCH_JOBS', e.toString(), error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showAddJobDialog() async {
    DebugLogger.info('JOB_TRACKER_UI', 'ADD_JOB_CLICKED');
    final result = await Navigator.of(context, rootNavigator: true).pushNamed(
      '/app/jobs/new',
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _showJobDetails(JobApplicationModel job) async {
    final result = await Navigator.of(context, rootNavigator: true).pushNamed(
      '/app/jobs/${job.id}',
      arguments: job,
    );
    if (result == true) {
      _loadData(); // Reload if deleted/edited
    }
  }

  Future<void> _updateStatus(JobApplicationModel job, String newStatus) async {
    await _supabaseService.updateJobApplicationStatus(job.id, newStatus);
    _loadData();
  }

  Future<void> _deleteJob(JobApplicationModel job) async {
    setState(() => _isLoading = true);
    try {
      await _supabaseService.deleteJobApplication(job.id);
      DebugLogger.success(
          'JOB_TRACKER', 'DELETE_JOB', 'Deleted ${job.companyName}');
      _loadData();
    } catch (e) {
      DebugLogger.failed('JOB_TRACKER', 'DELETE_JOB', e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  List<JobApplicationModel> get _filteredJobs {
    if (_searchQuery.isEmpty) return _jobs;
    return _jobs.where((j) {
      return j.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          j.roleTitle.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Job Tracker',
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width > 768
                                  ? 24
                                  : 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900)),
                      if (MediaQuery.of(context).size.width > 768) ...[
                        const SizedBox(height: 4),
                        const Text(
                            'Track your applications through every stage.',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.slate500)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: ElevatedButton.icon(
                    key: const Key('add_job_button'),
                    onPressed: _showAddJobDialog,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(
                        MediaQuery.of(context).size.width > 768
                            ? 'Add Application'
                            : 'Add',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: AppColors.slate900, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search jobs by company or title...',
                  hintStyle: TextStyle(color: AppColors.slate400, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.slate400, size: 18),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled:
                      false, // Explicitly disable fill to avoid theme conflicts
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Kanban Board
          Expanded(
            child: JobBoardScreen(
              jobs: _filteredJobs,
              isLoading: _isLoading,
              onUpdateStatus: _updateStatus,
              onShowDetails: _showJobDetails,
              onDelete: _deleteJob,
            ),
          ),
        ],
      ),
    );
  }
}
