import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../theme/project_manager_theme.dart';
import '../../models/project.dart';
import 'futuristic_page_route.dart';
import 'project_details_screen.dart';
import 'add_project_dialog.dart';

class ProjectListScreen extends StatefulWidget {
  final String? initialProjectId;
  
  const ProjectListScreen({super.key, this.initialProjectId});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    if (widget.initialProjectId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          FuturisticPageRoute(
            builder: (context) => ProjectDetailsScreen(projectId: widget.initialProjectId!),
          ),
        );
      });
    }
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
          child: SafeArea(
            child: Consumer<ProjectProvider>(
              builder: (context, provider, child) {
                final filtered = _filteredProjects(provider.projects);

                return CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      pinned: true,
                      expandedHeight: 120,
                      flexibleSpace: FlexibleSpaceBar(
                        title: const Text(
                          'ALL PROJECTS',
                          style: ProjectManagerTheme.titleText,
                        ),
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: ProjectManagerTheme.spaceGradient.scale(0.8),
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () => _showAddDialog(context),
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),

                    // Filter Tabs
                    SliverToBoxAdapter(
                      child: _buildFilterTabs(context, provider),
                    ),

                    // Project List
                    filtered.isEmpty
                        ? SliverFillRemaining(
                            child: _buildEmptyState(context),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final project = filtered[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildProjectCard(context, project),
                                  );
                                },
                                childCount: filtered.length,
                                addAutomaticKeepAlives: false,
                              ),
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

  Widget _buildFilterTabs(BuildContext context, ProjectProvider provider) {
    final tabs = [
      'All',
      'Active',
      'Planning',
      'Completed',
      'On Hold',
    ];

    Map<String, int> counts = {
      'All': provider.projects.length,
      'Active': provider.projects.where((p) => p.status.toLowerCase() == 'in progress').length,
      'Planning': provider.projects.where((p) => p.status.toLowerCase() == 'planning').length,
      'Completed': provider.projects.where((p) => p.status.toLowerCase() == 'completed').length,
      'On Hold': provider.projects.where((p) => p.status.toLowerCase() == 'on hold').length,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((label) {
            final selected = _filter == label;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _filter = label),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? ProjectManagerTheme.cyanGlow.withOpacity(0.2)
                        : ProjectManagerTheme.cosmicBlue,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? ProjectManagerTheme.cyanGlow
                          : ProjectManagerTheme.cyanGlow.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '$label (${counts[label] ?? 0})',
                    style: ProjectManagerTheme.bodyText.copyWith(
                      color: selected
                          ? ProjectManagerTheme.cyanGlow
                          : ProjectManagerTheme.textPrimary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    final color = Color(
      int.parse(project.themeColor.replaceFirst('#', '0xFF')),
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          FuturisticPageRoute(
            builder: (context) => ProjectDetailsScreen(projectId: project.id!),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            Row(
              children: [
                if (project.iconEmoji != null)
                  Text(project.iconEmoji!, style: const TextStyle(fontSize: 32)),
                if (project.iconEmoji != null) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: ProjectManagerTheme.subtitleText,
                      ),
                      Text(
                        project.projectType,
                        style: ProjectManagerTheme.captionText.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ProjectManagerTheme.getStatusColor(project.status)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    project.status,
                    style: ProjectManagerTheme.captionText.copyWith(
                      color: ProjectManagerTheme.getStatusColor(project.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              project.description,
              style: ProjectManagerTheme.bodyText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: project.progressPercentage / 100,
              backgroundColor: ProjectManagerTheme.nebulaBlue,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${project.completedFeatures}/${project.totalFeatures} Features',
                  style: ProjectManagerTheme.captionText,
                ),
                Text(
                  '${project.progressPercentage.toStringAsFixed(0)}%',
                  style: ProjectManagerTheme.captionText.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off_rounded,
            size: 80,
            color: ProjectManagerTheme.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'NO PROJECTS YET',
            style: ProjectManagerTheme.subtitleText,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('CREATE PROJECT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ProjectManagerTheme.cyanGlow,
              foregroundColor: ProjectManagerTheme.deepSpace,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddProjectDialog(),
    );
  }

  List<Project> _filteredProjects(List<Project> projects) {
    switch (_filter) {
      case 'Active':
        return projects.where((p) => p.status.toLowerCase() == 'in progress').toList();
      case 'Planning':
        return projects.where((p) => p.status.toLowerCase() == 'planning').toList();
      case 'Completed':
        return projects.where((p) => p.status.toLowerCase() == 'completed').toList();
      case 'On Hold':
        return projects.where((p) => p.status.toLowerCase() == 'on hold').toList();
      default:
        return projects;
    }
  }
}
