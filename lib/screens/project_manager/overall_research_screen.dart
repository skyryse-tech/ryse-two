import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../theme/project_manager_theme.dart';
import 'add_research_dialog.dart';

class OverallResearchScreen extends StatelessWidget {
  const OverallResearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ProjectManagerTheme.darkTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Overall Research'),
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: ProjectManagerTheme.spaceGradient,
          ),
          child: SafeArea(
            child: Consumer<ProjectProvider>(
              builder: (context, provider, child) {
                final notes = provider.overallResearch;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Company-wide research and discoveries',
                              style: ProjectManagerTheme.bodyText.copyWith(
                                color: ProjectManagerTheme.textPrimary,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAdd(context),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ProjectManagerTheme.mintGlow,
                              foregroundColor: ProjectManagerTheme.deepSpace,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: notes.isEmpty
                          ? Center(
                              child: Text(
                                'No overall research yet. Add your first insight.',
                                style: ProjectManagerTheme.bodyText,
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: notes.length,
                              itemBuilder: (context, index) {
                                final note = notes[index];
                                final dateLabel = _formatDate(note.createdAt);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: ProjectManagerTheme.cardGradient,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: ProjectManagerTheme.mintGlow.withOpacity(0.25),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note.title,
                                        style: ProjectManagerTheme.subtitleText.copyWith(fontSize: 16),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                            dateLabel,
                                            style: ProjectManagerTheme.captionText.copyWith(
                                              color: ProjectManagerTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            note.authorName,
                                            style: ProjectManagerTheme.captionText.copyWith(
                                              color: ProjectManagerTheme.mintGlow,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        note.content,
                                        style: ProjectManagerTheme.bodyText,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showAdd(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddResearchDialog(projectId: 'overall'),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }
}
