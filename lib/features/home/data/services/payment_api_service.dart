import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/payment_model.dart';

class PaymentApiService {
  final Dio _dio;

  PaymentApiService([Dio? dio]) : _dio = dio ?? DioClient.instance;

  Future<PaymentModel> createPayment({
    int? bookingId,
    int? orderId,
    required String paymentType,
    required String paymentMethod,
    String? returnUrl,
  }) async {
    try {
      final body = <String, dynamic>{
        'paymentType': paymentType,
        'paymentMethod': paymentMethod,
      };
      if (bookingId != null) body['bookingId'] = bookingId;
      if (orderId != null) body['orderId'] = orderId;
      if (returnUrl != null && returnUrl.isNotEmpty) body['returnUrl'] = returnUrl;

      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.createPayment,
        data: body,
      );

      final data = response.data;
      if (data == null || data['result'] == null) {
        throw const ApiException('Khởi tạo thanh toán thất bại.');
      }

      return PaymentModel.fromJson(data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    } catch (e) {
      throw ApiException('Lỗi thanh toán: $e');
    }
  }

  Future<List<PaymentModel>> getMyPayments() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.myPayments);
      final data = response.data;
      if (data == null || data['result'] == null) return [];
      final result = data['result'] as Map<String, dynamic>;
      final content = result['content'] as List<dynamic>? ?? [];
      return content.map((e) => PaymentModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException(_extractErrorMessage(e));
    }
  }

  Future<PaymentModel> getPaymentDetail(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.paymentById(id));
      final data = response.data;
      if (data == null || data['result'] == null) {
        throw const ApiException('Không tìm thấy thông tin thanh toán.');
      }
      return PaymentModel.fromJson(data['result'] as Map<String, dynamic>);
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
