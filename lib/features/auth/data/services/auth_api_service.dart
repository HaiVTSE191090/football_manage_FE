import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/registration_response.dart';
import '../models/resend_email_request.dart';
import '../models/verify_email_request.dart';

class AuthApiService {
  const AuthApiService(this._dio);

  final Dio _dio;

  Future<LoginResponse> login(LoginRequest request) async {
    final data = await _postRequest(ApiEndpoints.login, request.toJson());
    final result = data['result'] as Map<String, dynamic>?;
    if (result == null || (result['accessToken'] ?? '').toString().isEmpty) {
      throw const ApiException('Authentication failed: Missing access token.');
    }
    return LoginResponse.fromJson(result);
  }

  Future<LoginResponse> loginWithGoogle(String supabaseAccessToken) async {
    final data = await _postRequest(ApiEndpoints.googleLogin, {
      'accessToken': supabaseAccessToken,
    });
    final result = data['result'] as Map<String, dynamic>?;
    if (result == null || (result['accessToken'] ?? '').toString().isEmpty) {
      throw const ApiException('Google authentication failed: Missing access token.');
    }
    return LoginResponse.fromJson(result);
  }

  Future<RegistrationResponse> register(RegisterRequest request) async {
    final data = await _postRequest(ApiEndpoints.register, request.toJson());
    final result = data['result'] as Map<String, dynamic>?;
    if (result == null || (result['verificationId'] ?? '').toString().isEmpty) {
      throw const ApiException('Registration failed: Missing verification ID.');
    }
    return RegistrationResponse.fromJson(result);
  }

  Future<void> verifyEmail(VerifyEmailRequest request) async {
    await _postRequest(ApiEndpoints.verifyEmail, request.toJson());
  }

  Future<RegistrationResponse> resendEmailVerification(ResendEmailRequest request) async {
    final data = await _postRequest(ApiEndpoints.resendEmail, request.toJson());
    final result = data['result'] as Map<String, dynamic>?;
    if (result == null || (result['verificationId'] ?? '').toString().isEmpty) {
      throw const ApiException('Resend failed: Missing verification ID.');
    }
    return RegistrationResponse.fromJson(result);
  }

  Future<Map<String, dynamic>> _postRequest(String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('Server did not return data.');
      }

      final success = data['success'] as bool? ?? false;
      if (!success && response.statusCode != 200 && response.statusCode != 202) {
        throw ApiException(data['message'] ?? 'Request failed.');
      }

      return data;
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] as String?;
        if (message != null && message.isNotEmpty) {
          throw ApiException(message);
        }
      }

      throw ApiException(error.message ?? 'Could not connect to server.');
    }
  }
}
