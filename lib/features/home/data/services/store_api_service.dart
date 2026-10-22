import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class StoreApiService {
  final Dio _dio;

  StoreApiService([Dio? dio]) : _dio = dio ?? DioClient.instance;

  Future<List<ProductModel>> getProducts({String? search, String? productType}) async {
    try {
      final queryParams = <String, dynamic>{
        'size': 50,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (productType != null && productType != 'Tất cả') {
        queryParams['productType'] = productType;
      }

      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.products,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data == null || data['result'] == null) {
        return ProductModel.mockProducts;
      }

      final result = data['result'] as Map<String, dynamic>;
      final content = result['content'] as List<dynamic>? ?? [];

      if (content.isEmpty) {
        return [];
      }

      return content.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      throw ApiException(message);
    } catch (e) {
      throw ApiException('Lỗi tải danh sách sản phẩm: $e');
    }
  }

  Future<ShoppingCartModel?> getCart() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.cart);
      final data = response.data;
      if (data == null || data['result'] == null) return null;
      return ShoppingCartModel.fromJson(data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null;
      }
      final message = _extractErrorMessage(e);
      throw ApiException(message);
    }
  }

  Future<ShoppingCartModel> addToCart(int productId, int quantity) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.cartItems,
        data: {
          'productId': productId,
          'quantity': quantity,
        },
      );
      final data = response.data;
      if (data == null || data['result'] == null) {
        throw const ApiException('Không nhận được dữ liệu giỏ hàng.');
      }
      return ShoppingCartModel.fromJson(data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<ShoppingCartModel> updateCartItem(int itemId, int quantity) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.cartItemById(itemId),
        data: {
          'quantity': quantity,
        },
      );
      final data = response.data;
      if (data == null || data['result'] == null) {
        throw const ApiException('Không nhận được dữ liệu giỏ hàng.');
      }
      return ShoppingCartModel.fromJson(data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<ShoppingCartModel> removeCartItem(int itemId) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        ApiEndpoints.cartItemById(itemId),
      );
      final data = response.data;
      if (data == null || data['result'] == null) {
        throw const ApiException('Không nhận được dữ liệu giỏ hàng.');
      }
      return ShoppingCartModel.fromJson(data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<void> clearCart() async {
    try {
      await _dio.delete<Map<String, dynamic>>(ApiEndpoints.cartClear);
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<OrderModel> checkoutOrder({String? note}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.orderCheckout,
        data: note != null ? {'note': note} : {},
      );
      final data = response.data;
      if (data == null || data['result'] == null) {
        throw const ApiException('Không tạo được đơn hàng.');
      }
      return OrderModel.fromJson(data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.myOrders);
      final data = response.data;
      if (data == null || data['result'] == null) return [];
      final result = data['result'] as Map<String, dynamic>;
      final content = result['content'] as List<dynamic>? ?? [];
      return content.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message'] as String?;
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
    }
    return e.message ?? 'Lỗi kết nối tới máy chủ';
  }
}
