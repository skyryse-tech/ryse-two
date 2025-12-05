import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/expense_provider.dart';
import '../../theme/project_manager_theme.dart';
import '../../models/project.dart';

class AddFeatureDialog extends StatefulWidget {
  final String projectId;

  const AddFeatureDialog({super.key, required this.projectId});

  @override
  State<AddFeatureDialog> createState() => _AddFeatureDialogState();
}

class _AddFeatureDialogState extends State<AddFeatureDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hoursController = TextEditingController(text: '0');
  
  String _selectedStatus = 'Todo';
  int _selectedPriority = 3;
  String _selectedAssignee = '';

  final List<String> _statuses = ['Todo', 'In Progress', 'Testing', 'Completed', 'Blocked'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cofounders = Provider.of<ExpenseProvider>(context, listen: false).coFounders;
    
    if (_selectedAssignee.isEmpty && cofounders.isNotEmpty) {
      _selectedAssignee = cofounders.first.name;
    }

    return Theme(
      data: ProjectManagerTheme.darkTheme,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            gradient: ProjectManagerTheme.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ProjectManagerTheme.purpleNeon.withOpacity(0.3),
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
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.add_task_rounded, color: ProjectManagerTheme.purpleNeon),
                        const SizedBox(width: 12),
                        const Text('ADD FEATURE', style: ProjectManagerTheme.titleText),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(_nameController, 'Feature Name', 'Enter feature name'),
                    const SizedBox(height: 16),
                    _buildTextField(_descriptionController, 'Description', 'Describe the feature', maxLines: 3),
                    const SizedBox(height: 16),
                    _buildDropdown('Status', _selectedStatus, _statuses, (v) => setState(() => _selectedStatus = v!)),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      'Assigned To',
                      _selectedAssignee,
                      cofounders.map((cf) => cf.name).toList(),
                      (v) => setState(() => _selectedAssignee = v!),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_hoursController, 'Estimated Hours', '0', isNumber: true),
                    const SizedBox(height: 16),
                    Text('Priority: $_selectedPriority', style: ProjectManagerTheme.captionText),
                    Slider(
                      value: _selectedPriority.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: ProjectManagerTheme.purpleNeon,
                      onChanged: (v) => setState(() => _selectedPriority = v.toInt()),
                    ),
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
                            onPressed: _createFeature,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ProjectManagerTheme.purpleNeon,
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

  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ProjectManagerTheme.captionText),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: ProjectManagerTheme.bodyText.copyWith(color: ProjectManagerTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: ProjectManagerTheme.deepSpace.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ProjectManagerTheme.captionText),
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

  Future<void> _createFeature() async {
    if (!_formKey.currentState!.validate()) return;

    final feature = ProjectFeature(
      projectId: widget.projectId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _selectedStatus,
      createdAt: DateTime.now(),
      priority: _selectedPriority,
      estimatedHours: int.tryParse(_hoursController.text) ?? 0,
      assignedTo: _selectedAssignee,
    );

    try {
      await Provider.of<ProjectProvider>(context, listen: false).addFeature(feature);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feature added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
