import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late TextEditingController _companyNameController;
  
  String _selectedCategory = expenseCategories.first;
  int? _selectedPayer;
  List<int> _selectedContributors = [];
  DateTime _selectedDate = DateTime.now();
  bool _isCompanyFund = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();
    _notesController = TextEditingController();
    _companyNameController = TextEditingController(text: 'Company Fund');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _companyNameController.dispose();
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
                    'Record Expense',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'What did you spend on?',
                      prefixIcon: const Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Amount
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.attach_money),
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: expenseCategories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      'Date: ${_selectedDate.toString().split(' ')[0]}',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Is Company Fund
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Company Fund'),
                    subtitle: const Text('Is this from company account?'),
                    value: _isCompanyFund,
                    onChanged: (value) {
                      setState(() => _isCompanyFund = value);
                    },
                  ),
                  
                  if (_isCompanyFund) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _companyNameController,
                      decoration: InputDecoration(
                        labelText: 'Company Name',
                        prefixIcon: const Icon(Icons.business),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Who Paid
                  DropdownButtonFormField<int>(
                    value: _selectedPayer,
                    decoration: InputDecoration(
                      labelText: 'Who Paid?',
                      prefixIcon: const Icon(Icons.person),
                    ),
                    items: provider.coFounders
                        .map((cf) => DropdownMenuItem(
                              value: cf.id,
                              child: Text(cf.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPayer = value;
                          // Remove payer from contributors
                          _selectedContributors.remove(value);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Contributors Selection
                  Text(
                    'Anyone else needs to contribute?',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  ...provider.coFounders.map((coFounder) {
                    final isSelected = _selectedContributors.contains(coFounder.id);
                    final isPayer = coFounder.id == _selectedPayer;
                    
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(coFounder.name),
                      subtitle: isPayer ? const Text('(Paid this expense)') : null,
                      value: isSelected,
                      enabled: !isPayer,
                      onChanged: isPayer ? null : (value) {
                        setState(() {
                          if (value == true) {
                            _selectedContributors.add(coFounder.id!);
                          } else {
                            _selectedContributors.remove(coFounder.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                  
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Add additional details...',
                      prefixIcon: const Icon(Icons.note),
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
                        onPressed: () => _saveExpense(context, provider),
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

  void _saveExpense(BuildContext context, dynamic provider) {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    if (_selectedPayer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who paid')),
      );
      return;
    }

    // Include payer in contributors if they should be split
    List<int> finalContributors = [..._selectedContributors];
    if (!finalContributors.contains(_selectedPayer)) {
      finalContributors.add(_selectedPayer!);
    }

    if (finalContributors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who contributed')),
      );
      return;
    }

    final expense = Expense(
      description: _descriptionController.text,
      amount: double.parse(_amountController.text),
      paidById: _selectedPayer!,
      contributorIds: finalContributors,
      category: _selectedCategory,
      date: _selectedDate,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: DateTime.now(),
      isCompanyFund: _isCompanyFund,
      companyName: _isCompanyFund ? _companyNameController.text : '',
    );

    provider.addExpense(expense).then((success) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense recorded successfully')),
        );
      }
    });
  }
}
