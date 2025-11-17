import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/expense_provider.dart';
import '../../theme/app_theme.dart';
import 'add_company_fund_dialog.dart';

class CompanyFundScreen extends StatelessWidget {
  const CompanyFundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Company Fund'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.7)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Balance',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${provider.companyFundBalance.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${provider.companyFunds.length} transactions',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (provider.companyFunds.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(Icons.wallet, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No fund transactions yet',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...provider.companyFunds.map((fund) {
                    final isAdd = fund.type == 'add';
                    final color = isAdd ? AppTheme.success : AppTheme.error;
                    return _buildFundCard(context, fund, isAdd, color);
                  }),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddCompanyFundDialog(),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildFundCard(BuildContext context, dynamic fund, bool isAdd, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.withValues(alpha: 0.1),
              ),
              child: Icon(
                isAdd ? Icons.add_circle_outline : Icons.remove_circle_outline,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fund.description,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${isAdd ? 'Added' : 'Removed'} • ${DateFormat('MMM dd, yyyy').format(fund.date)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '${isAdd ? '+' : '-'}₹${fund.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
