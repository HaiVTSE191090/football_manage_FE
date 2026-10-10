import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

class SplitBillDialog extends StatefulWidget {
  const SplitBillDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const SplitBillDialog(),
    );
  }

  @override
  State<SplitBillDialog> createState() => _SplitBillDialogState();
}

class _SplitBillDialogState extends State<SplitBillDialog> {
  final _fieldCostController = TextEditingController(text: '450000');
  final _waterCostController = TextEditingController(text: '50000');
  int _playerCount = 10;

  @override
  void dispose() {
    _fieldCostController.dispose();
    _waterCostController.dispose();
    super.dispose();
  }

  int get _totalCost {
    final field = int.tryParse(_fieldCostController.text) ?? 0;
    final water = int.tryParse(_waterCostController.text) ?? 0;
    return field + water;
  }

  int get _costPerPerson {
    if (_playerCount <= 0) return 0;
    return (_totalCost / _playerCount).ceil();
  }

  String _formatNumber(int number) {
    final buffer = StringBuffer();
    final str = number.toString();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()}đ';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Iconsax.card, color: Color(0xFF16A34A)),
          SizedBox(width: 10),
          Text(
            'Chia Tiền Sân Nhanh',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field cost
            const Text(
              'Tiền sân (VNĐ):',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _fieldCostController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Water cost
            const Text(
              'Tiền nước & đồ uống (VNĐ):',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _waterCostController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),

            // Number of players
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Số người chia:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.grey.shade700,
                      onPressed: _playerCount > 1
                          ? () => setState(() => _playerCount--)
                          : null,
                    ),
                    Text(
                      '$_playerCount người',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.green.shade600,
                      onPressed: () => setState(() => _playerCount++),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),

            // Result
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng chi phí:'),
                      Text(
                        _formatNumber(_totalCost),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mỗi người góp:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatNumber(_costPerPerson),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            Clipboard.setData(ClipboardData(
              text: 'Kèo bóng đá hôm nay: Tổng ${_formatNumber(_totalCost)} / $_playerCount người. Mỗi anh em góp ${_formatNumber(_costPerPerson)} nhé!',
            ));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã sao chép nội dung chia tiền!')),
            );
          },
          child: const Text('Sao chép lời nhắn'),
        ),
      ],
    );
  }
}
