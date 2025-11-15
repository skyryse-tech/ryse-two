import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/cofounder.dart';
import '../../theme/app_theme.dart';
import 'add_cofounder_dialog.dart';

class CoFounderScreen extends StatelessWidget {
  const CoFounderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Co-founders'),
            elevation: 0,
          ),
          body: provider.coFounders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No co-founders added yet',
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
                  itemCount: provider.coFounders.length,
                  itemBuilder: (context, index) {
                    final coFounder = provider.coFounders[index];
                    return _buildCoFounderCard(context, coFounder, provider);
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddCoFounderDialog(),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildCoFounderCard(
    BuildContext context,
    CoFounder coFounder,
    dynamic provider,
  ) {
    final balance = provider.getBalances()[coFounder.id] ?? 0;
    final color = balance > 0 ? AppTheme.success : AppTheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor:
                      Color(int.parse('0x${coFounder.avatarColor}')),
                  child: Text(
                    coFounder.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coFounder.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        coFounder.email,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                      if (coFounder.phone.isNotEmpty)
                        Text(
                          coFounder.phone,
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
                        // Edit co-founder
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () {
                        _showDeleteConfirmation(context, coFounder, provider);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.background,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        balance > 0 ? 'Gets Refund' : 'Owes',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                      Text(
                        '\$${balance.abs().toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Paid',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                      Text(
                        '\$${provider.getExpensesByPayer(coFounder.id).toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    CoFounder coFounder,
    dynamic provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Co-founder?'),
        content: const Text(
          'This will also delete all related expenses.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteCoFounder(coFounder.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Co-founder deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
