class TransactionModel {
  final String id;
  final double amount;
  final String note;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'note': note,
        'timestamp': timestamp.toIso8601String(),
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'],
        amount: json['amount'],
        note: json['note'] ?? '',
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class ShopModel {
  final String id;
  final String name;
  final String location;
  final String lapu;
  final String root;
  final String ecType;
  final List<TransactionModel> transactions;
  final DateTime createdAt;

  ShopModel({
    required this.id,
    required this.name,
    required this.location,
    required this.lapu,
    required this.root,
    required this.ecType,
    required this.transactions,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'lapu': lapu,
        'root': root,
        'ecType': ecType,
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ShopModel.fromJson(Map<String, dynamic> json) => ShopModel(
        id: json['id'],
        name: json['name'],
        location: json['location'],
        lapu: json['lapu'],
        root: json['root'],
        ecType: json['ecType'],
        transactions: (json['transactions'] as List)
            .map((t) => TransactionModel.fromJson(t))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
      );

  double get todayTotal {
    final now = DateTime.now();
    return transactions.where((t) {
      return t.timestamp.year == now.year &&
          t.timestamp.month == now.month &&
          t.timestamp.day == now.day;
    }).fold(0, (sum, t) => sum + t.amount);
  }

  double get totalCollection => transactions.fold(0, (sum, t) => sum + t.amount);

  TransactionModel? get lastTransaction =>
      transactions.isNotEmpty ? transactions.last : null;
}
