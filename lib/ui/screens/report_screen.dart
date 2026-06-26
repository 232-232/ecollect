import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import 'package:intl/intl.dart';
import '../widgets/animated_dropdown.dart';
import '../widgets/glass_container.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String period = 'daily';
  DateTime selectedDate = DateTime.now();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  String selectedRoot = 'All Roots';
  String selectedEC = 'All EC';
  String searchQuery = '';

  final List<String> roots = [
    'All Roots',
    'Place 1',
    'Place 2',
    'Place 3',
    'Place 4',
  ];
  final List<String> ecTypes = ['All EC', 'Auto Credit', 'Manual', 'Digital'];

  bool _inPeriod(DateTime txDate) {
    if (period == 'daily') {
      return txDate.year == selectedDate.year &&
          txDate.month == selectedDate.month &&
          txDate.day == selectedDate.day;
    }
    if (period == 'weekly') {
      final startOfWeek = selectedDate.subtract(
        Duration(days: selectedDate.weekday - 1),
      );
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return txDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          txDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    }
    if (period == 'monthly') {
      return txDate.year == selectedDate.year &&
          txDate.month == selectedDate.month;
    }
    if (period == 'range') {
      final from = DateTime(fromDate.year, fromDate.month, fromDate.day);
      final to = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
      return txDate.isAfter(from.subtract(const Duration(milliseconds: 1))) &&
          txDate.isBefore(to.add(const Duration(milliseconds: 1)));
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          double totalAmount = 0;
          int totalCount = 0;
          Map<int, int> denomMap = {};
          List<Map<String, dynamic>> shopReports = [];

          final denoms = [5000, 2000, 1000, 500, 200, 100, 50, 20, 10];

          for (var shop in state.shops) {
            if (selectedRoot != 'All Roots' && shop.root != selectedRoot) {
              continue;
            }
            if (selectedEC != 'All EC' && shop.ecType != selectedEC) continue;
            if (searchQuery.isNotEmpty &&
                !shop.name.toLowerCase().contains(searchQuery.toLowerCase()) &&
                !shop.lapu.contains(searchQuery)) {
              continue;
            }

            double shopTotal = 0;
            for (var tx in shop.transactions) {
              if (_inPeriod(tx.timestamp)) {
                totalAmount += tx.amount;
                shopTotal += tx.amount;
                totalCount++;

                double rem = tx.amount;
                for (var d in denoms) {
                  int n = (rem / d).floor();
                  if (n > 0) {
                    denomMap[d] = (denomMap[d] ?? 0) + n;
                    rem -= n * d;
                  }
                }
              }
            }

            if (shopTotal > 0) {
              shopReports.add({'shop': shop, 'amount': shopTotal});
            }
          }

          shopReports.sort(
            (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
          );

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Tab Bar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildTab('daily', 'Daily'),
                    _buildTab('weekly', 'Weekly'),
                    _buildTab('monthly', 'Monthly'),
                    _buildTab('range', 'Range'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Filters Card
              GlassContainer(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      if (period != 'range')
                        _buildFieldGroup(
                          'Date',
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => selectedDate = date);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: theme.inputDecorationTheme.fillColor,
                                border: Border.all(color: theme.dividerColor),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat(
                                      period == 'monthly'
                                          ? 'MMMM yyyy'
                                          : 'dd MMM yyyy',
                                    ).format(selectedDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today, size: 18),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: _buildFieldGroup(
                                'From',
                                InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: fromDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() => fromDate = date);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          theme.inputDecorationTheme.fillColor,
                                      border: Border.all(
                                        color: theme.dividerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      DateFormat(
                                        'dd MMM yyyy',
                                      ).format(fromDate),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildFieldGroup(
                                'To',
                                InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: toDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() => toDate = date);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          theme.inputDecorationTheme.fillColor,
                                      border: Border.all(
                                        color: theme.dividerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      DateFormat('dd MMM yyyy').format(toDate),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      _buildFieldGroup(
                        'Search',
                        TextField(
                          onChanged: (val) => setState(() => searchQuery = val),
                          decoration: const InputDecoration(
                            hintText: 'Search shop or LAPU...',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedDropdown(
                              label: 'Root',
                              value: selectedRoot,
                              items: roots,
                              onChanged: (val) =>
                                  setState(() => selectedRoot = val!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AnimatedDropdown(
                              label: 'EC Type',
                              value: selectedEC,
                              items: ecTypes,
                              onChanged: (val) =>
                                  setState(() => selectedEC = val!),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.12),
                      const Color(0xFF00BFA5).withValues(alpha: 0.08),
                    ],
                  ),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL COLLECTION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Utils.formatINR(totalAmount),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      '$totalCount collections',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                    ),
                    if (denomMap.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Denominations',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(denomMap.entries.toList()
                            ..sort((a, b) => b.key.compareTo(a.key)))
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${e.key} × ${e.value}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  Text(
                                    Utils.formatINR(
                                      (e.key * e.value).toDouble(),
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Shop-wise',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 12),

              if (shopReports.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No data for this period',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...shopReports.map((report) {
                  final shop = report['shop'] as ShopModel;
                  final amount = report['amount'] as double;
                  return GlassContainer(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        shop.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${shop.location} · LAPU: ${shop.lapu} · ${shop.root}',
                      ),
                      trailing: Text(
                        Utils.formatINR(amount),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(String val, String label) {
    final theme = Theme.of(context);
    final isSelected = period == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => period = val),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? theme.primaryColor
                  : theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldGroup(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodySmall?.color,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
