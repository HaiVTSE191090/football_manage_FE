import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,// nếu ae có làm cái phần mà thay đổi nền trắng đen thì hải sẽ gọi cái này lại.
      home: const LoginPage(),
    );
  }
}
