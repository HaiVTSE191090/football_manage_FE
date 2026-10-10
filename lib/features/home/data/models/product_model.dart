class ProductModel {
  final String id;
  final String name;
  final String productType; // 'DRINK', 'SOCKS', 'BALL', 'SPORTS_SET'
  final int price;
  final int availableQuantity;
  final String imageUrl;
  final String description;

  const ProductModel({
    required this.id,
    required this.name,
    required this.productType,
    required this.price,
    required this.availableQuantity,
    required this.imageUrl,
    required this.description,
  });

  static List<ProductModel> get mockProducts => const [
    ProductModel(
      id: 'prod_1',
      name: 'Nước bù khoáng Pocari Sweat 500ml',
      productType: 'DRINK',
      price: 15000,
      availableQuantity: 100,
      imageUrl: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=400&q=80',
      description: 'Bù nước và điện giải tối ưu trong khi thi đấu thể thao cường độ cao.',
    ),
    ProductModel(
      id: 'prod_2',
      name: 'Nước uống tăng lực Revive chanh muối',
      productType: 'DRINK',
      price: 12000,
      availableQuantity: 80,
      imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400&q=80',
      description: 'Giải khát cực đã, hồi phục thể lực nhanh chóng trên sân cỏ.',
    ),
    ProductModel(
      id: 'prod_3',
      name: 'Vớ bóng đá chống trượt Fox Feet cao cấp',
      productType: 'SOCKS',
      price: 45000,
      availableQuantity: 40,
      imageUrl: 'https://images.unsplash.com/photo-1582966772680-860e372bb558?w=400&q=80',
      description: 'Lớp đệm cao su silicon chống trơn trượt lòng bàn chân khi bứt tốc.',
    ),
    ProductModel(
      id: 'prod_4',
      name: 'Bóng đá chính hãng Molten Vantaggio 5000',
      productType: 'BALL',
      price: 420000,
      availableQuantity: 15,
      imageUrl: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400&q=80',
      description: 'Bóng đá thi đấu tiêu chuẩn FIFA Quality Pro, da PU cao cấp bền bỉ.',
    ),
    ProductModel(
      id: 'prod_5',
      name: 'Set quần áo thể thao thi đấu CLB phong trào',
      productType: 'SPORTS_SET',
      price: 160000,
      availableQuantity: 25,
      imageUrl: 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=400&q=80',
      description: 'Chất vải thun lạnh co giãn 4 chiều, thoáng khí, thấm hút mồ hôi cực tốt.',
    ),
  ];
}

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  int get itemAmount => product.price * quantity;
}
