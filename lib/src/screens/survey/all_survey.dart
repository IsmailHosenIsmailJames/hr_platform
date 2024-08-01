import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hr_platform/src/core/show_toast_message.dart';
import 'package:hr_platform/src/screens/survey/survey.dart';
import 'package:clipboard/clipboard.dart';
import 'package:hr_platform/src/screens/survey/view_general_user.dart/survey_view.dart';

import 'models/surevey_question_model.dart';

class AllSurvey extends StatefulWidget {
  const AllSurvey({super.key});

  @override
  State<AllSurvey> createState() => _AllSurveyState();
}

class _AllSurveyState extends State<AllSurvey> {
  List<SureveyModel> allSurvey = [];

  final box = Hive.box("surveyLocal");

  @override
  void initState() {
    getSurveyData();
    super.initState();
  }

  Future<void> getSurveyData() async {
    allSurvey = [];
    List<String> keys = List<String>.from(box.keys.toList());
    for (String key in keys) {
      allSurvey.add(SureveyModel.fromJson(box.get(key)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Survey"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(
            allSurvey.length,
            (index) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SurveyView(
                        surevey: allSurvey[index],
                        isPreview: false,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        allSurvey[index].title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(5),
                      if (allSurvey[index].description.isNotEmpty)
                        Text(
                          allSurvey[index].description,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (allSurvey[index].description.isNotEmpty) const Gap(5),
                      Text("ID: ${allSurvey[index].id}"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              FlutterClipboard.copy('${allSurvey[index].id}')
                                  .then((value) {
                                showToastedMessage(
                                    "Copied ${allSurvey[index].id}");
                              });
                            },
                            icon: const Icon(Icons.link),
                          ),
                          if ((FirebaseAuth.instance.currentUser!.email !=
                                  null &&
                              FirebaseAuth
                                  .instance.currentUser!.email!.isNotEmpty))
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Are you sure?"),
                                    content: const Text(
                                        "After delete, this will no longer exits in server or local memory."),
                                    actions: [
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                            foregroundColor: Colors.red),
                                        onPressed: () async {
                                          await box
                                              .delete("${allSurvey[index].id}");
                                          await getSurveyData();

                                          setState(() {});
                                          // ignore: use_build_context_synchronously
                                          Navigator.pop(context);
                                        },
                                        label: const Text("Delete"),
                                        icon: const Icon(
                                          Icons.delete,
                                        ),
                                      ),
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                            foregroundColor: Colors.green),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        label: const Text("Cancel"),
                                        icon: const Icon(
                                          Icons.cancel,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          if ((FirebaseAuth.instance.currentUser!.email !=
                                  null &&
                              FirebaseAuth
                                  .instance.currentUser!.email!.isNotEmpty))
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Survey(
                                      previousSurveyModel: allSurvey[index],
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
