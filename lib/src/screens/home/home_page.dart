import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hr_platform/src/core/fluttertoast/fluttertoast_message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    }
    await Hive.box("info").delete("userData");
    // ignore: use_build_context_synchronously
    context.go("/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await logout();
            showFluttertoastMessage("Logout successfull");
          },
          child: const Text("Logout"),
        ),
      ),
    );
  }
}
