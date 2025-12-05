import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/project_provider.dart';
import '../../theme/project_manager_theme.dart';
import '../../models/project.dart';
import 'add_feature_dialog.dart';
import 'add_research_dialog.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ProjectManagerTheme.darkTheme,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: ProjectManagerTheme.spaceGradient,
          ),
          child: Consumer<ProjectProvider>(
            builder: (context, provider, child) {
              final project = provider.projects.firstWhere(
                (p) => p.id == widget.projectId,
                orElse: () => throw Exception('Project not found'),
              );
              
              final features = provider.getFeaturesForProject(widget.projectId);
              final research = provider.getResearchForProject(widget.projectId);
              final timeline = provider.getTimelineForProject(widget.projectId);

              final color = Color(
                int.parse(project.themeColor.replaceFirst('#', '0xFF')),
              );

              return CustomScrollView(
                slivers: [
                  // App Bar with Project Info
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: ProjectManagerTheme.cosmicBlue,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        project.name,
                        style: ProjectManagerTheme.subtitleText,
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withOpacity(0.3),
                              ProjectManagerTheme.deepSpace,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (project.iconEmoji != null)
                              Text(project.iconEmoji!, style: const TextStyle(fontSize: 48)),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Project Stats
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: ProjectManagerTheme.cardGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.description,
                            style: ProjectManagerTheme.bodyText,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildInfoChip(
                                Icons.category_rounded,
                                project.projectType,
                                color,
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                Icons.circle,
                                project.status,
                                ProjectManagerTheme.getStatusColor(project.status),
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                Icons.flag_rounded,
                                'Priority ${project.priority}',
                                ProjectManagerTheme.yellowGlow,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: project.progressPercentage / 100,
                              backgroundColor: ProjectManagerTheme.nebulaBlue,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${project.completedFeatures}/${project.totalFeatures} Features',
                                style: ProjectManagerTheme.bodyText,
                              ),
                              Text(
                                '${project.progressPercentage.toStringAsFixed(1)}%',
                                style: ProjectManagerTheme.bodyText.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (project.techStack.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'TECH STACK',
                              style: ProjectManagerTheme.captionText.copyWith(
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: project.techStack.split(',').map((tech) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ProjectManagerTheme.cyanGlow.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: ProjectManagerTheme.cyanGlow.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    tech.trim(),
                                    style: ProjectManagerTheme.captionText.copyWith(
                                      color: ProjectManagerTheme.cyanGlow,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Tabs
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: ProjectManagerTheme.cosmicBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: color,
                        labelColor: color,
                        unselectedLabelColor: ProjectManagerTheme.textSecondary,
                        tabs: [
                          Tab(
                            icon: const Icon(Icons.list_rounded),
                            text: 'Features (${features.length})',
                          ),
                          Tab(
                            icon: const Icon(Icons.science_rounded),
                            text: 'Research (${research.length})',
                          ),
                          Tab(
                            icon: const Icon(Icons.timeline_rounded),
                            text: 'Timeline (${timeline.length})',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab Content
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildFeaturesTab(features, color),
                        _buildResearchTab(research, color),
                        _buildTimelineTab(timeline, color),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: ProjectManagerTheme.captionText.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesTab(List<ProjectFeature> features, Color color) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddFeatureDialog(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('ADD FEATURE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: ProjectManagerTheme.deepSpace,
            ),
          ),
        ),
        Expanded(
          child: features.isEmpty
              ? _buildEmptyState('No features yet', Icons.list_alt_rounded)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    final feature = features[index];
                    return _buildFeatureCard(feature, color);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(ProjectFeature feature, Color projectColor) {
    final statusColor = ProjectManagerTheme.getStatusColor(feature.status);
    
    return GestureDetector(
      onTap: () => _showEditFeatureStatusDialog(feature),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: ProjectManagerTheme.cardGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    feature.name,
                    style: ProjectManagerTheme.subtitleText.copyWith(fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    feature.status,
                    style: ProjectManagerTheme.captionText.copyWith(color: statusColor),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            feature.description,
            style: ProjectManagerTheme.bodyText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: projectColor),
              const SizedBox(width: 4),
              Text(
                feature.assignedTo,
                style: ProjectManagerTheme.captionText.copyWith(color: projectColor),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 14, color: ProjectManagerTheme.textTertiary),
              const SizedBox(width: 4),
              Text(
                '${feature.estimatedHours}h',
                style: ProjectManagerTheme.captionText,
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  void _showEditFeatureStatusDialog(ProjectFeature feature) {
    final statuses = ['To Do', 'In Progress', 'In Review', 'Completed', 'Blocked'];
    
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: ProjectManagerTheme.darkTheme,
        child: AlertDialog(
          backgroundColor: ProjectManagerTheme.cosmicBlue,
          title: Text(
            'Update Feature Status',
            style: ProjectManagerTheme.titleText,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.name,
                style: ProjectManagerTheme.subtitleText,
              ),
              const SizedBox(height: 16),
              Text(
                'Current Status: ${feature.status}',
                style: ProjectManagerTheme.bodyText,
              ),
              const SizedBox(height: 16),
              ...statuses.map((status) {
                final statusColor = ProjectManagerTheme.getStatusColor(status);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      if (status != feature.status) {
                        final updatedFeature = ProjectFeature(
                          id: feature.id,
                          projectId: feature.projectId,
                          name: feature.name,
                          description: feature.description,
                          status: status,
                          priority: feature.priority,
                          estimatedHours: feature.estimatedHours,
                          assignedTo: feature.assignedTo,
                          dependencies: feature.dependencies,
                          createdAt: feature.createdAt,
                        );
                        
                        Provider.of<ProjectProvider>(context, listen: false)
                            .updateFeature(updatedFeature);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor.withOpacity(0.2),
                      foregroundColor: statusColor,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(status),
                  ),
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResearchTab(List<ResearchNote> research, Color color) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddResearchDialog(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('ADD RESEARCH'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: ProjectManagerTheme.deepSpace,
            ),
          ),
        ),
        Expanded(
          child: research.isEmpty
              ? _buildEmptyState('No research yet', Icons.science_rounded)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: research.length,
                  itemBuilder: (context, index) {
                    final note = research[index];
                    return _buildResearchCard(note, color);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildResearchCard(ResearchNote note, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: ProjectManagerTheme.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: ProjectManagerTheme.subtitleText.copyWith(fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  note.category,
                  style: ProjectManagerTheme.captionText.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.content,
            style: ProjectManagerTheme.bodyText,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                note.authorName,
                style: ProjectManagerTheme.captionText.copyWith(color: color),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d, y').format(note.createdAt),
                style: ProjectManagerTheme.captionText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(List<ProjectTimeline> timeline, Color color) {
    if (timeline.isEmpty) {
      return _buildEmptyState('No timeline events', Icons.timeline_rounded);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: timeline.length,
      itemBuilder: (context, index) {
        final event = timeline[index];
        final isLast = index == timeline.length - 1;
        return _buildTimelineEvent(event, color, isLast);
      },
    );
  }

  Widget _buildTimelineEvent(ProjectTimeline event, Color color, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: color.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ProjectManagerTheme.cosmicBlue.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: ProjectManagerTheme.subtitleText.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: ProjectManagerTheme.bodyText.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      event.performedBy,
                      style: ProjectManagerTheme.captionText.copyWith(color: color),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d, HH:mm').format(event.timestamp),
                      style: ProjectManagerTheme.captionText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: ProjectManagerTheme.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: ProjectManagerTheme.bodyText,
          ),
        ],
      ),
    );
  }

  void _showAddFeatureDialog() {
    showDialog(
      context: context,
      builder: (context) => AddFeatureDialog(projectId: widget.projectId),
    );
  }

  void _showAddResearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AddResearchDialog(projectId: widget.projectId),
    );
  }
}
