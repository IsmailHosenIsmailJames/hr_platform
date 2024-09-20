// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hr_platform/src/auth/is_authenticated.dart';
import 'package:hr_platform/src/screens/home/home_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Initialization extends StatefulWidget {
  final String? namePath;
  const Initialization({super.key, this.namePath});

  @override
  State<Initialization> createState() => _InitializationState();
}

class _InitializationState extends State<Initialization> {
  @override
  void initState() {
    if (!isAuthenticated()) {
      goToLoginPage();
    } else {
      getMappedData();
    }
    super.initState();
  }

  Future<void> goToLoginPage() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => true);
  }

  Future<void> getMappedData() async {
    final response = await FirebaseFirestore.instance
        .collection('data')
        .doc('data-map')
        .get();
    if (response.exists) {
      await Hive.box('info').put('data', jsonEncode(response.data() ?? {}));
    } else {
      await Hive.box('info').put('data', jsonEncode({}));
    }
    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(path: widget.namePath ?? "/"),
          settings: RouteSettings(name: widget.namePath ?? "/"),
        ),
        (route) => true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.blue.shade800, size: 40),
      ),
    );
  }
}
