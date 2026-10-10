class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final String tokenType;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }
}
