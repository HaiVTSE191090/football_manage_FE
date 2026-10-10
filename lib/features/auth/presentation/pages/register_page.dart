import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import 'otp_verification_page.dart';
import '../../data/models/register_request.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/auth_api_service.dart';
import '../widgets/google_auth_coordinator.dart';
import '../widgets/google_sign_in_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _phoneController = TextEditingController();
  late final AuthRepository _authRepository;

  DateTime? _dateOfBirth;
  String? _gender;
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  bool _isGoogleSubmitting = false;
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();

    _authRepository = AuthRepository(
      apiService: AuthApiService(DioClient.instance),
      storageService: SecureStorageService.instance,
    );

    _listenToSupabaseAuth();
  }

  void _listenToSupabaseAuth() {
    if (!AppConfig.isSupabaseConfigured) return;
    try {
      _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        final session = data.session;
        if (event == AuthChangeEvent.signedIn && session != null) {
          _handleGoogleLoginSuccess(session.accessToken);
        }
      });
    } catch (e) {
      debugPrint('Supabase auth listener registration error: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!AppConfig.isSupabaseConfigured) {
      _showMessage('Supabase chưa được cấu hình. Vui lòng kiểm tra file .env.');
      return;
    }

    setState(() {
      _isGoogleSubmitting = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : AppConfig.supabaseRedirectUrl,
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _isGoogleSubmitting = false;
        });
        _showMessage('Không thể mở đăng nhập Google: $error');
      }
    }
  }

  Future<void> _handleGoogleLoginSuccess(String supabaseAccessToken) async {
    await GoogleAuthCoordinator.processSession(
      context: context,
      supabaseAccessToken: supabaseAccessToken,
      authRepository: _authRepository,
      setLoading: (loading) {
        if (mounted) {
          setState(() {
            _isGoogleSubmitting = loading;
          });
        }
      },
      showMessage: (msg) {
        if (mounted) {
          _showMessage(msg);
        }
      },
    );
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _avatarUrlController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate == null) return;

    setState(() {
      _dateOfBirth = pickedDate;
    });
  }

  Future<void> _submitRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _authRepository.register(
        RegisterRequest(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          dateOfBirth: _formattedDateOfBirth,
          gender: _gender ?? '',
          avatarUrl: _avatarUrlController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(
            verificationId: response.verificationId,
            email: _emailController.text.trim(),
            cooldownSeconds: response.cooldownSeconds,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String get _formattedDateOfBirth {
    final date = _dateOfBirth;
    if (date == null) return '';

    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Iconsax.arrow_left),
                  ),
                ),
                SizedBox(
                  height: 240,
                  child: Image.network(
                    'https://ouch-cdn2.icons8.com/fv7W4YUUpGVcNhmKcDGZp6pF1-IDEyCjSjtBB8-Kp_0/rs:fit:784:784/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvMTUv/ZjUzYTU4NDAtNjBl/Yy00ZWRhLWE1YWIt/ZGM1MWJmYjBiYjI2/LnN2Zw.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Iconsax.gallery_slash,
                        color: Colors.green,
                        size: 96,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Register your football field client account',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 28),
                _RegisterTextField(
                  controller: _fullNameController,
                  labelText: 'Full name',
                  hintText: 'Enter your full name',
                  icon: Iconsax.user,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _RegisterTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'user@example.com',
                  icon: Iconsax.sms,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return 'Please enter your email';
                    if (!email.contains('@')) return 'Email is invalid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _RegisterTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  icon: Iconsax.key,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                      color: Colors.black54,
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(value)) {
                      return 'Must include lowercase, uppercase, digit, and special char';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _DateOfBirthField(
                  value: _formattedDateOfBirth,
                  onTap: _pickDateOfBirth,
                  validator: () {
                    if (_dateOfBirth == null) {
                      return 'Please choose your date of birth';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: _inputDecoration(
                    labelText: 'Gender',
                    hintText: 'Choose your gender',
                    icon: Iconsax.profile_2user,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Male')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                    DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please choose your gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _RegisterTextField(
                  controller: _phoneController,
                  labelText: 'Phone',
                  hintText: '0914929545',
                  icon: Iconsax.call,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    final phone = value?.trim() ?? '';
                    if (phone.isEmpty) return 'Please enter your phone number';
                    if (!RegExp(r'^(0|\+84)[0-9]{9}$').hasMatch(phone)) return 'Phone number is invalid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _RegisterTextField(
                  controller: _avatarUrlController,
                  labelText: 'Avatar URL',
                  hintText: 'Optional avatar image URL',
                  icon: Iconsax.gallery,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 28),
                MaterialButton(
                  onPressed: (_isSubmitting || _isGoogleSubmitting) ? null : _submitRegister,
                  height: 48,
                  color: Colors.green,
                  disabledColor: Colors.green.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Register',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                ),
                const SizedBox(height: 20),
                const SocialAuthDivider(),
                const SizedBox(height: 20),
                GoogleSignInButton(
                  onPressed: (_isSubmitting || _isGoogleSubmitting) ? null : _signInWithGoogle,
                  isLoading: _isGoogleSubmitting,
                  text: 'Đăng ký với Google',
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateOfBirthField extends StatelessWidget {
  const _DateOfBirthField({
    required this.value,
    required this.onTap,
    required this.validator,
  });

  final String value;
  final VoidCallback onTap;
  final String? Function() validator;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (_) => validator(),
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(10.0),
              onTap: onTap,
              child: InputDecorator(
                decoration: _inputDecoration(
                  labelText: 'Date of birth',
                  hintText: 'YYYY-MM-DD',
                  icon: Iconsax.calendar,
                ).copyWith(errorText: field.errorText),
                child: Text(
                  value.isEmpty ? 'YYYY-MM-DD' : value,
                  style: TextStyle(
                    color: value.isEmpty ? Colors.grey : Colors.black,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RegisterTextField extends StatelessWidget {
  const _RegisterTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.black,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: _inputDecoration(
        labelText: labelText,
        hintText: hintText,
        icon: icon,
      ).copyWith(suffixIcon: suffixIcon),
    );
  }
}

InputDecoration _inputDecoration({
  required String labelText,
  required String hintText,
  required IconData icon,
}) {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(0.0),
    labelText: labelText,
    hintText: hintText,
    labelStyle: const TextStyle(
      color: Colors.black,
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
    ),
    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
    prefixIcon: Icon(icon, color: Colors.black, size: 18),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
      borderRadius: BorderRadius.circular(10.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
    floatingLabelStyle: const TextStyle(color: Colors.black, fontSize: 18.0),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black, width: 1.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
  );
}
