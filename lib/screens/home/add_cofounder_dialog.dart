import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/cofounder.dart';
import '../../theme/app_theme.dart';

class AddCoFounderDialog extends StatefulWidget {
  const AddCoFounderDialog({super.key});

  @override
  State<AddCoFounderDialog> createState() => _AddCoFounderDialogState();
}

class _AddCoFounderDialogState extends State<AddCoFounderDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankAccountController;
  late TextEditingController _bankIFSCController;
  late TextEditingController _roleController;
  
  late String _selectedColor;
  
  final List<String> _avatarColors = [
    'FF1E88E5', // Blue
    'FFEC407A', // Pink
    'FF43A047', // Green
    'FFF57C00', // Orange
    'FF6A1B9A', // Purple
    'FF00796B', // Teal
    'FFD32F2F', // Red
    'FFFBC02D', // Amber
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bankNameController = TextEditingController();
    _bankAccountController = TextEditingController();
    _bankIFSCController = TextEditingController();
    _roleController = TextEditingController(text: 'Co-founder');
    _selectedColor = _avatarColors.first;
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
                    'Add Team Member',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  
                  // Avatar color selection
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
                        onTap: () {
                          setState(() => _selectedColor = color);
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Color(int.parse('0x$color')),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: AppTheme.primary,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Name
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'John Doe',
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'john@example.com',
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone (optional)',
                      hintText: '+1 234 567 8900',
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Role
                  TextField(
                    controller: _roleController,
                    decoration: InputDecoration(
                      labelText: 'Designation/Role',
                      hintText: 'CTO, CEO, Developer',
                      prefixIcon: const Icon(Icons.work),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Bank Details Section
                  Text(
                    'Bank Account Details (optional)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: _bankNameController,
                    decoration: InputDecoration(
                      labelText: 'Bank Name',
                      hintText: 'HDFC, ICICI, SBI',
                      prefixIcon: const Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _bankAccountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Account Number',
                      hintText: '1234567890',
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _bankIFSCController,
                    decoration: InputDecoration(
                      labelText: 'IFSC Code',
                      hintText: 'HDFC0001234',
                      prefixIcon: const Icon(Icons.code),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _saveCoFounder(context, provider),
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

  void _saveCoFounder(BuildContext context, dynamic provider) {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email')),
      );
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    final coFounder = CoFounder(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _roleController.text.trim().isEmpty ? 'Co-founder' : _roleController.text.trim(),
      avatarColor: _selectedColor,
      createdAt: DateTime.now(),
      bankName: _bankNameController.text.trim(),
      bankAccountNumber: _bankAccountController.text.trim(),
      bankIFSC: _bankIFSCController.text.trim(),
    );

    provider.addCoFounder(coFounder).then((success) {
      if (mounted) {
        Navigator.pop(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Team member added successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error adding team member')),
          );
        }
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    });
  }
}
