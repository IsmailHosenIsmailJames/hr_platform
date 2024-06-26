import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hr_platform/src/models/files_model.dart';
import 'package:hr_platform/src/theme/break_point.dart';

class HomePage extends StatefulWidget {
  final String path;
  const HomePage({super.key, required this.path});

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
    Navigator.pushNamedAndRemoveUntil(
      // ignore: use_build_context_synchronously
      context,
      "/login",
      (route) => true,
    );
  }

  final box = Hive.box('info');

  List<Map> getCurrentPossitionListOfData() {
    final data = box.get('data', defaultValue: null);
    List<Map> toReturn = [];
    if (data != null) {
      toReturn = List<Map>.from(jsonDecode(data)['data-map']);
    }
    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = FirebaseAuth.instance.currentUser!.email != null;
    List<Map> cureentLayerData = getCurrentPossitionListOfData();
    return Scaffold(
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: null,
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(
                  Icons.add,
                  size: 35,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.of(context).size.width > breakpoint ? 5 : 4),
          itemCount: cureentLayerData.length,
          padding: const EdgeInsets.all(5),
          itemBuilder: (context, index) {
            Map<String, dynamic> cureent =
                Map<String, dynamic>.from(cureentLayerData[index]);
            FilesModel cureentModel = FilesModel.fromMap(cureent);
            bool isFile = cureent['is-file'];
            return isFile
                ? TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.5),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      cureentModel.path;
                    },
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            cureentModel.image ??
                                "http://116.68.200.97:6027/static/media/form.54693b5d.png",
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.5),
                          child: const Icon(FluentIcons.document_24_regular)),
                    ),
                  )
                : TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {},
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      height: 100,
                      color: Colors.blue,
                      width: 100,
                      child: Text(isFile.toString()),
                    ),
                  );
          },
        ),
      ),
    );
  }
}
