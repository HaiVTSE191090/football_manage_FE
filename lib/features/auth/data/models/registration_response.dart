class RegistrationResponse {
  const RegistrationResponse({
    required this.verificationId,
    required this.emailVerified,
    required this.cooldownSeconds,
    required this.expiresInSeconds,
  });

  final String verificationId;
  final bool emailVerified;
  final int cooldownSeconds;
  final int expiresInSeconds;

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      verificationId: json['verificationId'] as String? ?? '',
      emailVerified: json['emailVerified'] as bool? ?? false,
      cooldownSeconds: json['cooldownSeconds'] as int? ?? 60,
      expiresInSeconds: json['expiresInSeconds'] as int? ?? 300,
    );
  }
}
