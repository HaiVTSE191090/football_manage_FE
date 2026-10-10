class VerifyEmailRequest {
  const VerifyEmailRequest({
    required this.verificationId,
    required this.otp,
  });

  final String verificationId;
  final String otp;

  Map<String, dynamic> toJson() {
    return {
      'verificationId': verificationId,
      'otp': otp,
    };
  }
}
