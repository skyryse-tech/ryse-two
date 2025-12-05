import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/expense_provider.dart';
import '../../theme/project_manager_theme.dart';
import '../../models/project.dart';

class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({super.key});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _techStackController = TextEditingController();
  final _repoUrlController = TextEditingController();
  
  String _selectedType = 'Website';
  String _selectedStatus = 'Planning';
  int _selectedPriority = 3;
  String _selectedColor = '#00F0FF';
  String? _selectedEmoji;
  DateTime? _deadline;
  List<String> _selectedCofounders = [];

  final List<String> _projectTypes = [
    'Website',
    'Mobile App',
    'Desktop App',
    'API',
    'Backend',
    'Design',
    'Research',
    'Other',
  ];

  final List<String> _statuses = [
    'Planning',
    'In Progress',
    'On Hold',
    'Completed',
  ];

  final Map<String, String> _colorOptions = {
    'Cyan': '#00F0FF',
    'Purple': '#9D4EDD',
    'Pink': '#FF006E',
    'Mint': '#06FFA5',
    'Yellow': '#FFBE0B',
    'Blue': '#00D9FF',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _techStackController.dispose();
    _repoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ProjectManagerTheme.darkTheme,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          decoration: BoxDecoration(
            gradient: ProjectManagerTheme.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ProjectManagerTheme.cyanGlow.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ProjectManagerTheme.cyanGlow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: ProjectManagerTheme.cyanGlow,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'NEW PROJECT',
                          style: ProjectManagerTheme.titleText,
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: ProjectManagerTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Project Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Project Name',
                      hint: 'Enter project name',
                      icon: Icons.folder_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter project name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'What is this project about?',
                      icon: Icons.description_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    
                    // Project Type & Status
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Type',
                            value: _selectedType,
                            items: _projectTypes,
                            onChanged: (value) {
                              setState(() => _selectedType = value!);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Status',
                            value: _selectedStatus,
                            items: _statuses,
                            onChanged: (value) {
                              setState(() => _selectedStatus = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tech Stack
                    _buildTextField(
                      controller: _techStackController,
                      label: 'Tech Stack',
                      hint: 'Flutter, Firebase, Node.js...',
                      icon: Icons.code_rounded,
                    ),
                    const SizedBox(height: 16),
                    
                    // Repository URL
                    _buildTextField(
                      controller: _repoUrlController,
                      label: 'Repository URL (Optional)',
                      hint: 'https://github.com/...',
                      icon: Icons.link_rounded,
                    ),
                    const SizedBox(height: 16),
                    
                    // Color Selection
                    Text(
                      'Theme Color',
                      style: ProjectManagerTheme.captionText.copyWith(
                        color: ProjectManagerTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _colorOptions.entries.map((entry) {
                        final isSelected = _selectedColor == entry.value;
                        final color = Color(
                          int.parse(entry.value.replaceFirst('#', '0xFF')),
                        );
                        return InkWell(
                          onTap: () => setState(() => _selectedColor = entry.value),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? ProjectManagerTheme.textPrimary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Priority Slider
                    Text(
                      'Priority: $_selectedPriority',
                      style: ProjectManagerTheme.captionText.copyWith(
                        color: ProjectManagerTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Slider(
                      value: _selectedPriority.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: ProjectManagerTheme.cyanGlow,
                      onChanged: (value) {
                        setState(() => _selectedPriority = value.toInt());
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Team Selection
                    Consumer<ExpenseProvider>(
                      builder: (context, expenseProvider, child) {
                        final cofounders = expenseProvider.coFounders;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned To',
                              style: ProjectManagerTheme.captionText.copyWith(
                                color: ProjectManagerTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: cofounders.map((cf) {
                                final isSelected = _selectedCofounders.contains(cf.name);
                                return FilterChip(
                                  label: Text(cf.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedCofounders.add(cf.name);
                                      } else {
                                        _selectedCofounders.remove(cf.name);
                                      }
                                    });
                                  },
                                  selectedColor: ProjectManagerTheme.cyanGlow.withOpacity(0.3),
                                  checkmarkColor: ProjectManagerTheme.cyanGlow,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? ProjectManagerTheme.cyanGlow
                                        : ProjectManagerTheme.textSecondary,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ProjectManagerTheme.textSecondary,
                              side: BorderSide(
                                color: ProjectManagerTheme.textSecondary.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('CANCEL'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _createProject,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ProjectManagerTheme.cyanGlow,
                              foregroundColor: ProjectManagerTheme.deepSpace,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('CREATE'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ProjectManagerTheme.captionText.copyWith(
            color: ProjectManagerTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: ProjectManagerTheme.bodyText.copyWith(
            color: ProjectManagerTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ProjectManagerTheme.bodyText,
            prefixIcon: Icon(icon, color: ProjectManagerTheme.cyanGlow),
            filled: true,
            fillColor: ProjectManagerTheme.deepSpace.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ProjectManagerTheme.cyanGlow.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ProjectManagerTheme.cyanGlow.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ProjectManagerTheme.cyanGlow,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ProjectManagerTheme.captionText.copyWith(
            color: ProjectManagerTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          style: ProjectManagerTheme.bodyText.copyWith(
            color: ProjectManagerTheme.textPrimary,
          ),
          dropdownColor: ProjectManagerTheme.cosmicBlue,
          decoration: InputDecoration(
            filled: true,
            fillColor: ProjectManagerTheme.deepSpace.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ProjectManagerTheme.cyanGlow.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ProjectManagerTheme.cyanGlow.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ProjectManagerTheme.cyanGlow,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCofounders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one team member')),
      );
      return;
    }

    final project = Project(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      projectType: _selectedType,
      createdAt: DateTime.now(),
      deadline: _deadline,
      status: _selectedStatus,
      priority: _selectedPriority,
      techStack: _techStackController.text.trim(),
      repositoryUrl: _repoUrlController.text.trim().isEmpty 
          ? null 
          : _repoUrlController.text.trim(),
      assignedTo: _selectedCofounders.join(', '),
      themeColor: _selectedColor,
      iconEmoji: _selectedEmoji,
    );

    try {
      await Provider.of<ProjectProvider>(context, listen: false).addProject(project);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${project.name}" created successfully!'),
            backgroundColor: ProjectManagerTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating project: $e'),
            backgroundColor: ProjectManagerTheme.errorRed,
          ),
        );
      }
    }
  }
}
