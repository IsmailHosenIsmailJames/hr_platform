import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:hr_platform/src/core/fluttertoast/fluttertoast_message.dart';
import 'package:hr_platform/src/core/initialization/init.dart';

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

    final response =
        await FirebaseFirestore.instance.collection('user').doc('user').get();
    if (response.exists) {
      Map<String, dynamic> allUserData =
          Map<String, dynamic>.from(response.data()!);
      List<Map> userList = List<Map>.from(allUserData['user-list']);
      for (Map user in userList) {
        String temId = user['id'] ?? '';
        String temPass = user['password'] ?? '';
        if (temId == id && temPass == password) {
          Map<String, dynamic> thisUser = Map<String, dynamic>.from(user);
          await Hive.box('info').put('userData', thisUser);
          Navigator.pushAndRemoveUntil(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => const Init(),
            ),
            (route) => true,
          );
          return null;
        }
      }
    }
    return "User did not exits";
  }

  Future<String?> loginAdmin(String email, String password) async {
    try {
      final UserCredential result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (result.user != null) {
        final response = await FirebaseFirestore.instance
            .collection('user')
            .doc('admin')
            .get();
        if (response.exists) {
          Map userData = response.data()!;
          Map<String, dynamic> adminData = userData['data'];
          Hive.box('info').put("userData", adminData);
        } else {
          return "Something went worng";
        }
      } else {
        return "Email is not valid";
      }
    } catch (e) {
      if (kDebugMode) {
        print("loginAdmin() error :  + $e");
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Widget form = Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _idTextEditingController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final String? result = await loginUser(
                    _idTextEditingController.text.trim(),
                    _passwordTextEditingController.text,
                  );

                  if (result == null) {
                    // login successfull
                    showFluttertoastMessage("Login successfull");
                  } else {
                    // something worng
                    showFluttertoastMessage(result);
                  }
                }
              },
              child: const Text("Login"),
            ),
          ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth > breakpoint
            ?
            // desktop view
            Scaffold(
                body: Center(
                  child: form,
                ),
              )
            :
            // mobile view
            Scaffold(
                body: Center(
                  child: form,
                ),
              );
      },
    );
  }
}
