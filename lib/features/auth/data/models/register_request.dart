class RegisterRequest {
  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.dateOfBirth,
    required this.gender,
    required this.phone,
    this.avatarUrl,
  });

  final String fullName;
  final String email;
  final String password;
  final String dateOfBirth;
  final String gender;
  final String phone;
  final String? avatarUrl;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      if (avatarUrl != null && avatarUrl!.isNotEmpty) 'avatarUrl': avatarUrl,
      'phone': phone,
    };
  }
}
