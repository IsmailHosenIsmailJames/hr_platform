import 'package:flutter/material.dart';

import '../../../theme/break_point.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth > breakpoint
            ?
            // desktop view
            const Text("Desktop")
            :
            // mobile view
            const Text("Mobile");
      },
    );
  }
}
