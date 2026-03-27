import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/models/job_application_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class JobBoardScreen extends StatelessWidget {
  final List<JobApplicationModel> jobs;
  final bool isLoading;
  final Function(JobApplicationModel, String) onUpdateStatus;
  final Function(JobApplicationModel) onShowDetails;
  final Function(JobApplicationModel) onDelete;

  const JobBoardScreen({
    super.key,
    required this.jobs,
    required this.isLoading,
    required this.onUpdateStatus,
    required this.onShowDetails,
    required this.onDelete,
  });

  static const List<String> _statuses = [
    'Wishlist',
    'Applied',
    'Interview',
    'Offer',
    'Rejected',
  ];

  static const Map<String, Color> _columnTopBorder = {
    'Wishlist': Color(0xFFCBD5E1),
    'Applied': Color(0xFF93C5FD),
    'Interview': Color(0xFFFDE047),
    'Offer': Color(0xFF86EFAC),
    'Rejected': Color(0xFFFCA5A5),
  };

  static const Map<String, Color> _columnBg = {
    'Wishlist': Color(0xFFF8FAFC),
    'Applied': Color(0xFFEFF6FF),
    'Interview': Color(0xFFFEFCE8),
    'Offer': Color(0xFFF0FDF4),
    'Rejected': Color(0xFFFEF2F2),
  };

  static const Map<String, Color> _dotColor = {
    'Wishlist': Color(0xFF94A3B8),
    'Applied': Color(0xFF3B82F6),
    'Interview': Color(0xFFEAB308),
    'Offer': Color(0xFF22C55E),
    'Rejected': Color(0xFFEF4444),
  };

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 768;

      if (isWide) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _statuses
                .map((status) => _buildKanbanColumn(context, status, isWide))
                .toList(),
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: _statuses
            .map((status) => _buildKanbanColumn(context, status, isWide))
            .toList(),
      );
    });
  }

  Widget _buildKanbanColumn(BuildContext context, String status, bool isWide) {
    final statusJobs = jobs.where((j) => j.status == status).toList();
    final topColor = _columnTopBorder[status]!;
    final bg = _columnBg[status]!;
    final dot = _dotColor[status]!;

    final content = Container(
      decoration: BoxDecoration(
        color: bg.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        border: Border.all(color: AppColors.slate200),
      ),
      child: ListView(
        shrinkWrap: !isWide,
        physics: isWide ? null : const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ...statusJobs
              .asMap()
              .entries
              .map((e) => _buildJobCard(context, e.value, e.key)),
          if (statusJobs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No jobs in this stage',
                    style: TextStyle(fontSize: 12, color: AppColors.slate400)),
              ),
            ),
        ],
      ),
    );

    return Container(
      width: isWide ? 280 : double.infinity,
      margin: EdgeInsets.only(right: isWide ? 16 : 0, bottom: isWide ? 0 : 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              border: Border(top: BorderSide(color: topColor, width: 4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(status,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.slate700)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${statusJobs.length}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.slate400,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),

          // Column body
          if (isWide) Expanded(child: content) else content,
        ],
      ),
    );
  }

  Widget _buildJobCard(
      BuildContext context, JobApplicationModel job, int index) {
    return GestureDetector(
      onTap: () {
        DebugLogger.info('JOB_BOARD_UI', 'JOB_CARD_CLICKED',
            'Viewing details for ${job.companyName}');
        onShowDetails(job);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.slate100),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.business_rounded,
                      size: 16, color: AppColors.slate500),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.companyName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.slate900),
                          overflow: TextOverflow.ellipsis),
                      Text(job.roleTitle,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.slate500),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 16, color: AppColors.slate300),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 12, color: AppColors.slate400),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location ?? 'Remote',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.slate400),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today_rounded,
                    size: 10, color: AppColors.slate400),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd').format(job.appliedAt),
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.slate400),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      size: 16, color: AppColors.slate300),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tooltip: 'Update Status',
                  onSelected: (val) async {
                    if (val == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text('Delete?',
                              style: TextStyle(color: AppColors.slate900)),
                          content: const Text('Remove this application?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete',
                                    style: TextStyle(color: AppColors.error))),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        onDelete(job);
                      }
                      return;
                    }
                    DebugLogger.info('JOB_BOARD_UI', 'STATUS_UPDATE_CLICKED',
                        'Updating status to $val for ${job.companyName}');
                    onUpdateStatus(job, val);
                  },
                  itemBuilder: (context) => [
                    ..._statuses.map((s) => PopupMenuItem(
                        value: s,
                        child: Text(s,
                            style: const TextStyle(
                                color: AppColors.slate900, fontSize: 14)))),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete',
                          style:
                              TextStyle(color: AppColors.error, fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(job.salaryRange ?? 'Not specified',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, end: 0, duration: 300.ms);
  }
}
