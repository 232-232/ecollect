import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../widgets/add_collection_sheet.dart' show showToast;
import '../widgets/animated_dropdown.dart';
import '../widgets/glass_container.dart';

class AddShopScreen extends StatefulWidget {
  const AddShopScreen({super.key});

  @override
  State<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends State<AddShopScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _lapuController = TextEditingController();

  final List<String> roots = ['Place 1', 'Place 2', 'Place 3', 'Place 4'];
  final List<String> ecTypes = ['Auto Credit', 'Manual', 'Digital'];

  String? selectedRoot;
  String? selectedEC;
  bool _isLoading = false;

  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _lapuController.dispose();
    _entryController.stop();
    _entryController.dispose();
    super.dispose();
  }

  void _saveShop() async {
    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final lapu = _lapuController.text.trim();

    if (name.isEmpty || location.isEmpty || lapu.isEmpty ||
        selectedRoot == null || selectedEC == null) {
      HapticFeedback.heavyImpact();
      showToast(context, 'Please fill all fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      context.read<AppState>().addShop(ShopModel(
        id: 'sh_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        location: location,
        lapu: lapu,
        root: selectedRoot!,
        ecType: selectedEC!,
        transactions: [],
        createdAt: DateTime.now(),
      ));
      showToast(context, 'Shop "$name" added successfully!');
      // Short delay so toast is visible before pop
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Custom back button = chevron
      appBar: AppBar(
        leading: _ChevronBack(),
        title: const Text('Add Shop'),
        titleSpacing: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Shop details card
                GlassContainer(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldGroup(
                        context,
                        'Shop Name',
                        Icons.storefront_outlined,
                        TextField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                              hintText: 'Enter shop name'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFieldGroup(
                        context,
                        'Location / Area',
                        Icons.location_on_outlined,
                        TextField(
                          controller: _locationController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration:
                              const InputDecoration(hintText: 'e.g. Kollam'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFieldGroup(
                        context,
                        'LAPU Number',
                        Icons.sim_card_outlined,
                        TextField(
                          controller: _lapuController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration:
                              const InputDecoration(hintText: 'e.g. 5484849'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Dropdowns card
                GlassContainer(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDropdown(
                        label: 'Root Place',
                        hint: 'Select Place...',
                        value: selectedRoot,
                        items: roots,
                        onChanged: (val) =>
                            setState(() => selectedRoot = val),
                      ),
                      const SizedBox(height: 20),
                      AnimatedDropdown(
                        label: 'EC Type',
                        hint: 'Select Type...',
                        value: selectedEC,
                        items: ecTypes,
                        onChanged: (val) =>
                            setState(() => selectedEC = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save button
                _AnimatedSaveButton(
                  isLoading: _isLoading,
                  onTap: _isLoading ? null : _saveShop,
                  primaryColor: theme.primaryColor,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldGroup(
      BuildContext context, String label, IconData icon, Widget field) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: theme.textTheme.bodySmall?.color),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodySmall?.color,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}



class _ChevronBack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.chevron_left, size: 28),
      tooltip: 'Back',
      onPressed: () => Navigator.maybePop(context),
    );
  }
}



class _AnimatedSaveButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onTap;
  final Color primaryColor;

  const _AnimatedSaveButton({
    required this.isLoading,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  State<_AnimatedSaveButton> createState() => _AnimatedSaveButtonState();
}

class _AnimatedSaveButtonState extends State<_AnimatedSaveButton>
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
                HapticFeedback.mediumImpact();
                widget.onTap!();
              }
            : null,
        onTapCancel: () => _c.reverse(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
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
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.store_mall_directory_outlined,
                          color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Save Shop',
                        style: TextStyle(
                          fontSize: 17,
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
