import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../data/models/booking_item_model.dart';
import '../../data/models/equipment_model.dart';
import '../../data/models/field_model.dart';
import '../../data/models/referee_model.dart';

class BookingBottomSheet extends StatefulWidget {
  final FieldModel field;
  final void Function(BookingItemModel newBooking)? onBookingSuccess;

  const BookingBottomSheet({
    super.key,
    required this.field,
    this.onBookingSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required FieldModel field,
    void Function(BookingItemModel newBooking)? onBookingSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingBottomSheet(
        field: field,
        onBookingSuccess: onBookingSuccess,
      ),
    );
  }

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  int _selectedDateIndex = 0;
  int _selectedSlotIndex = 1;
  int _selectedPitchIndex = 0;
  bool _isSubmitting = false;

  // Referee selection (Optional - FR14)
  bool _wantReferee = false;
  int _selectedRefereeIndex = 0;
  final List<RefereeModel> _referees = RefereeModel.mockReferees;

  // Equipment rental selection (Optional - FR35)
  bool _wantEquipment = false;
  final List<RentalSelection> _rentals = [
    RentalSelection(
      equipment: const EquipmentItem(
        id: 'eq_ball',
        name: 'Bóng đá thi đấu FIFA',
        equipmentType: 'FOOTBALL',
        rentalPrice: 30000,
        availableQuantity: 20,
        iconEmoji: '⚽',
      ),
      quantity: 0,
    ),
    RentalSelection(
      equipment: const EquipmentItem(
        id: 'eq_shoes',
        name: 'Giày đá bóng cỏ nhân tạo',
        equipmentType: 'SHOES',
        rentalPrice: 50000,
        availableQuantity: 30,
        availableSizes: ['39', '40', '41', '42', '43'],
        iconEmoji: '👟',
      ),
      quantity: 0,
      selectedSize: '41',
    ),
    RentalSelection(
      equipment: const EquipmentItem(
        id: 'eq_gloves',
        name: 'Găng tay thủ môn dính bóng',
        equipmentType: 'GLOVES',
        rentalPrice: 30000,
        availableQuantity: 10,
        iconEmoji: '🧤',
      ),
      quantity: 0,
    ),
    RentalSelection(
      equipment: const EquipmentItem(
        id: 'eq_bibs',
        name: 'Bộ áo bib phân đội (10 áo)',
        equipmentType: 'BIBS',
        rentalPrice: 20000,
        availableQuantity: 15,
        iconEmoji: '🎽',
      ),
      quantity: 0,
    ),
  ];

  // Payment Option (Deposit 30% vs Full 100% - FR17)
  String _paymentOption = 'DEPOSIT'; // 'DEPOSIT' or 'FULL_PAYMENT'
  final double _depositRate = 0.30; // 30% deposit business rule

  final List<String> _dates = ['Hôm nay', 'Ngày mai', 'Thứ Bảy', 'Chủ Nhật'];
  final List<String> _slots = [
    '16:00 - 17:30 (Trống)',
    '17:30 - 19:00 (Trống)',
    '19:00 - 20:30 (Trống)',
    '20:30 - 22:00 (Trống)',
  ];
  final List<String> _pitches = ['Sân 5A (5v5)', 'Sân 5B (5v5)', 'Sân 7A (7v7 VIP)'];

  // Duration in hours (1.5h per slot)
  final double _durationHours = 1.5;

