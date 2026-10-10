class AuthResponse {
  const AuthResponse({
    required this.code,
    required this.success,
    required this.message,
    required this.accessToken,
  });

  final int? code;
  final bool success;
  final String? message;
  final String accessToken;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>?;

    return AuthResponse(
      code: json['code'] as int?,
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      accessToken: result?['accessToken'] as String? ?? '',
    );
  }
}
