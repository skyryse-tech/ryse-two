import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';

class AddExpenseDialog extends StatefulWidget {
  final Expense? expense;
  final bool isEdit;

  const AddExpenseDialog({super.key, this.expense, this.isEdit = false});

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
    
    if (widget.isEdit && widget.expense != null) {
      final exp = widget.expense!;
      _descriptionController.text = exp.description;
      _amountController.text = exp.amount.toString();
      _notesController.text = exp.notes ?? '';
      _companyNameController.text = exp.companyName;
      _selectedCategory = exp.category;
      _selectedPayer = exp.paidById == 0 ? null : exp.paidById;
      _selectedContributors = List.from(exp.contributorIds);
      _selectedDate = exp.date;
      _isCompanyFund = exp.isCompanyFund;
    }
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
                    widget.isEdit ? 'Edit Expense' : 'Record Expense',
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
                    initialValue: _selectedCategory,
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
                  
                  // Who Paid - Disabled for company fund
                  DropdownButtonFormField<int>(
                    initialValue: _selectedPayer,
                    decoration: InputDecoration(
                      labelText: _isCompanyFund ? 'Company Fund Payment' : 'Who Paid?',
                      prefixIcon: const Icon(Icons.person),
                      helperText: _isCompanyFund ? 'Deducted from company fund' : null,
                    ),
                    items: _isCompanyFund
                        ? [] // Empty when company fund is selected
                        : provider.coFounders
                            .map((cf) => DropdownMenuItem(
                                  value: cf.id,
                                  child: Text(cf.name),
                                ))
                            .toList(),
                    onChanged: _isCompanyFund
                        ? null // Disabled when company fund
                        : (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedPayer = value;
                                  // Remove payer from contributors
                                  _selectedContributors.remove(value);
                                });
                              }
                            },
                    isExpanded: true,
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
                  }),
                  
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
                        child: Text(widget.isEdit ? 'Update' : 'Save'),
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

    // For company fund, use a placeholder payer ID (0 or special value)
    // For personal expense, require payer selection
    if (!_isCompanyFund && _selectedPayer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who paid')),
      );
      return;
    }

    // Include payer in contributors if not company fund
    List<int> finalContributors = [..._selectedContributors];
    if (!_isCompanyFund && _selectedPayer != null) {
      if (!finalContributors.contains(_selectedPayer)) {
        finalContributors.add(_selectedPayer!);
      }
    }

    if (finalContributors.isEmpty && !_isCompanyFund) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who contributed')),
      );
      return;
    }

    final expense = Expense(
      id: widget.isEdit ? widget.expense?.id : null,
      description: _descriptionController.text,
      amount: double.parse(_amountController.text),
      paidById: _isCompanyFund ? 0 : _selectedPayer!,
      contributorIds: finalContributors.isEmpty ? [0] : finalContributors,
      category: _selectedCategory,
      date: _selectedDate,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: widget.isEdit ? widget.expense!.createdAt : DateTime.now(),
      isCompanyFund: _isCompanyFund,
      companyName: _isCompanyFund ? _companyNameController.text : '',
    );

    if (widget.isEdit) {
      provider.updateExpense(expense).then((success) {
        if (mounted) {
          Navigator.pop(context, true);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expense updated successfully')),
            );
          }
        }
      });
    } else {
      provider.addExpense(expense).then((success) {
        if (mounted) {
          Navigator.pop(context);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expense recorded successfully')),
            );
          }
        }
      });
    }
  }
}
