import 'package:flutter/material.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../data/repositories/auth_repository.dart';

class GoogleAuthCoordinator {
  const GoogleAuthCoordinator._();

  static bool _isProcessing = false;

  static Future<void> processSession({
    required BuildContext context,
    required String supabaseAccessToken,
    required AuthRepository authRepository,
    required void Function(bool isLoading) setLoading,
    required void Function(String message) showMessage,
  }) async {
    if (_isProcessing) return;
    _isProcessing = true;
    setLoading(true);

    try {
      await authRepository.loginWithGoogle(supabaseAccessToken);

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } catch (error) {
      if (!context.mounted) return;
      showMessage(error.toString());
    } finally {
      _isProcessing = false;
      if (context.mounted) {
        setLoading(false);
      }
    }
  }
}
