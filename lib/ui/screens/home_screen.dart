import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../widgets/shop_card.dart';
import '../widgets/add_collection_sheet.dart' show AddCollectionSheet, showToast;
import 'add_shop_screen.dart';
import 'report_screen.dart';
import '../widgets/animated_dropdown.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  final List<String> roots = ['All Roots', 'Place 1', 'Place 2', 'Place 3', 'Place 4'];
  final List<String> ecTypes = ['All EC', 'Auto Credit', 'Manual', 'Digital'];

  String selectedRoot = 'All Roots';
  String selectedEC = 'All EC';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<AppState>().setFilter(search: query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: theme.appBarTheme.titleTextStyle,
            children: [
              const TextSpan(text: 'e'),
              TextSpan(
                text: 'Collect',
                style: TextStyle(color: theme.primaryColor),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<AppState>().isDarkMode 
                  ? Icons.light_mode_outlined 
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              context.read<AppState>().toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const ReportScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: _AnimatedAddButton(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const AddShopScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                        child: child,
                      );
                    },
                  ),
                );
              },
              primaryColor: theme.primaryColor,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search name or LAPU...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedDropdown(
                        label: 'Root',
                        value: selectedRoot,
                        items: roots,
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() => selectedRoot = newValue);
                            context.read<AppState>().setFilter(
                                  root: newValue == 'All Roots' ? '' : newValue,
                                );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedDropdown(
                        label: 'EC Type',
                        value: selectedEC,
                        items: ecTypes,
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() => selectedEC = newValue);
                            context.read<AppState>().setFilter(
                                  ec: newValue == 'All EC' ? '' : newValue,
                                );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shops',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 17),
                ),
                Consumer<AppState>(
                  builder: (context, state, child) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${state.filteredShops.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Consumer<AppState>(
              builder: (context, state, child) {
                final shops = state.filteredShops;
                
                if (shops.isEmpty) {
                  return const Center(child: _PulsingEmptyState());
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    final shop = shops[index];
                    return ShopCard(
                      shop: shop,
                      onDelete: () => state.deleteShop(shop.id),
                      onAddCollection: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => AddCollectionSheet(shopId: shop.id),
                        ).then((result) {
                          if (result == true && context.mounted) {
                            showToast(context, 'Collection added successfully ✓');
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: Consumer<AppState>(
        builder: (context, state, child) {
          double total = 0;
          int count = 0;
          for (var shop in state.shops) {
            final todayTotal = shop.todayTotal;
            if (todayTotal > 0) {
              total += todayTotal;
              count += shop.transactions.where((t) => t.timestamp.day == DateTime.now().day).length;
            }
          }

          return GestureDetector(
            onTap: () {
              if (count == 0) return;
              _showTodayBreakdown(context, state);
            },
            child: Container(
              color: theme.cardColor,
              padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Today\'s Collection', style: TextStyle(fontWeight: FontWeight.bold)),
                          if (count > 0) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.open_in_new, size: 14, color: theme.primaryColor),
                          ],
                        ],
                      ),
                      Text('$count collections', style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
                    ],
                  ),
                  Text(
                    Utils.formatINR(total),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTodayBreakdown(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final today = DateTime.now();
        final List<Map<String, dynamic>> todayTxs = [];

        for (var shop in state.shops) {
          for (var tx in shop.transactions) {
            if (tx.timestamp.year == today.year &&
                tx.timestamp.month == today.month &&
                tx.timestamp.day == today.day) {
              todayTxs.add({
                'shop': shop,
                'amount': tx.amount,
                'time': tx.timestamp,
              });
            }
          }
        }

        todayTxs.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  'Today\'s Breakdown',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 20),
                  itemCount: todayTxs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = todayTxs[index];
                    final shop = item['shop'] as ShopModel;
                    final amount = item['amount'] as double;
                    final time = item['time'] as DateTime;
                    
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                        child: Icon(Icons.receipt, color: theme.primaryColor, size: 18),
                      ),
                      title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} · ${shop.location}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        Utils.formatINR(amount),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: theme.primaryColor,
                          fontSize: 15,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class _PulsingEmptyState extends StatefulWidget {
  const _PulsingEmptyState();

  @override
  State<_PulsingEmptyState> createState() => _PulsingEmptyStateState();
}

class _PulsingEmptyStateState extends State<_PulsingEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _opacityAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: Opacity(opacity: _opacityAnim.value, child: child),
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primaryColor.withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.store_mall_directory_outlined,
              size: 52,
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'No shops found',
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 6),
        Text(
          'Add a shop or adjust your filters',
          style: TextStyle(color: theme.textTheme.bodySmall?.color),
        ),
      ],
    );
  }
}

class _AnimatedAddButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color primaryColor;

  const _AnimatedAddButton({
    required this.onTap,
    required this.primaryColor,
  });

  @override
  State<_AnimatedAddButton> createState() => _AnimatedAddButtonState();
}

class _AnimatedAddButtonState extends State<_AnimatedAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.stop();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _c.forward(),
        onTapUp: (_) {
          _c.reverse();
          widget.onTap();
        },
        onTapCancel: () => _c.reverse(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.primaryColor,
                const Color(0xFF00BFA5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