  String _formatCurrency(int amount) {
    final buffer = StringBuffer();
    final str = amount.toString();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()}đ';
  }

  int get _fieldFee => (widget.field.pricePerHour * _durationHours).round();

  int get _refereeFee {
    if (!_wantReferee) return 0;
    final ref = _referees[_selectedRefereeIndex];
    return (ref.hourlyRate * _durationHours).round();
  }

  int get _equipmentFee {
    if (!_wantEquipment) return 0;
    int total = 0;
    for (final item in _rentals) {
      total += item.totalFee;
    }
    return total;
  }

  int get _totalAmount => _fieldFee + _refereeFee + _equipmentFee;

  int get _payableAmount {
    if (_paymentOption == 'FULL_PAYMENT') {
      return _totalAmount;
    }
    return (_totalAmount * _depositRate).round();
  }

  void _confirmBooking() async {
    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    final List<String> eqDescriptions = [];
    if (_wantEquipment) {
      for (final r in _rentals) {
        if (r.quantity > 0) {
          if (r.equipment.equipmentType == 'SHOES') {
            eqDescriptions.add('${r.quantity}x Giày (Size ${r.selectedSize})');
          } else {
            eqDescriptions.add('${r.quantity}x ${r.equipment.name}');
          }
        }
      }
    }

    final newBooking = BookingItemModel(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
      bookingCode: 'FB-${DateTime.now().millisecond + 1000}',
      fieldName: widget.field.name,
      subFieldName: _pitches[_selectedPitchIndex],
      date: '${_dates[_selectedDateIndex]}, ${_slots[_selectedSlotIndex].split(' ')[0]} - ${_slots[_selectedSlotIndex].split(' ')[2]}',
      time: '${_slots[_selectedSlotIndex].split(' ')[0]} - ${_slots[_selectedSlotIndex].split(' ')[2]}',
      totalAmount: _totalAmount,
      depositAmount: _payableAmount,
      status: 'confirmed',
      refereeName: _wantReferee
          ? '${_referees[_selectedRefereeIndex].name} (${_referees[_selectedRefereeIndex].level})'
          : null,
      equipmentList: eqDescriptions,
      paymentOption: _paymentOption,
    );

    Navigator.pop(context);
    widget.onBookingSuccess?.call(newBooking);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle & title
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.sports_soccer, color: Color(0xFF16A34A)),
                      const SizedBox(width: 8),
                      const Text(
                        'Đặt Sân Trực Tiếp',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field info card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.field.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.green.shade200,
                              child: const Icon(Icons.sports_soccer, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.field.name,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.field.address,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatCurrency(widget.field.pricePerHour)} / giờ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // STEP 1: Date & Time Slot
                  _buildSectionHeader('1. Chọn ngày & Khung giờ (Kiểm tra lịch trống)'),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_dates.length, (index) {
                        final isSelected = _selectedDateIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_dates[index]),
                            selected: isSelected,
                            selectedColor: Colors.green.shade600,
                            backgroundColor: Colors.grey.shade100,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade800,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                            onSelected: (_) => setState(() => _selectedDateIndex = index),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_slots.length, (index) {
                      final isSelected = _selectedSlotIndex == index;
                      return ChoiceChip(
                        avatar: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: isSelected ? Colors.white : Colors.green.shade600,
                        ),
                        label: Text(_slots[index]),
                        selected: isSelected,
                        selectedColor: Colors.green.shade600,
                        backgroundColor: Colors.grey.shade50,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade800,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        onSelected: (_) => setState(() => _selectedSlotIndex = index),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),

                  // STEP 2: Pitch Type
                  _buildSectionHeader('2. Chọn loại sân & Cụm sân'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(_pitches.length, (index) {
                      final isSelected = _selectedPitchIndex == index;
                      return ChoiceChip(
                        label: Text(_pitches[index]),
                        selected: isSelected,
                        selectedColor: Colors.green.shade600,
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade800,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        onSelected: (_) => setState(() => _selectedPitchIndex = index),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),

                  // STEP 3: Add Referee (FR13 - FR16)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('3. Thuê Trọng tài (Tùy chọn)'),
                      Switch(
                        value: _wantReferee,
                        activeThumbColor: const Color(0xFF16A34A),
                        onChanged: (val) => setState(() => _wantReferee = val),
                      ),
                    ],
                  ),
                  if (_wantReferee) ...[
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(_referees.length, (index) {
                        final ref = _referees[index];
                        final isSelected = _selectedRefereeIndex == index;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? const Color(0xFF16A34A) : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                          ),
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: NetworkImage(ref.avatarUrl),
                              onBackgroundImageError: (_, _) {},
                              child: const Icon(Icons.person, size: 20),
                            ),
                            title: Text(
                              ref.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            subtitle: Text(
                              '${ref.levelLabel} • ⭐ ${ref.rating} (${ref.matchesOfficiated} trận)',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            trailing: Text(
                              '${_formatCurrency(ref.hourlyRate)}/h',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                                fontSize: 13,
                              ),
                            ),
                            onTap: () => setState(() => _selectedRefereeIndex = index),
                          ),
                        );
                      }),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // STEP 4: Equipment Rental (FR34 - FR37)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('4. Thuê Dụng cụ & Giày bóng đá (Tùy chọn)'),
                      Switch(
                        value: _wantEquipment,
                        activeThumbColor: const Color(0xFF16A34A),
                        onChanged: (val) => setState(() => _wantEquipment = val),
                      ),
                    ],
                  ),
                  if (_wantEquipment) ...[
                    const SizedBox(height: 8),
                    Column(
                      children: _rentals.map((rental) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: rental.quantity > 0 ? const Color(0xFFF0FDF4) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: rental.quantity > 0 ? const Color(0xFF16A34A) : Colors.grey.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(rental.equipment.iconEmoji, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rental.equipment.name,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${_formatCurrency(rental.equipment.rentalPrice)} / lượt • Còn ${rental.equipment.availableQuantity}',
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Counter
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                                        onPressed: rental.quantity > 0
                                            ? () => setState(() => rental.quantity--)
                                            : null,
                                      ),
                                      Text(
                                        '${rental.quantity}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, size: 20),
                                        onPressed: rental.quantity < rental.equipment.availableQuantity
                                            ? () => setState(() => rental.quantity++)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Shoe size selection if equipment is shoes and quantity > 0
                              if (rental.equipment.equipmentType == 'SHOES' && rental.quantity > 0) ...[
                                const Divider(height: 12),
                                Row(
                                  children: [
                                    const Text('Chọn Size giày: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 6),
                                    Wrap(
                                      spacing: 6,
                                      children: rental.equipment.availableSizes.map((sz) {
                                        final isSz = rental.selectedSize == sz;
                                        return InkWell(
                                          onTap: () => setState(() => rental.selectedSize = sz),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isSz ? const Color(0xFF16A34A) : Colors.white,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: isSz ? const Color(0xFF16A34A) : Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Text(
                                              sz,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isSz ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // STEP 5: Payment Option (FR17)
                  _buildSectionHeader('5. Lựa chọn Thanh toán'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _paymentOption = 'DEPOSIT'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _paymentOption == 'DEPOSIT' ? const Color(0xFFF0FDF4) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _paymentOption == 'DEPOSIT' ? const Color(0xFF16A34A) : Colors.grey.shade200,
                                width: _paymentOption == 'DEPOSIT' ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _paymentOption == 'DEPOSIT' ? Icons.radio_button_checked : Icons.radio_button_off,
                                      color: const Color(0xFF16A34A),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('Đặt cọc 30%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCurrency((_totalAmount * _depositRate).round()),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _paymentOption = 'FULL_PAYMENT'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _paymentOption == 'FULL_PAYMENT' ? const Color(0xFFF0FDF4) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _paymentOption == 'FULL_PAYMENT' ? const Color(0xFF16A34A) : Colors.grey.shade200,
                                width: _paymentOption == 'FULL_PAYMENT' ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _paymentOption == 'FULL_PAYMENT' ? Icons.radio_button_checked : Icons.radio_button_off,
                                      color: const Color(0xFF16A34A),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('Trả 100%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCurrency(_totalAmount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // PRICING SUMMARY (FR16, FR37)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildPriceRow('Tiền thuê sân (1.5h):', _formatCurrency(_fieldFee)),
                        if (_wantReferee)
                          _buildPriceRow(
                            'Thuê trọng tài (${_referees[_selectedRefereeIndex].level}):',
                            _formatCurrency(_refereeFee),
                          ),
                        if (_wantEquipment && _equipmentFee > 0)
                          _buildPriceRow('Thuê dụng cụ & giày:', _formatCurrency(_equipmentFee)),
                        const Divider(height: 16),
                        _buildPriceRow(
                          'Tổng giá trị booking:',
                          _formatCurrency(_totalAmount),
                          isBold: true,
                        ),
                        const SizedBox(height: 4),
                        _buildPriceRow(
                          'Số tiền thanh toán ngay (${_paymentOption == 'DEPOSIT' ? 'Cọc 30%' : '100%'}):',
                          _formatCurrency(_payableAmount),
                          isHighlight: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Submit bar
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.tick_circle, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Xác nhận đặt giữ sân (${_formatCurrency(_payableAmount)})',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade900,
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold || isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? const Color(0xFF16A34A) : Colors.grey.shade800,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 15 : 13,
              fontWeight: isBold || isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight ? const Color(0xFF16A34A) : Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
