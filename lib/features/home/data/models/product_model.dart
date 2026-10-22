class ProductModel {
  final int id;
  final String name;
  final String productType; // 'BEVERAGE', 'SOCKS', 'BALL', 'SPORTS_SET', 'EQUIPMENT'
  final int price;
  final int availableQuantity;
  final String imageUrl;
  final String description;
  final bool isActive;

  const ProductModel({
    required this.id,
    required this.name,
    required this.productType,
    required this.price,
    required this.availableQuantity,
    this.imageUrl = '',
    this.description = '',
    this.isActive = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['productId'] ?? json['id'] ?? 0;
    final int id = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    final rawPrice = json['price'] ?? 0;
    final int price = rawPrice is num ? rawPrice.toInt() : (double.tryParse(rawPrice.toString())?.toInt() ?? 0);

    final rawQty = json['quantity'] ?? json['availableQuantity'] ?? 0;
    final int availableQuantity = rawQty is int ? rawQty : int.tryParse(rawQty.toString()) ?? 0;

    return ProductModel(
      id: id,
      name: json['name'] as String? ?? 'Sản phẩm',
      productType: json['productType'] as String? ?? 'OTHER',
      price: price,
      availableQuantity: availableQuantity,
      imageUrl: _fallbackImageUrl(json['productType'] as String? ?? ''),
      description: json['description'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static String _fallbackImageUrl(String type) {
    switch (type.toUpperCase()) {
      case 'DRINK':
      case 'BEVERAGE':
        return 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=400&q=80';
      case 'SOCKS':
        return 'https://images.unsplash.com/photo-1582966772680-860e372bb558?w=400&q=80';
      case 'BALL':
        return 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400&q=80';
      case 'SPORTS_SET':
      case 'EQUIPMENT':
        return 'https://images.unsplash.com/photo-1517466787929-bc90951d0974?w=400&q=80';
      default:
        return 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=400&q=80';
    }
  }

  static List<ProductModel> get mockProducts => const [
    ProductModel(
      id: 1,
      name: 'Nước bù khoáng Pocari Sweat 500ml',
      productType: 'BEVERAGE',
      price: 15000,
      availableQuantity: 100,
      imageUrl: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=400&q=80',
      description: 'Bù nước và điện giải tối ưu trong khi thi đấu thể thao cường độ cao.',
    ),
    ProductModel(
      id: 2,
      name: 'Nước uống tăng lực Revive chanh muối',
      productType: 'BEVERAGE',
      price: 12000,
      availableQuantity: 80,
      imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400&q=80',
      description: 'Giải khát cực đã, hồi phục thể lực nhanh chóng trên sân cỏ.',
    ),
    ProductModel(
      id: 3,
      name: 'Vớ bóng đá chống trượt Fox Feet cao cấp',
      productType: 'SOCKS',
      price: 45000,
      availableQuantity: 40,
      imageUrl: 'https://images.unsplash.com/photo-1582966772680-860e372bb558?w=400&q=80',
      description: 'Lớp đệm cao su silicon chống trơn trượt lòng bàn chân khi bứt tốc.',
    ),
    ProductModel(
      id: 4,
      name: 'Bóng đá chính hãng Molten Vantaggio 5000',
      productType: 'BALL',
      price: 420000,
      availableQuantity: 15,
      imageUrl: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400&q=80',
      description: 'Bóng đá thi đấu tiêu chuẩn FIFA Quality Pro, da PU cao cấp bền bỉ.',
    ),
    ProductModel(
      id: 5,
      name: 'Set quần áo thể thao thi đấu CLB phong trào',
      productType: 'SPORTS_SET',
      price: 180000,
      availableQuantity: 25,
      imageUrl: 'https://images.unsplash.com/photo-1517466787929-bc90951d0974?w=400&q=80',
      description: 'Chất vải mè thể thao thoáng khí, thấm hút mồ hôi, co giãn 4 chiều.',
    ),
  ];
}

class CartItemModel {
  final int cartItemId;
  final ProductModel product;
  int quantity;
  final int unitPrice;

  CartItemModel({
    this.cartItemId = 0,
    required this.product,
    required this.quantity,
    int? unitPrice,
  }) : unitPrice = unitPrice ?? product.price;

  int get itemAmount => unitPrice * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final rawItemId = json['cartItemId'] ?? 0;
    final int cartItemId = rawItemId is int ? rawItemId : int.tryParse(rawItemId.toString()) ?? 0;

    final rawQty = json['quantity'] ?? 1;
    final int quantity = rawQty is int ? rawQty : int.tryParse(rawQty.toString()) ?? 1;

    final rawPrice = json['unitPrice'] ?? 0;
    final int unitPrice = rawPrice is num ? rawPrice.toInt() : (double.tryParse(rawPrice.toString())?.toInt() ?? 0);

    final product = ProductModel(
      id: json['productId'] is int ? json['productId'] : int.tryParse((json['productId'] ?? 0).toString()) ?? 0,
      name: json['productName'] as String? ?? 'Sản phẩm',
      productType: json['productType'] as String? ?? 'OTHER',
      price: unitPrice,
      availableQuantity: 999,
      imageUrl: ProductModel._fallbackImageUrl(json['productType'] as String? ?? ''),
    );

    return CartItemModel(
      cartItemId: cartItemId,
      product: product,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }
}

class ShoppingCartModel {
  final int cartId;
  final List<CartItemModel> items;
  final int totalItems;
  final int totalAmount;

  const ShoppingCartModel({
    required this.cartId,
    required this.items,
    required this.totalItems,
    required this.totalAmount,
  });

  factory ShoppingCartModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['cartId'] ?? 0;
    final int cartId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    final rawTotalAmount = json['totalAmount'] ?? 0;
    final int totalAmount = rawTotalAmount is num ? rawTotalAmount.toInt() : (double.tryParse(rawTotalAmount.toString())?.toInt() ?? 0);

    final rawTotalItems = json['totalItems'] ?? 0;
    final int totalItems = rawTotalItems is int ? rawTotalItems : int.tryParse(rawTotalItems.toString()) ?? 0;

    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();

    return ShoppingCartModel(
      cartId: cartId,
      items: items,
      totalItems: totalItems,
      totalAmount: totalAmount,
    );
  }
}
