import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  List<ShopModel> _shops = [];
  bool _isDarkMode = false;
  
  // Filters
  String _filterRoot = '';
  String _filterEC = '';
  String _filterSearch = '';

  List<ShopModel> get shops => _shops;
  bool get isDarkMode => _isDarkMode;
  
  String get filterRoot => _filterRoot;
  String get filterEC => _filterEC;
  String get filterSearch => _filterSearch;

  List<ShopModel> get filteredShops {
    return _shops.where((s) {
      if (_filterRoot.isNotEmpty && s.root != _filterRoot) return false;
      if (_filterEC.isNotEmpty && s.ecType != _filterEC) return false;
      if (_filterSearch.isNotEmpty) {
        final q = _filterSearch.toLowerCase();
        if (!s.name.toLowerCase().contains(q) && !s.lapu.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  AppState() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    
    final shopsJson = prefs.getString('shops');
    if (shopsJson != null) {
      final List decoded = jsonDecode(shopsJson);
      _shops = decoded.map((e) => ShopModel.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveShops() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_shops.map((s) => s.toJson()).toList());
    await prefs.setString('shops', jsonStr);
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void addShop(ShopModel shop) {
    _shops.insert(0, shop);
    notifyListeners();
    _saveShops();
  }

  void deleteShop(String id) {
    _shops.removeWhere((s) => s.id == id);
    notifyListeners();
    _saveShops();
  }

  void addTransaction(String shopId, double amount, String note) {
    final index = _shops.indexWhere((s) => s.id == shopId);
    if (index >= 0) {
      final shop = _shops[index];
      final transaction = TransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        note: note,
        timestamp: DateTime.now(),
      );
      
      final updatedShop = ShopModel(
        id: shop.id,
        name: shop.name,
        location: shop.location,
        lapu: shop.lapu,
        root: shop.root,
        ecType: shop.ecType,
        transactions: [...shop.transactions, transaction],
        createdAt: shop.createdAt,
      );
      
      _shops[index] = updatedShop;
      notifyListeners();
      _saveShops();
    }
  }

  void setFilter({String? root, String? ec, String? search}) {
    if (root != null) _filterRoot = root;
    if (ec != null) _filterEC = ec;
    if (search != null) _filterSearch = search;
    notifyListeners();
  }
}
