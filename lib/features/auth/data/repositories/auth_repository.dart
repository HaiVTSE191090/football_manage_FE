import '../../../../core/storage/secure_storage_service.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/registration_response.dart';
import '../models/resend_email_request.dart';
import '../models/verify_email_request.dart';
import '../services/auth_api_service.dart';

class AuthRepository {
  const AuthRepository({
    required this.apiService,
    required this.storageService,
  });

  final AuthApiService apiService;
  final SecureStorageService storageService;

  Future<String> login(LoginRequest request) async {
    final response = await apiService.login(request);
    await storageService.saveAccessToken(response.accessToken);
    return response.accessToken;
  }

  Future<String> loginWithGoogle(String supabaseAccessToken) async {
    final response = await apiService.loginWithGoogle(supabaseAccessToken);
    await storageService.saveAccessToken(response.accessToken);
    return response.accessToken;
  }

  Future<RegistrationResponse> register(RegisterRequest request) async {
    return apiService.register(request);
  }

  Future<void> verifyEmail(VerifyEmailRequest request) async {
    return apiService.verifyEmail(request);
  }

  Future<RegistrationResponse> resendEmailVerification(ResendEmailRequest request) async {
    return apiService.resendEmailVerification(request);
  }
}
