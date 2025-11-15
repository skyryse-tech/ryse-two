import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';
import '../../theme/app_theme.dart';
import 'add_expense_dialog.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final expenses = _selectedCategory == 'All'
            ? provider.expenses
            : provider.expenses
                .where((e) => e.category == _selectedCategory)
                .toList();

        final coFounders = provider.coFounders;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Expenses'),
            elevation: 0,
          ),
          body: Column(
            children: [
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    ...expenseCategories.map((cat) => _buildFilterChip(cat)),
                  ],
                ),
              ),
              // Expenses list
              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No expenses in this category',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          final payer = coFounders
                              .firstWhere((cf) => cf.id == expense.paidById);
                          return _buildExpenseCard(
                            context,
                            expense,
                            payer,
                            provider,
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddExpenseDialog(),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String category) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: _selectedCategory == category,
        onSelected: (selected) {
          setState(() => _selectedCategory = category);
        },
      ),
    );
  }

  Widget _buildExpenseCard(
    BuildContext context,
    Expense expense,
    dynamic payer,
    dynamic provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.background,
                  ),
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        expense.category,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${expense.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(expense.date),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: AppTheme.divider),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      Color(int.parse('0x${payer.avatarColor}')),
                  child: Text(
                    payer.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paid by ${payer.name}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${expense.contributorIds.length} people involved • \$${expense.getContributionPerPerson().toStringAsFixed(2)} each',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Edit'),
                      onTap: () {
                        // Edit expense
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () {
                        _showDeleteConfirmation(context, expense, provider);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Expense expense,
    dynamic provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text(
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteExpense(expense.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final Map<String, IconData> icons = {
      'Office Supplies': Icons.edit,
      'Equipment': Icons.computer,
      'Software & Tools': Icons.apps,
      'Marketing': Icons.campaign,
      'Travel': Icons.flight,
      'Utilities': Icons.power,
      'Rent/Space': Icons.home,
      'Food & Beverage': Icons.restaurant,
      'Professional Services': Icons.business,
      'Other': Icons.category,
    };
    return icons[category] ?? Icons.category;
  }
}
