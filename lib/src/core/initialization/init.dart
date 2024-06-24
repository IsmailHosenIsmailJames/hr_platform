import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../screens/auth/login/login_page.dart';
import '../../screens/home/home_page.dart';

class Init extends StatelessWidget {
  const Init({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Hive.box('info').get('userData', defaultValue: null);
    return data == null ? const LoginPage() : const HomePage();
  }
}
