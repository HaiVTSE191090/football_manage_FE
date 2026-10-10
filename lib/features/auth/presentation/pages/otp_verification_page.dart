import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/models/resend_email_request.dart';
import '../../data/models/verify_email_request.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/auth_api_service.dart';
import 'login_page.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.verificationId,
    required this.email,
    required this.cooldownSeconds,
  });

  final String verificationId;
  final String email;
  final int cooldownSeconds;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  late final AuthRepository _authRepository;
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  late String _currentVerificationId;
  int _countdown = 0;
  Timer? _timer;
  bool _isSubmitting = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(
      apiService: AuthApiService(DioClient.instance),
      storageService: SecureStorageService.instance,
    );
    _currentVerificationId = widget.verificationId;
    _startCooldown(widget.cooldownSeconds);
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _startCooldown(int seconds) {
    setState(() {
      _countdown = seconds;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authRepository.verifyEmail(
        VerifyEmailRequest(
          verificationId: _currentVerificationId,
          otp: _otpController.text.trim(),
        ),
      );

      if (!mounted) return;
      _showMessage('Email verified successfully! Please login.');
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
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

  Future<void> _resendOtp() async {
    if (_countdown > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      final response = await _authRepository.resendEmailVerification(
        ResendEmailRequest(verificationId: _currentVerificationId),
      );
      
      if (!mounted) return;
      
      setState(() {
        _currentVerificationId = response.verificationId;
      });
      _startCooldown(response.cooldownSeconds);
      _showMessage('A new verification code has been sent.');
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.sms_tracking, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                Text(
                  'Nhập 6 mã số đã được gửi tới:\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                FormField<String>(
                  validator: (_) {
                    final otp = _otpController.text.trim();
                    if (otp.isEmpty) return 'Vui lòng nhập mã OTP';
                    if (otp.length != 6 || int.tryParse(otp) == null) {
                      return 'Mã OTP phải bao gồm đúng 6 chữ số';
                    }
                    return null;
                  },
                  builder: (fieldState) {
                    final hasError = fieldState.hasError;
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () => _focusNode.requestFocus(),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 6 individual pin boxes
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  6,
                                  (index) => _buildOtpBox(
                                    index: index,
                                    hasError: hasError,
                                  ),
                                ),
                              ),
                              // Invisible TextField over the boxes to handle keyboard & paste seamlessly
                              Positioned.fill(
                                child: TextField(
                                  controller: _otpController,
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  showCursor: false,
                                  enableInteractiveSelection: true,
                                  cursorColor: Colors.transparent,
                                  style: const TextStyle(
                                    color: Colors.transparent,
                                    fontSize: 1,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    fillColor: Colors.transparent,
                                    filled: false,
                                  ),
                                  onChanged: (val) {
                                    fieldState.didChange(val);
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hasError) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 16,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                fieldState.errorText ?? '',
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                MaterialButton(
                  onPressed: _isSubmitting ? null : _verifyOtp,
                  color: Colors.green,
                  disabledColor: Colors.green.shade200,
                  height: 48,
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
                          'Verify',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _countdown > 0 
                        ? 'Resend code in $_countdown s' 
                        : 'Didn\'t receive the code?',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    if (_countdown == 0)
                      TextButton(
                        onPressed: _isResending ? null : _resendOtp,
                        child: _isResending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Resend', style: TextStyle(color: Colors.blue)),
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

  Widget _buildOtpBox({
    required int index,
    required bool hasError,
  }) {
    final otpText = _otpController.text;
    final isFocused = _focusNode.hasFocus;
    final isCurrentIndex = otpText.length == index;
    final isBoxActive = isFocused && (isCurrentIndex || (otpText.length == 6 && index == 5));
    final hasValue = index < otpText.length;
    final char = hasValue ? otpText[index] : '';

    Color borderColor;
    Color backgroundColor;
    double borderWidth = 1.2;

    if (hasError) {
      borderColor = Colors.redAccent;
      backgroundColor = Colors.red.shade50.withValues(alpha: 0.25);
      borderWidth = 1.5;
    } else if (isBoxActive) {
      borderColor = Colors.green.shade600;
      backgroundColor = Colors.white;
      borderWidth = 2.0;
    } else if (hasValue) {
      borderColor = Colors.green.shade500;
      backgroundColor = Colors.green.shade50.withValues(alpha: 0.4);
      borderWidth = 1.5;
    } else {
      borderColor = Colors.grey.shade300;
      backgroundColor = Colors.grey.shade50;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 46,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: isBoxActive && !hasError
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(
        child: hasValue
            ? Text(
                char,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: hasError ? Colors.redAccent : Colors.grey.shade900,
                ),
              )
            : (isBoxActive && !hasError
                ? Container(
                    width: 2,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  )
                : Text(
                    '•',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
      ),
    );
  }
}

