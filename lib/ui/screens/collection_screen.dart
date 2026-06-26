import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils.dart';
import '../../data/app_state.dart';
import '../widgets/add_collection_sheet.dart' show AddCollectionSheet, showToast;
import '../widgets/glass_container.dart';

class CollectionScreen extends StatelessWidget {
  final String shopId;

  const CollectionScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final shop = state.shops.firstWhere((s) => s.id == shopId);
        final theme = Theme.of(context);

        final lastTx = shop.lastTransaction;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, size: 28),
              onPressed: () => Navigator.maybePop(context),
            ),
            title: const Text('Collection'),
            titleSpacing: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_card_outlined),
                onPressed: () => _openCreditModal(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00897B), Color(0xFF00BFA5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${shop.location} · LAPU: ${shop.lapu} · ${shop.ecType}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -16),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Summary Cards
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.5,
                        children: [
                          _buildSummaryCard(
                            context,
                            'Today',
                            Utils.formatINR(shop.todayTotal),
                            Icons.today_outlined,
                            const Color(0xFF00897B),
                          ),
                          _buildSummaryCard(
                            context,
                            'Total',
                            Utils.formatINR(shop.totalCollection),
                            Icons.account_balance_wallet_outlined,
                            const Color(0xFF00C853),
                          ),
                          _buildSummaryCard(
                            context,
                            'Collections',
                            '${shop.transactions.length}',
                            Icons.receipt_long_outlined,
                            const Color(0xFFFFB300),
                          ),
                          _buildSummaryCard(
                            context,
                            'Last',
                            lastTx != null
                                ? Utils.formatDate(lastTx.timestamp)
                                : '—',
                            Icons.history_outlined,
                            const Color(0xFF039BE5),
                            valueSize: 13,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Transactions',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 12),

                      GlassContainer(
                        child: shop.transactions.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(
                                  child: Text(
                                    'No transactions yet',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: shop.transactions.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final tx = shop.transactions.reversed
                                      .toList()[index];
                                  return ListTile(
                                    leading: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF00C853),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    title: Text(
                                      '+${Utils.formatINR(tx.amount)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00C853),
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (tx.note.isNotEmpty) Text(tx.note),
                                        Text(
                                          Utils.formatDate(tx.timestamp),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _openCreditModal(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_card_outlined),
                              SizedBox(width: 8),
                              Text(
                                'Add Collection',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    double valueSize = 22,
  }) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.w800,
              color: label == 'Today'
                  ? theme.primaryColor
                  : theme.textTheme.bodyLarge?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _openCreditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCollectionSheet(shopId: shopId),
    ).then((result) {
      if (result == true && context.mounted) {
        showToast(context, 'Collection added successfully ✓');
      }
    });
  }
}
