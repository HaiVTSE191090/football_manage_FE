class ResendEmailRequest {
  const ResendEmailRequest({
    required this.verificationId,
  });

  final String verificationId;

  Map<String, dynamic> toJson() {
    return {
      'verificationId': verificationId,
    };
  }
}
