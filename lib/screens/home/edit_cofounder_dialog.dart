import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/cofounder.dart';
import '../../theme/app_theme.dart';

class EditCoFounderDialog extends StatefulWidget {
  final CoFounder coFounder;

  const EditCoFounderDialog({super.key, required this.coFounder});

  @override
  State<EditCoFounderDialog> createState() => _EditCoFounderDialogState();
}

class _EditCoFounderDialogState extends State<EditCoFounderDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankAccountController;
  late TextEditingController _bankIFSCController;
  late TextEditingController _roleController;
  late TextEditingController _targetController;
  late String _selectedColor;

  final List<String> _avatarColors = [
    'FF1E88E5',
    'FFEC407A',
    'FF43A047',
    'FFF57C00',
    'FF6A1B9A',
    'FF00796B',
    'FFD32F2F',
    'FFFBC02D',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.coFounder.name);
    _emailController = TextEditingController(text: widget.coFounder.email);
    _phoneController = TextEditingController(text: widget.coFounder.phone);
    _bankNameController = TextEditingController(text: widget.coFounder.bankName);
    _bankAccountController = TextEditingController(text: widget.coFounder.bankAccountNumber);
    _bankIFSCController = TextEditingController(text: widget.coFounder.bankIFSC);
    _roleController = TextEditingController(text: widget.coFounder.role);
    _targetController = TextEditingController(text: widget.coFounder.targetContribution.toString());
    _selectedColor = widget.coFounder.avatarColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _bankIFSCController.dispose();
    _roleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        return Dialog(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Team Member',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Avatar Color',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _avatarColors.map((color) {
                      final isSelected = _selectedColor == color;
                      return InkWell(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Color(int.parse('0x$color')),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? Border.all(color: AppTheme.primary, width: 3) : null,
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone (optional)',
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _roleController,
                    decoration: InputDecoration(
                      labelText: 'Designation/Role',
                      prefixIcon: const Icon(Icons.work),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _targetController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Target Contribution',
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bank Account Details (optional)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bankNameController,
                    decoration: InputDecoration(
                      labelText: 'Bank Name',
                      prefixIcon: const Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bankAccountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Account Number',
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bankIFSCController,
                    decoration: InputDecoration(
                      labelText: 'IFSC Code',
                      prefixIcon: const Icon(Icons.code),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _updateCoFounder(context, provider),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateCoFounder(BuildContext context, ExpenseProvider provider) {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email')),
      );
      return;
    }

    final updatedCoFounder = widget.coFounder.copyWith(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      role: _roleController.text,
      avatarColor: _selectedColor,
      bankName: _bankNameController.text,
      bankAccountNumber: _bankAccountController.text,
      bankIFSC: _bankIFSCController.text,
      targetContribution: double.tryParse(_targetController.text) ?? 0,
    );

    provider.updateCoFounder(updatedCoFounder).then((success) {
      if (success && mounted) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Team member updated successfully')),
          );
        }
      }
    });
  }
}
