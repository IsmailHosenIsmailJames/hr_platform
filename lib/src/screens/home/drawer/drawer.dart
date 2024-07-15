import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hr_platform/src/screens/add_user/add_user.dart';
import 'package:hr_platform/src/screens/home/settings/settings.dart';
import 'package:hr_platform/src/screens/survey/survey.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.blue.shade800,
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
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const Settings();
                        },
                      ),
                    );
                  },
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Settings",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  icon: const Icon(FluentIcons.settings_24_regular),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
