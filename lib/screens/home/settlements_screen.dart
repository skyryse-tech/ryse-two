import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/settlement.dart';
import '../../theme/app_theme.dart';

class SettlementsScreen extends StatelessWidget {
  const SettlementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final balances = provider.getBalances();
        final coFounders = provider.coFounders;

        // Calculate who owes whom
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settlements'),
            elevation: 0,
          ),
          body: debts.isEmpty
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
                ),
        );
      },
    );
  }

  Widget _buildDebtCard(
    BuildContext context,
    Map<String, dynamic> debt,
    dynamic provider,
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
                      '\$${amount.toStringAsFixed(2)}',
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
    dynamic provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Settlement'),
        content: Text(
          '${from.name} will transfer \$${amount.toStringAsFixed(2)} to ${to.name}',
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
              provider.recordSettlement(settlement);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settlement recorded')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
