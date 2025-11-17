import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/settlement.dart';
import '../../models/expense.dart';
import '../../theme/app_theme.dart';

class SettlementsScreen extends StatefulWidget {
  const SettlementsScreen({super.key});

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final balances = provider.getBalances();
        final coFounders = provider.coFounders;
        final settlements = provider.settlements;

        // Calculate pending debts
        List<Map<String, dynamic>> debts = [];
        for (int i = 0; i < coFounders.length; i++) {
          for (int j = i + 1; j < coFounders.length; j++) {
            final balance1 = balances[coFounders[i].id] ?? 0;
            final balance2 = balances[coFounders[j].id] ?? 0;

            if (balance1 > 0 && balance2 < 0) {
              final amount = balance1.abs() > balance2.abs()
                  ? balance2.abs()
                  : balance1.abs();
              debts.add({
                'from': coFounders[j],
                'to': coFounders[i],
                'amount': amount,
              });
            } else if (balance1 < 0 && balance2 > 0) {
              final amount = balance1.abs() > balance2.abs()
                  ? balance2.abs()
                  : balance1.abs();
              debts.add({
                'from': coFounders[i],
                'to': coFounders[j],
                'amount': amount,
              });
            }
          }
        }

        // Separate settled and unsettled settlements
        final settledSettlements =
            settlements.where((s) => s.settled).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settlements'),
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: 'Pending (${debts.length})',
                ),
                Tab(
                  text: 'History (${settledSettlements.length})',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPendingTab(context, debts, provider),
              _buildHistoryTab(context, settledSettlements, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingTab(
    BuildContext context,
    List<Map<String, dynamic>> debts,
    ExpenseProvider provider,
  ) {
    return debts.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'All settled!',
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
            itemCount: debts.length,
            itemBuilder: (context, index) {
              final debt = debts[index];
              return _buildDebtCard(context, debt, provider);
            },
          );
  }

  Widget _buildHistoryTab(
    BuildContext context,
    List<Settlement> settledSettlements,
    ExpenseProvider provider,
  ) {
    return settledSettlements.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No settlement history yet',
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
            itemCount: settledSettlements.length,
            itemBuilder: (context, index) {
              final settlement = settledSettlements[index];
              return _buildSettlementHistoryCard(
                context,
                settlement,
                provider,
              );
            },
          );
  }

  Widget _buildDebtCard(
    BuildContext context,
    Map<String, dynamic> debt,
    ExpenseProvider provider,
  ) {
    final from = debt['from'] as dynamic;
    final to = debt['to'] as dynamic;
    final amount = debt['amount'] as double;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPersonAvatarWithName(from),
                Column(
                  children: [
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                _buildPersonAvatarWithName(to),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showSettlementDialog(context, from, to, amount, provider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                ),
                child: const Text('Mark as Settled'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementHistoryCard(
    BuildContext context,
    Settlement settlement,
    ExpenseProvider provider,
  ) {
    final from = provider.getCoFounderById(settlement.fromId);
    final to = provider.getCoFounderById(settlement.toId);
    
    Expense? relatedExpense;
    if (settlement.relatedExpenseId != null) {
      try {
        relatedExpense = provider.expenses.firstWhere(
          (e) => e.id == settlement.relatedExpenseId,
        );
      } catch (e) {
        relatedExpense = null;
      }
    }

    if (from == null || to == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[50],
      child: InkWell(
        onTap: relatedExpense != null
            ? () {
                _showSettlementDetail(
                  context,
                  settlement,
                  from,
                  to,
                  relatedExpense!,
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSmallPersonAvatar(from),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${from.name} → ${to.name}',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${settlement.amount.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.success),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.success,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(settlement.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  if (relatedExpense != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 14,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            relatedExpense.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.primary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallPersonAvatar(dynamic person) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Color(int.parse('0x${person.avatarColor}')),
      child: Text(
        person.name[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPersonAvatarWithName(dynamic person) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor:
              Color(int.parse('0x${person.avatarColor}')),
          child: Text(
            person.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          person.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showSettlementDialog(
    BuildContext context,
    dynamic from,
    dynamic to,
    double amount,
    ExpenseProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Settlement'),
        content: Text(
          '${from.name} will transfer ₹${amount.toStringAsFixed(2)} to ${to.name}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final settlement = Settlement(
                fromId: from.id,
                toId: to.id,
                amount: amount,
                date: DateTime.now(),
                settled: true,
              );
              provider.recordSettlement(settlement).then((success) {
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settlement recorded')),
                    );
                  }
                }
              });
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSettlementDetail(
    BuildContext context,
    Settlement settlement,
    dynamic from,
    dynamic to,
    dynamic expense,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Settlement Details',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                'From',
                from.name,
                Color(int.parse('0x${from.avatarColor}')),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'To',
                to.name,
                Color(int.parse('0x${to.avatarColor}')),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Amount',
                '₹${settlement.amount.toStringAsFixed(2)}',
                Colors.green,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Date',
                _formatDate(settlement.date),
                Colors.blue,
              ),
              const Divider(height: 24),
              Text(
                'Related Expense',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Category: ${expense.category}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '₹${expense.amount.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accent,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(expense.date),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

