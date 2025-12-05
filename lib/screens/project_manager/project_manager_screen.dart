import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers/project_provider.dart';
import '../../theme/project_manager_theme.dart';
import 'futuristic_page_route.dart';
import 'project_list_screen.dart';
import 'add_project_dialog.dart';
import 'add_research_dialog.dart';
import 'overall_research_screen.dart';
import 'theme_tear_transition.dart';

class ProjectManagerScreen extends StatefulWidget {
  const ProjectManagerScreen({super.key});

  @override
  State<ProjectManagerScreen> createState() => _ProjectManagerScreenState();
}

class _ProjectManagerScreenState extends State<ProjectManagerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
      ),
    );

    _animationController.forward();

    // Load data
    Future.microtask(() {
      if (mounted) {
        Provider.of<ProjectProvider>(context, listen: false).loadAllData();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          child: Stack(
            children: [
              // Lightweight static star background
              const _StaticStarBackground(),
              
              // Main content
              SafeArea(
                child: Consumer<ProjectProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return _buildLoadingState();
                    }

                    return CustomScrollView(
                      slivers: [
                        // Custom App Bar
                        SliverToBoxAdapter(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              ProjectManagerTheme.cyanGlow.withOpacity(0.3),
                                              ProjectManagerTheme.purpleNeon.withOpacity(0.3),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: ProjectManagerTheme.cyanGlow.withOpacity(0.5),
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.satellite_alt_rounded,
                                          color: ProjectManagerTheme.cyanGlow,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'PROJECT',
                                              style: ProjectManagerTheme.captionText.copyWith(
                                                color: ProjectManagerTheme.cyanGlow,
                                                letterSpacing: 4,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const Text(
                                              'COMMAND CENTER',
                                              style: ProjectManagerTheme.titleText,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => provider.loadAllData(),
                                        icon: const Icon(
                                          Icons.refresh_rounded,
                                          color: ProjectManagerTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Mission Control • All Systems Operational',
                                    style: ProjectManagerTheme.captionText.copyWith(
                                      color: ProjectManagerTheme.successGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Overall Research (replaces stats grid)
                        SliverToBoxAdapter(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              child: _buildOverallResearchSection(provider),
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 24)),

                        // Quick Actions
                        SliverToBoxAdapter(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'QUICK ACTIONS',
                                    style: ProjectManagerTheme.subtitleText.copyWith(
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildActionButton(
                                          icon: Icons.add_rounded,
                                          label: 'New Project',
                                          color: ProjectManagerTheme.cyanGlow,
                                          onTap: () => _showAddProjectDialog(context),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildActionButton(
                                          icon: Icons.view_list_rounded,
                                          label: 'All Projects',
                                          color: ProjectManagerTheme.purpleNeon,
                                          onTap: () => _navigateToProjectList(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 32)),

                        // Active Projects
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'ACTIVE MISSIONS',
                              style: ProjectManagerTheme.subtitleText.copyWith(
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 16)),

                        // Project Cards
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: provider.projects.isEmpty
                              ? SliverToBoxAdapter(
                                  child: _buildEmptyState(),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final project = provider.projects
                                          .where((p) => p.status == 'In Progress')
                                          .toList();
                                      if (index >= project.length) return null;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: _buildProjectCard(project[index]),
                                      );
                                    },
                                    childCount: provider.projects
                                        .where((p) => p.status == 'In Progress')
                                        .length,
                                  ),
                                ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const ThemeTearLoading(
      message: 'INITIALIZING SYSTEMS...',
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: ProjectManagerTheme.subtitleText.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(project) {
    final color = Color(
      int.parse(project.themeColor.replaceFirst('#', '0xFF')),
    );

    return InkWell(
      onTap: () {
        // Navigate to project details
        Navigator.push(
          context,
          FuturisticPageRoute(
            builder: (context) => ProjectListScreen(initialProjectId: project.id),
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
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (project.iconEmoji != null)
                  Text(
                    project.iconEmoji!,
                    style: const TextStyle(fontSize: 32),
                  ),
                if (project.iconEmoji != null) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: ProjectManagerTheme.subtitleText.copyWith(
                          color: ProjectManagerTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.projectType,
                        style: ProjectManagerTheme.captionText.copyWith(
                          color: color,
                        ),
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
                    border: Border.all(
                      color: ProjectManagerTheme.getStatusColor(project.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    project.status,
                    style: ProjectManagerTheme.captionText.copyWith(
                      color: ProjectManagerTheme.getStatusColor(project.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: project.progressPercentage / 100,
                backgroundColor: ProjectManagerTheme.nebulaBlue,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.rocket_launch_outlined,
              size: 80,
              color: ProjectManagerTheme.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'NO ACTIVE MISSIONS',
              style: ProjectManagerTheme.subtitleText.copyWith(
                color: ProjectManagerTheme.textSecondary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your first project to begin tracking',
              style: ProjectManagerTheme.captionText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddProjectDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('CREATE PROJECT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ProjectManagerTheme.cyanGlow,
                foregroundColor: ProjectManagerTheme.deepSpace,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallResearchSection(ProjectProvider provider) {
    final notes = provider.overallResearch;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ProjectManagerTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ProjectManagerTheme.mintGlow.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _navigateToOverallResearch(context),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ProjectManagerTheme.mintGlow.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ProjectManagerTheme.mintGlow.withOpacity(0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.science_rounded,
                          color: ProjectManagerTheme.mintGlow,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OVERALL RESEARCH',
                              style: ProjectManagerTheme.subtitleText.copyWith(
                                letterSpacing: 2,
                              ),
                            ),
                            // Text(
                            //   'Company-wide insights, discoveries, and experiments',
                            //   style: ProjectManagerTheme.captionText,
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showOverallResearchDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ProjectManagerTheme.mintGlow,
                  foregroundColor: ProjectManagerTheme.deepSpace,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (notes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ProjectManagerTheme.deepSpace.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ProjectManagerTheme.mintGlow.withOpacity(0.2),
                ),
              ),
              child: Text(
                'No research added yet. Capture discoveries to share with the team.',
                style: ProjectManagerTheme.bodyText,
              ),
            )
          else
            Column(
              children: notes.take(2).map((note) {
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _navigateToOverallResearch(context),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ProjectManagerTheme.deepSpace.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ProjectManagerTheme.mintGlow.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _truncateText(note.title, 70),
                                style: ProjectManagerTheme.subtitleText.copyWith(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                          _truncateText(note.content, 220),
                          style: ProjectManagerTheme.bodyText,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showOverallResearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddResearchDialog(projectId: 'overall'),
    );
  }

  void _navigateToOverallResearch(BuildContext context) {
    Navigator.push(
      context,
      FuturisticPageRoute(
        builder: (context) => const OverallResearchScreen(),
      ),
    );
  }

  String _truncateText(String value, int maxChars) {
    if (value.length <= maxChars) return value;
    return '${value.substring(0, maxChars)}...';
  }

  void _showAddProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddProjectDialog(),
    );
  }

  void _navigateToProjectList(BuildContext context) {
    Navigator.push(
      context,
      FuturisticPageRoute(
        builder: (context) => const ProjectListScreen(),
      ),
    );
  }
}

/// Lightweight static star background - renders once on init
class _StaticStarBackground extends StatelessWidget {
  const _StaticStarBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StaticStarPainter(),
      child: Container(),
    );
  }
}

class _StaticStarPainter extends CustomPainter {
  final List<_StarData> stars = _generateStars();

  static List<_StarData> _generateStars() {
    final stars = <_StarData>[];
    final random = Random(42); // Fixed seed for consistency
    
    for (int i = 0; i < 40; i++) {
      stars.add(
        _StarData(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: 1.0 + (random.nextDouble() * 2),
          opacity: 0.2 + (random.nextDouble() * 0.6),
        ),
      );
    }
    return stars;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (final star in stars) {
      paint.color = const Color(0xFFF0F0FF).withOpacity(star.opacity);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StaticStarPainter oldDelegate) => false; // Never repaint
}

class _StarData {
  final double x;
  final double y;
  final double size;
  final double opacity;

  _StarData({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
  });
}

