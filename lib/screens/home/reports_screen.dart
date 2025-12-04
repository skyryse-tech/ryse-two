import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/expense_provider.dart';
import '../../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.primary,
              title: const Text('Reports & Analytics', style: TextStyle(color: Colors.white)),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'By Person'),
                  Tab(text: 'By Category'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildOverviewTab(context, provider),
                _buildByPersonTab(context, provider),
                _buildByCategoryTab(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(BuildContext context, dynamic provider) {
    final coFounders = provider.coFounders;
    
    // Calculate company fund vs personal expenses
    double companyFund = 0;
    double personalExpense = 0;
    for (var expense in provider.expenses) {
      if (expense.isCompanyFund) {
        companyFund += expense.amount;
      } else {
        personalExpense += expense.amount;
      }
    }

    final totalExpenses = personalExpense; // Only personal expenses count as total

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Amount - Large Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Expenses',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '₹${totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Key metrics - Row 1
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Company Fund',
                  '₹${companyFund.toStringAsFixed(2)}',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Personal',
                  '₹${personalExpense.toStringAsFixed(2)}',
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Key metrics - Row 2
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Transactions',
                  '${provider.expenses.length}',
                  AppTheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Team Size',
                  '${coFounders.length}',
                  AppTheme.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Average Expense',
                  provider.expenses.isEmpty
                      ? '₹0.00'
                      : '₹${(totalExpenses / provider.expenses.length).toStringAsFixed(2)}',
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Per Capita',
                  coFounders.isEmpty
                      ? '₹0.00'
                      : '₹${(totalExpenses / coFounders.length).toStringAsFixed(2)}',
                  Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Expense Distribution',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildExpenseChart(provider),
        ],
      ),
    );
  }

  Widget _buildByPersonTab(BuildContext context, dynamic provider) {
    final coFounders = provider.coFounders;
    final balances = provider.getBalances();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contribution Summary',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...coFounders.map((coFounder) {
            final paid = provider.getExpensesByPayer(coFounder.id);
            final balance = balances[coFounder.id] ?? 0;

            return _buildPersonCard(
              context,
              coFounder.name,
              Color(int.parse('0x${coFounder.avatarColor}')),
              paid,
              balance,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildByCategoryTab(BuildContext context, dynamic provider) {
    Map<String, double> categoryTotals = {};
    for (var expense in provider.expenses) {
      // Skip company fund expenses in category view
      if (expense.isCompanyFund) continue;
      
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expenses by Category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          sortedCategories.isEmpty
              ? Center(
                  child: Text(
                    'No expense data',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                )
              : ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: sortedCategories.map((entry) {
                    return _buildCategoryItem(
                      context,
                      entry.key,
                      entry.value,
                      provider.getTotalExpenses(),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.7)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseChart(dynamic provider) {
    Map<String, double> categoryTotals = {};
    for (var expense in provider.expenses) {
      // Skip company fund expenses in chart
      if (expense.isCompanyFund) continue;
      
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    // Calculate total only for personal expenses
    double personalTotal = 0;
    for (var expense in provider.expenses) {
      if (!expense.isCompanyFund) {
        personalTotal += expense.amount;
      }
    }

    return SizedBox(
      height: 300,
      child: categoryTotals.isEmpty
          ? Center(
              child: Text(
                'No expense data available',
                style: TextStyle(color: Colors.grey[400]),
              ),
            )
          : PieChart(
              PieChartData(
                sections: categoryTotals.entries.map((entry) {
                  final percentage = personalTotal > 0
                      ? (entry.value / personalTotal) * 100
                      : 0;
                  return PieChartSectionData(
                    value: entry.value,
                    title: '${percentage.toStringAsFixed(1)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildPersonCard(
    BuildContext context,
    String name,
    Color avatarColor,
    double paid,
    double balance,
  ) {
    // Calculate progress based on total personal expenses
    final totalPersonalExpenses = context.read<ExpenseProvider>()
        .expenses
        .where((e) => !e.isCompanyFund)
        .fold<double>(0, (sum, e) => sum + e.amount);
    
    final progressValue = totalPersonalExpenses > 0 ? (paid / totalPersonalExpenses).toDouble() : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: avatarColor,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progressValue.clamp(0.0, 1.0),
                    backgroundColor: AppTheme.background,
                    minHeight: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Paid: ₹${paid.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  balance > 0
                      ? '+₹${balance.toStringAsFixed(2)}'
                      : '-₹${balance.abs().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: balance > 0 ? AppTheme.success : AppTheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String category,
    double amount,
    double total,
  ) {
    final percentage = (amount / total) * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AppTheme.background,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
