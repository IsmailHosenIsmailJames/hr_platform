import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hr_platform/src/models/user_model.dart';
import 'package:hr_platform/src/screens/add_user/add_user.dart';
import 'package:hr_platform/src/screens/edit_profile/edit_profile.dart';
import 'package:hr_platform/src/screens/home/suspended_user/suspended_user.dart';
import 'package:hr_platform/src/screens/survey/all_survey.dart';
import 'package:hr_platform/src/screens/survey/getx/controller_getx.dart';
import 'package:hr_platform/src/screens/survey/models/surevey_question_model.dart';
import 'package:hr_platform/src/screens/survey/survey.dart';

class MyDrawer extends StatelessWidget {
  final bool isAdmin;
  const MyDrawer({
    super.key,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('info');
    UserModel? userModel =
        (!isAdmin) ? UserModel.fromJson(box.get('userData')) : null;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            if (!isAdmin)
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.blue.shade800,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Text(
                        userModel!.userName!,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      "ID: ${userModel.userID ?? ""}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(userModel.cellPhone ?? ""),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  if (FirebaseAuth.instance.currentUser!.email != null &&
                      FirebaseAuth.instance.currentUser!.email!.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const AddUser();
                            },
                          ),
                        );
                      },
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Add user",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      icon: const Icon(FluentIcons.add_24_filled),
                    ),
                  if (FirebaseAuth.instance.currentUser!.email != null &&
                      FirebaseAuth.instance.currentUser!.email!.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        final tem = Get.put(SurveyController());
                        tem.survey.value = SureveyModel(
                          id: getRandomValue(),
                          title: "",
                          description: "",
                          date: DateTime.now().millisecondsSinceEpoch,
                          questions: <Question>[],
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const Survey();
                            },
                          ),
                        );
                      },
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Create a Survey",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      icon: const Icon(FluentIcons.document_table_24_regular),
                    ),
                  if (FirebaseAuth.instance.currentUser!.email != null &&
                      FirebaseAuth.instance.currentUser!.email!.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const SuspendedUser();
                            },
                          ),
                        );
                      },
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Suspended User",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      icon: const Icon(FluentIcons.document_table_24_regular),
                    ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const AllSurvey();
                          },
                        ),
                      );
                    },
                    label: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "All Survey",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    icon: const Icon(FluentIcons.document_table_24_regular),
                  ),
                  if (!(FirebaseAuth.instance.currentUser!.email != null &&
                      FirebaseAuth.instance.currentUser!.email!.isNotEmpty))
                    TextButton.icon(
                      onPressed: () async {
                        final box = await Hive.openBox('info');
                        UserModel userModel =
                            UserModel.fromJson(box.get('userData'));
                        Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return EditProfile(
                                userModel: userModel,
                              );
                            },
                          ),
                        );
                      },
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Edit Profile",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      icon: const Icon(FluentIcons.edit_24_regular),
                    ),
                  TextButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      await Hive.box('info').deleteFromDisk();
                      await Hive.box("surveyLocal").deleteFromDisk();
                      await Hive.openBox("info");
                      await Hive.openBox("surveyLocal");
                      Navigator.pushNamedAndRemoveUntil(
                        // ignore: use_build_context_synchronously
                        context,
                        '/',
                        (route) => false,
                      );
                    },
                    label: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Sign Out",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    icon: const Icon(FluentIcons.sign_out_24_regular),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
