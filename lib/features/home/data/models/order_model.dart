import 'product_model.dart';

class OrderModel {
  final int orderId;
  final int totalAmount;
  final String status;
  final String createdAt;
  final List<CartItemModel> items;

  const OrderModel({
    required this.orderId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.items = const [],
  });

  String get orderCode => 'ORD-$orderId';
  int get finalAmount => totalAmount;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['orderId'] ?? 0;
    final int orderId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    final rawAmount = json['totalAmount'] ?? 0;
    final int totalAmount = rawAmount is num ? rawAmount.toInt() : (double.tryParse(rawAmount.toString())?.toInt() ?? 0);

    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();

    return OrderModel(
      orderId: orderId,
      totalAmount: totalAmount,
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['createdAt'] as String? ?? '',
      items: items,
    );
  }
}
