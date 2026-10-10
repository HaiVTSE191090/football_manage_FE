class EquipmentItem {
  final String id;
  final String name;
  final String equipmentType; // 'FOOTBALL', 'SHOES', 'GLOVES', 'BIBS'
  final int rentalPrice;
  final int availableQuantity;
  final List<String> availableSizes;
  final String iconEmoji;

  const EquipmentItem({
    required this.id,
    required this.name,
    required this.equipmentType,
    required this.rentalPrice,
    required this.availableQuantity,
    this.availableSizes = const [],
    this.iconEmoji = '⚽',
  });

  static List<EquipmentItem> get defaultEquipmentList => const [
    EquipmentItem(
      id: 'eq_ball',
      name: 'Bóng đá thi đấu FIFA Quality',
      equipmentType: 'FOOTBALL',
      rentalPrice: 30000,
      availableQuantity: 20,
      iconEmoji: '⚽',
    ),
    EquipmentItem(
      id: 'eq_shoes',
      name: 'Giày đá bóng sân cỏ nhân tạo (Đủ size)',
      equipmentType: 'SHOES',
      rentalPrice: 50000,
      availableQuantity: 35,
      availableSizes: ['39', '40', '41', '42', '43'],
      iconEmoji: '👟',
    ),
    EquipmentItem(
      id: 'eq_gloves',
      name: 'Găng tay thủ môn dính bóng cao cấp',
      equipmentType: 'GLOVES',
      rentalPrice: 30000,
      availableQuantity: 12,
      iconEmoji: '🧤',
    ),
    EquipmentItem(
      id: 'eq_bibs',
      name: 'Bộ áo bib chia đội (10 áo)',
      equipmentType: 'BIBS',
      rentalPrice: 20000,
      availableQuantity: 15,
      iconEmoji: '🎽',
    ),
  ];
}

class RentalSelection {
  final EquipmentItem equipment;
  int quantity;
  String? selectedSize;

  RentalSelection({
    required this.equipment,
    this.quantity = 0,
    this.selectedSize,
  });

  int get totalFee => equipment.rentalPrice * quantity;
}
