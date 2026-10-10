class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  String? _accessToken;

  Future<void> saveAccessToken(String token) async {
    _accessToken = token;
  }

  Future<String?> getAccessToken() async {
    return _accessToken;
  }

  Future<void> clearAccessToken() async {
    _accessToken = null;
  }
}
