import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/expense_provider.dart';
import '../../theme/project_manager_theme.dart';
import '../../models/project.dart';

class AddResearchDialog extends StatefulWidget {
  final String projectId;

  const AddResearchDialog({super.key, required this.projectId});

  @override
  State<AddResearchDialog> createState() => _AddResearchDialogState();
}

class _AddResearchDialogState extends State<AddResearchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final _linksController = TextEditingController();
  
  String _selectedCategory = 'Technical';
  String _selectedAuthor = '';

  final List<String> _categories = [
    'Technical',
    'Market',
    'Design',
    'User Feedback',
    'Competitive Analysis',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _linksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cofounders = Provider.of<ExpenseProvider>(context, listen: false).coFounders;
    
    if (_selectedAuthor.isEmpty && cofounders.isNotEmpty) {
      _selectedAuthor = cofounders.first.name;
    }

    return Theme(
      data: ProjectManagerTheme.darkTheme,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          decoration: BoxDecoration(
            gradient: ProjectManagerTheme.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ProjectManagerTheme.mintGlow.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: SingleChildScrollView(
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
                        const Icon(Icons.science_rounded, color: ProjectManagerTheme.mintGlow),
                        const SizedBox(width: 12),
                        const Text('ADD RESEARCH', style: ProjectManagerTheme.titleText),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    _buildTextField(_titleController, 'Title', 'Research title'),
                    const SizedBox(height: 16),
                    
                    _buildTextField(_contentController, 'Content', 'Describe your research findings...', maxLines: 6),
                    const SizedBox(height: 16),
                    
                    _buildDropdown('Category', _selectedCategory, _categories, (v) => setState(() => _selectedCategory = v!)),
                    const SizedBox(height: 16),
                    
                    _buildDropdown(
                      'Author',
                      _selectedAuthor,
                      cofounders.map((cf) => cf.name).toList(),
                      (v) => setState(() => _selectedAuthor = v!),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(_tagsController, 'Tags (Optional)', 'tag1, tag2, tag3'),
                    const SizedBox(height: 16),
                    
                    _buildTextField(_linksController, 'Reference Links (Optional)', 'https://...'),
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CANCEL'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _createResearch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ProjectManagerTheme.mintGlow,
                              foregroundColor: ProjectManagerTheme.deepSpace,
                            ),
                            child: const Text('ADD'),
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

  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ProjectManagerTheme.captionText.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: ProjectManagerTheme.bodyText.copyWith(color: ProjectManagerTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: ProjectManagerTheme.deepSpace.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ProjectManagerTheme.mintGlow.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ProjectManagerTheme.mintGlow, width: 2),
            ),
          ),
          validator: maxLines > 1 ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ProjectManagerTheme.captionText.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
          style: ProjectManagerTheme.bodyText.copyWith(color: ProjectManagerTheme.textPrimary),
          dropdownColor: ProjectManagerTheme.cosmicBlue,
          decoration: InputDecoration(
            filled: true,
            fillColor: ProjectManagerTheme.deepSpace.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Future<void> _createResearch() async {
    if (!_formKey.currentState!.validate()) return;

    final note = ResearchNote(
      projectId: widget.projectId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      authorName: _selectedAuthor,
      createdAt: DateTime.now(),
      category: _selectedCategory,
      tags: _tagsController.text.trim().isEmpty ? null : _tagsController.text.trim(),
      referenceLinks: _linksController.text.trim().isEmpty ? null : _linksController.text.trim(),
    );

    try {
      await Provider.of<ProjectProvider>(context, listen: false).addResearchNote(note);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Research added successfully!'),
            backgroundColor: ProjectManagerTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: ProjectManagerTheme.errorRed,
          ),
        );
      }
    }
  }
}
