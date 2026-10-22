class PaymentModel {
  final int paymentId;
  final int? bookingId;
  final int? orderId;
  final int amount;
  final String paymentType;
  final String paymentMethod;
  final String transactionRef;
  final String status;
  final String? paymentUrl;
  final String createdAt;

  const PaymentModel({
    required this.paymentId,
    this.bookingId,
    this.orderId,
    required this.amount,
    required this.paymentType,
    required this.paymentMethod,
    required this.transactionRef,
    required this.status,
    this.paymentUrl,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['paymentId'] ?? 0;
    final int paymentId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    final rawBookingId = json['bookingId'];
    final int? bookingId = rawBookingId != null ? (rawBookingId is int ? rawBookingId : int.tryParse(rawBookingId.toString())) : null;

    final rawOrderId = json['orderId'];
    final int? orderId = rawOrderId != null ? (rawOrderId is int ? rawOrderId : int.tryParse(rawOrderId.toString())) : null;

    final rawAmount = json['amount'] ?? 0;
    final int amount = rawAmount is num ? rawAmount.toInt() : (double.tryParse(rawAmount.toString())?.toInt() ?? 0);

    return PaymentModel(
      paymentId: paymentId,
      bookingId: bookingId,
      orderId: orderId,
      amount: amount,
      paymentType: json['paymentType'] as String? ?? 'FULL',
      paymentMethod: json['paymentMethod'] as String? ?? 'CASH',
      transactionRef: json['transactionRef'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      paymentUrl: json['paymentUrl'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
