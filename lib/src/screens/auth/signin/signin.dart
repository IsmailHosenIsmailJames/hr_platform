import 'package:flutter/material.dart';

import '../../../theme/break_point.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
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
