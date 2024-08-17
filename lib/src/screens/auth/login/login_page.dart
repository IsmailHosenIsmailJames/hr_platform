// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hr_platform/src/core/fluttertoast/fluttertoast_message.dart';
import 'package:hr_platform/src/theme/text_field_input_decoration.dart';

import '../../../theme/break_point.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();

  bool isIdLooksLikeEmail(String id) {
    return EmailValidator.validate(id);
  }

  Future<String?> loginUser(String id, String password) async {
    if (isIdLooksLikeEmail(id)) {
      String? result = await loginAdmin(id, password);
      if (result == null) {
        return null;
      } else {
        return result;
      }
    }
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      final response = await FirebaseFirestore.instance
          .collection('general_user')
          .doc(id)
          .get();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (response.exists) {
        Map temUserData = Map.from(response.data()!);
        String isSuspended = temUserData['isSuspanded'] ?? "false";
        if (isSuspended == "true") {
          showModalBottomSheet(
            context: context,
            builder: (context) => const Center(
              child: Text(
                "This user has been suspended",
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
          return "This user has been suspended";
        }
        var box = await Hive.openBox('info');
        await box.deleteFromDisk();
        box = await Hive.openBox('info');
        temUserData.addAll({"user_id": id});
        await box.put('userData', jsonEncode(temUserData));
        Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
        return null;
      } else {
        showFluttertoastMessage("User did not exits", context);
        return "User did not exits";
      }
    } catch (e) {
      showFluttertoastMessage("Something went worng", context);
      return "Something went worng";
    }
  }

  Future<String?> loginAdmin(String email, String password) async {
    try {
      final UserCredential result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (result.user != null) {
        final response = await FirebaseFirestore.instance
            .collection('admin')
            .doc('admin')
            .get();
        if (response.exists) {
          Map userData = response.data()!;
          Map<String, dynamic> adminData = Map<String, dynamic>.from(userData);
          var box = await Hive.openBox('info');
          await box.deleteFromDisk();
          box = await Hive.openBox('info');
          await box.put("userData", jsonEncode(adminData));
          Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
        } else {
          showFluttertoastMessage("Something went worng", context);
          return "Something went worng";
        }
      } else {
        showFluttertoastMessage("Email is not valid", context);
        return "Email is not valid";
      }
    } catch (e) {
      if (kDebugMode) {
        print("loginAdmin() error :  + $e");
      }
      showFluttertoastMessage("Something went worng. Unable to login", context);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Widget form = Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            controller: _idTextEditingController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(color: Colors.black),
            keyboardType: TextInputType.emailAddress,
            decoration:
                getInputDecooration("User ID", "Please type your ID here..."),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please type here your ID";
              }
              return null;
            },
          ),
          const Gap(10),
          TextFormField(
            controller: _passwordTextEditingController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(color: Colors.black),
            obscureText: true,
            decoration: getInputDecooration(
                "Password", "Please type your Password here..."),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please type here your ID";
              }
              return null;
            },
          ),
          const Gap(10),
          SizedBox(
            height: 50,
            width: 400,
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        ),
                      );
                    },
                  );

                  final String? result = await loginUser(
                    _idTextEditingController.text.trim(),
                    _passwordTextEditingController.text,
                  );

                  if (kDebugMode) {
                    print(result);
                  }

                  if (result == null) {
                    // login successfull
                    showFluttertoastMessage("Login successfull", context);
                  } else {
                    // something worng
                    showFluttertoastMessage(result, context);
                  }

                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Login"),
            ),
          ),
        ],
      ),
    );

    final Widget decoratedForm = ClipRRect(
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        width: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Login",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const Gap(30),
            form,
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth > breakPointWidth
            ?
            // desktop view
            Scaffold(
                backgroundColor: Colors.blue.shade800,
                body: Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: SizedBox(
                              height: 400,
                              width: 400,
                              child: Image.asset(
                                "assets/radiant_logo.636da2b1.png",
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: decoratedForm,
                      ),
                    ],
                  ),
                ),
              )
            :
            // mobile view
            Scaffold(
                backgroundColor: Colors.blue.shade800,
                body: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 100,
                          width: 250,
                          child: Image.asset(
                            "assets/radiant_logo.636da2b1.png",
                          ),
                        ),
                        const Gap(20),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: decoratedForm,
                        ),
                      ],
                    ),
                  ),
                ),
              );
      },
    );
  }
}
