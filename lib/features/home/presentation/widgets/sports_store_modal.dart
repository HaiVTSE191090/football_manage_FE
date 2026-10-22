import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../../data/services/store_api_service.dart';
import 'payment_method_sheet.dart';

class SportsStoreModal extends StatefulWidget {
  const SportsStoreModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SportsStoreModal(),
    );
  }

  @override
  State<SportsStoreModal> createState() => _SportsStoreModalState();
}

class _SportsStoreModalState extends State<SportsStoreModal> {
  final StoreApiService _storeService = StoreApiService();

  List<ProductModel> _products = [];
  List<CartItemModel> _cartItems = [];

  bool _isLoadingProducts = true;
  bool _isLoadingCart = false;
  bool _showingCartView = false;
  bool _isCheckingOut = false;

  String _selectedCategory = 'Tất cả';
  final List<String> _categories = [
    'Tất cả',
    'Nước uống',
    'Vớ & Phụ kiện',
    'Bóng thi đấu',
    'Trang phục',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCart();
  }

  String? _mapCategoryToBackend(String category) {
    switch (category) {
      case 'Nước uống':
        return 'BEVERAGE';
      case 'Vớ & Phụ kiện':
        return 'SOCKS';
      case 'Bóng thi đấu':
        return 'BALL';
      case 'Trang phục':
        return 'SPORTS_SET';
      default:
        return null;
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final backendType = _mapCategoryToBackend(_selectedCategory);
      final list = await _storeService.getProducts(productType: backendType);
      if (mounted) {
        setState(() {
          _products = list.isNotEmpty ? list : ProductModel.mockProducts;
          _isLoadingProducts = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _products = ProductModel.mockProducts;
          _isLoadingProducts = false;
        });
      }
    }
  }

  Future<void> _loadCart() async {
    setState(() => _isLoadingCart = true);
    try {
      final cart = await _storeService.getCart();
      if (mounted && cart != null) {
        setState(() {
          _cartItems = cart.items;
          _isLoadingCart = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingCart = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCart = false);
      }
    }
  }

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

  int get _cartTotal {
    int sum = 0;
    for (final item in _cartItems) {
      sum += item.itemAmount;
    }
    return sum;
  }

  int get _cartItemCount {
    int count = 0;
    for (final item in _cartItems) {
      count += item.quantity;
    }
    return count;
  }

  Future<void> _addToCart(ProductModel product) async {
    // Optimistic UI update
    setState(() {
      final index = _cartItems.indexWhere((c) => c.product.id == product.id);
      if (index != -1) {
        _cartItems[index].quantity++;
      } else {
        _cartItems.add(CartItemModel(product: product, quantity: 1));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${product.name} vào giỏ hàng!'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final updatedCart = await _storeService.addToCart(product.id, 1);
      if (mounted) {
        setState(() {
          _cartItems = updatedCart.items;
        });
      }
    } catch (e) {
      // Local addition remains as fallback
    }
  }

  Future<void> _updateQuantity(int index, int delta) async {
    final item = _cartItems[index];
    final newQty = item.quantity + delta;

    if (newQty <= 0) {
      setState(() {
        _cartItems.removeAt(index);
      });
      if (item.cartItemId > 0) {
        try {
          await _storeService.removeCartItem(item.cartItemId);
        } catch (_) {}
      }
    } else {
      setState(() {
        item.quantity = newQty;
      });
      if (item.cartItemId > 0) {
        try {
          await _storeService.updateCartItem(item.cartItemId, newQty);
        } catch (_) {}
      }
    }
  }

  Future<void> _checkout() async {
    if (_cartItems.isEmpty) return;

    setState(() => _isCheckingOut = true);

    try {
      final OrderModel order = await _storeService.checkoutOrder(
        note: 'Đặt mua đồ dùng / nước uống trực tiếp qua ứng dụng',
      );

      if (!mounted) return;

      setState(() {
        _isCheckingOut = false;
        _cartItems.clear();
      });

      // Close store modal first
      Navigator.pop(context);

      // Open PaymentMethodSheet for the created order (BR37 & BR38)
      PaymentMethodSheet.show(
        context: context,
        title: 'Thanh Toán Đơn Mua Hàng #${order.orderCode}',
        amount: order.finalAmount > 0 ? order.finalAmount : order.totalAmount,
        orderId: order.orderId,
        paymentType: 'FULL',
        onPaymentCompleted: (payment) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
                  SizedBox(width: 8),
                  Text('Đặt Mua Thành Công!'),
                ],
              ),
              content: Text(
                'Đơn hàng #${order.orderCode} đã được ghi nhận. Bạn có thể nhận đồ trực tiếp tại quầy tiếp tân hoặc yêu cầu mang ra sân khi thi đấu.',
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Xác nhận'),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade600,
            content: Text('Không thể đặt đơn hàng: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 14, left: 20, right: 20, bottom: 8),
            child: Row(
              children: [
                Icon(
                  _showingCartView ? Iconsax.shopping_cart : Iconsax.shop,
                  color: const Color(0xFF16A34A),
                ),
                const SizedBox(width: 10),
                Text(
                  _showingCartView ? 'Giỏ Hàng Của Bạn' : 'Cửa Hàng Thể Thao & Nước',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // Cart button with badge
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        _showingCartView ? Icons.storefront_rounded : Iconsax.shopping_cart,
                        color: Colors.grey.shade800,
                      ),
                      onPressed: () => setState(() => _showingCartView = !_showingCartView),
                    ),
                    if (_cartItemCount > 0 && !_showingCartView)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$_cartItemCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Category Selector (when in catalog view)
          if (!_showingCartView)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF16A34A),
                    backgroundColor: Colors.grey.shade100,
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                        _loadProducts();
                      }
                    },
                  );
                },
              ),
            ),

          if (!_showingCartView) const Divider(height: 1),

          // Main View (Catalog vs Cart)
          Expanded(
            child: _showingCartView ? _buildCartView() : _buildCatalogView(),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogView() {
    if (_isLoadingProducts) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF16A34A)),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.box, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              'Không tìm thấy sản phẩm phù hợp',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = _products[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  p.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      p.description.isNotEmpty ? p.description : 'Sản phẩm chính hãng chất lượng cao',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatPrice(p.price),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _addToCart(p),
                          icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                          label: const Text('Thêm', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartView() {
    if (_isLoadingCart) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF16A34A)),
      );
    }

    if (_cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.shopping_cart, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              'Giỏ hàng của bạn đang trống',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
              ),
              onPressed: () => setState(() => _showingCartView = false),
              child: const Text('Khám phá sản phẩm'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _cartItems.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.sports_soccer),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatPrice(item.unitPrice)} x ${item.quantity}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: () => _updateQuantity(index, -1),
                        ),
                        Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: () => _updateQuantity(index, 1),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Cart Summary & Checkout button (FR41)
        Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng tiền đơn hàng:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(
                    _formatPrice(_cartTotal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isCheckingOut ? null : _checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isCheckingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Thanh Toán Đơn Mua Hàng',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
