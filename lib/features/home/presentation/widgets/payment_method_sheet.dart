import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/payment_model.dart';
import '../../data/services/payment_api_service.dart';

class PaymentMethodSheet extends StatefulWidget {
  final String title;
  final int amount;
  final int? bookingId;
  final int? orderId;
  final String paymentType; // 'DEPOSIT', 'FULL', 'REMAINING'
  final void Function(PaymentModel payment)? onPaymentCompleted;

  const PaymentMethodSheet({
    super.key,
    required this.title,
    required this.amount,
    this.bookingId,
    this.orderId,
    this.paymentType = 'FULL',
    this.onPaymentCompleted,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required int amount,
    int? bookingId,
    int? orderId,
    String paymentType = 'FULL',
    void Function(PaymentModel payment)? onPaymentCompleted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentMethodSheet(
        title: title,
        amount: amount,
        bookingId: bookingId,
        orderId: orderId,
        paymentType: paymentType,
        onPaymentCompleted: onPaymentCompleted,
      ),
    );
  }

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  final PaymentApiService _paymentService = PaymentApiService();
  String _selectedMethod = 'VNPAY'; // 'VNPAY', 'BANK_TRANSFER', 'CASH'
  bool _isLoading = false;

  String _formatPrice(int price) {
    final buffer = StringBuffer();
    final str = price.toString();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()}đ';
  }

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      final payment = await _paymentService.createPayment(
        bookingId: widget.bookingId,
        orderId: widget.orderId,
        paymentType: widget.paymentType,
        paymentMethod: _selectedMethod,
      );

      if (!mounted) return;

      if (_selectedMethod == 'VNPAY' && payment.paymentUrl != null && payment.paymentUrl!.isNotEmpty) {
        final uri = Uri.parse(payment.paymentUrl!);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể mở liên kết thanh toán VNPay.')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onPaymentCompleted?.call(payment);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            content: Text(
              _selectedMethod == 'VNPAY'
                  ? 'Đã chuyển hướng tới cổng thanh toán VNPay'
                  : 'Đã tạo yêu cầu thanh toán (${_selectedMethod == 'CASH' ? 'Tiền mặt' : 'Chuyển khoản'}) thành công!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            content: Text('Lỗi thanh toán: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền cần thanh toán:',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                Text(
                  _formatPrice(widget.amount),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            const Text(
              'Chọn phương thức thanh toán:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            _buildMethodTile(
              id: 'VNPAY',
              title: 'Cổng VNPay',
              subtitle: 'Thẻ ATM nội địa, QR Code, Visa/Mastercard',
              icon: Iconsax.card_pos,
              color: const Color(0xFF005BAA),
            ),
            const SizedBox(height: 10),
            _buildMethodTile(
              id: 'BANK_TRANSFER',
              title: 'Chuyển khoản ngân hàng',
              subtitle: 'Chuyển khoản trực tiếp tới tài khoản quản lý sân',
              icon: Iconsax.bank,
              color: const Color(0xFF0D9488),
            ),
            const SizedBox(height: 10),
            _buildMethodTile(
              id: 'CASH',
              title: 'Tiền mặt',
              subtitle: 'Thanh toán trực tiếp tại quầy lễ tân sân bóng',
              icon: Iconsax.money_recive,
              color: const Color(0xFFD97706),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.shield_tick, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _selectedMethod == 'VNPAY'
                                ? 'Tiến hành thanh toán VNPay'
                                : 'Xác nhận thanh toán',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF16A34A) : Colors.grey.shade200,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF16A34A) : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
