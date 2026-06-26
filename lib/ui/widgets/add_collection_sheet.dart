import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/app_state.dart';

class AddCollectionSheet extends StatefulWidget {
  final String shopId;
  const AddCollectionSheet({super.key, required this.shopId});

  @override
  State<AddCollectionSheet> createState() => _AddCollectionSheetState();
}

class _AddCollectionSheetState extends State<AddCollectionSheet>
    with TickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _btnController;
  late Animation<double> _btnScale;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  // Denomination tracking
  final Map<int, int> _denomCounts = {};
  bool _showDenom = false;

  final List<int> _denoms = [500, 200, 100, 50, 20, 10];
  final List<int> quickAmounts = [10, 20, 50, 100, 200, 500];

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.easeInOut),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    _amountController.addListener(_syncDenomFromAmount);
  }

  void _syncDenomFromAmount() {
    final total = double.tryParse(_amountController.text) ?? 0;
    if (!_showDenom) return;
    // Recalculate denoms from amount
    int rem = total.round();
    final newMap = <int, int>{};
    for (final d in _denoms) {
      final n = rem ~/ d;
      if (n > 0) {
        newMap[d] = n;
        rem -= n * d;
      }
    }
    setState(() => _denomCounts
      ..clear()
      ..addAll(newMap));
  }

  void _updateAmountFromDenoms() {
    int total = 0;
    for (final e in _denomCounts.entries) {
      total += e.key * e.value;
    }
    _amountController.removeListener(_syncDenomFromAmount);
    _amountController.text = total > 0 ? total.toString() : '';
    _amountController.addListener(_syncDenomFromAmount);
  }

  void _addQuickAmount(int amount) {
    final current = int.tryParse(_amountController.text) ?? 0;
    _amountController.text = (current + amount).toString();
    HapticFeedback.lightImpact();
  }

  void _confirm() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      if (mounted) _showToast(context, 'Enter a valid amount', isError: true);
      return;
    }
    if (!mounted) return;
    await _btnController.forward();
    if (!mounted) return;
    await _btnController.reverse();
    if (!mounted) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      context.read<AppState>().addTransaction(
            widget.shopId,
            amount,
            _noteController.text.trim(),
          );
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_syncDenomFromAmount);
    _amountController.dispose();
    _noteController.dispose();
    _btnController.stop();
    _btnController.dispose();
    _slideController.stop();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162119) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle + Header
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 18),
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.primaryColor,
                              const Color(0xFF00BFA5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_card_outlined,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Add Collection',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Amount Input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor.withValues(alpha: 0.08),
                          theme.primaryColor.withValues(alpha: 0.03),
                        ],
                      ),
                      border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.3),
                          width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: '0',
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              hintStyle: TextStyle(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.4),
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        // Clear button
                        if (_amountController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear_rounded,
                                color: theme.textTheme.bodySmall?.color),
                            onPressed: () {
                              _amountController.clear();
                              setState(() => _denomCounts.clear());
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Note
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      hintText: 'e.g. morning collection',
                      prefixIcon: Icon(Icons.notes_outlined, size: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Amounts
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'QUICK AMOUNTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: quickAmounts.map((amount) {
                      return _QuickChip(
                        label: '₹${amount >= 1000 ? '${amount ~/ 1000}K' : amount}',
                        onTap: () => _addQuickAmount(amount),
                        primaryColor: theme.primaryColor,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Denomination toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showDenom = !_showDenom;
                        if (_showDenom) _syncDenomFromAmount();
                      });
                      HapticFeedback.selectionClick();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calculate_outlined,
                                  size: 18, color: theme.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Denomination Breakdown',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          AnimatedRotation(
                            turns: _showDenom ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(Icons.keyboard_arrow_down,
                                color: theme.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Denomination grid
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  child: _showDenom
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _denoms.map((denom) {
                              final count = _denomCounts[denom] ?? 0;
                              return _DenomCounter(
                                denom: denom,
                                count: count,
                                primaryColor: theme.primaryColor,
                                isDark: isDark,
                                onIncrement: () {
                                  setState(() {
                                    _denomCounts[denom] = count + 1;
                                  });
                                  _updateAmountFromDenoms();
                                  HapticFeedback.lightImpact();
                                },
                                onDecrement: () {
                                  if (count > 0) {
                                    setState(() {
                                      if (count == 1) {
                                        _denomCounts.remove(denom);
                                      } else {
                                        _denomCounts[denom] = count - 1;
                                      }
                                    });
                                    _updateAmountFromDenoms();
                                    HapticFeedback.lightImpact();
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Confirm button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: ScaleTransition(
                    scale: _btnScale,
                    child: _AnimatedConfirmButton(
                      isLoading: _isLoading,
                      onTap: _isLoading ? null : _confirm,
                      primaryColor: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class _QuickChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color primaryColor;
  const _QuickChip(
      {required this.label, required this.onTap, required this.primaryColor});

  @override
  State<_QuickChip> createState() => _QuickChipState();
}

class _QuickChipState extends State<_QuickChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.9)
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.primaryColor.withValues(alpha: 0.08),
            border:
                Border.all(color: widget.primaryColor.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: widget.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}



class _DenomCounter extends StatelessWidget {
  final int denom;
  final int count;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _DenomCounter({
    required this.denom,
    required this.count,
    required this.primaryColor,
    required this.isDark,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = count > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isActive
            ? primaryColor.withValues(alpha: 0.12)
            : (isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.03)),
        border: Border.all(
          color: isActive
              ? primaryColor.withValues(alpha: 0.4)
              : Colors.transparent,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹${denom >= 1000 ? '${denom ~/ 1000}K' : denom}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive
                      ? primaryColor
                      : (isDark ? Colors.white60 : Colors.black45),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDecrement,
                child: Icon(Icons.remove_circle_outline,
                    size: 18,
                    color: isActive ? primaryColor : Colors.grey.shade400),
              ),
              const SizedBox(width: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: child,
                ),
                child: Text(
                  '$count',
                  key: ValueKey(count),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isActive ? primaryColor : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onIncrement,
                child: Icon(Icons.add_circle_outline,
                    size: 18, color: primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class _AnimatedConfirmButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onTap;
  final Color primaryColor;

  const _AnimatedConfirmButton({
    required this.isLoading,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  State<_AnimatedConfirmButton> createState() => _AnimatedConfirmButtonState();
}

class _AnimatedConfirmButtonState extends State<_AnimatedConfirmButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
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
        onTapDown: widget.onTap != null ? (_) => _c.forward() : null,
        onTapUp: widget.onTap != null
            ? (_) {
                _c.reverse();
                widget.onTap!();
              }
            : null,
        onTapCancel: () => _c.reverse(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.primaryColor,
                const Color(0xFF00BFA5),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Confirm Collection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}



void showToast(BuildContext context, String message, {bool isError = false}) {
  _showToast(context, message, isError: isError);
}

void _showToast(BuildContext context, String message, {bool isError = false}) {
  // Only show if the overlay is still available
  if (!context.mounted) return;
  OverlayState? overlay;
  try {
    overlay = Overlay.of(context);
  } catch (_) {
    return;
  }
  late OverlayEntry entry;
  bool removed = false;
  entry = OverlayEntry(
    builder: (_) => _ToastWidget(
      message: message,
      isError: isError,
      onDismiss: () {
        if (!removed) {
          removed = true;
          try { entry.remove(); } catch (_) {}
        }
      },
    ),
  );
  overlay.insert(entry);
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _c.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _c.reverse().then((_) {
        if (mounted) widget.onDismiss();
      });
    });
  }

  @override
  void dispose() {
    _c.stop();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isError ? const Color(0xFFE53935) : const Color(0xFF00897B);
    final icon = widget.isError ? Icons.error_outline : Icons.check_circle_outline;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
