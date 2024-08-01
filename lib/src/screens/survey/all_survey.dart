import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hr_platform/src/core/show_toast_message.dart';
import 'package:hr_platform/src/screens/add_user/add_user.dart';
import 'package:hr_platform/src/screens/survey/survey.dart';
import 'package:clipboard/clipboard.dart';
import 'package:hr_platform/src/screens/survey/view_general_user.dart/survey_view.dart';
import 'package:hr_platform/src/theme/break_point.dart';

import '../../models/user_model.dart';
import 'models/surevey_question_model.dart';

class AllSurvey extends StatefulWidget {
  final String? surveyID;
  const AllSurvey({super.key, this.surveyID});

  @override
  State<AllSurvey> createState() => _AllSurveyState();
}

class _AllSurveyState extends State<AllSurvey> {
  List<SureveyModel> allSurveyLocal = [];
  List<SureveyModel> allSurveyFirebase = [];
  bool isGettingData = true;

  final box = Hive.box("surveyLocal");

  @override
  void initState() {
    getSurveyData();
    super.initState();
  }

  Future<void> getSurveyData() async {
    allSurveyLocal = [];
    try {
      List<String> keys = List<String>.from(box.keys.toList());
      for (String key in keys) {
        allSurveyLocal.add(SureveyModel.fromJson(box.get(key)));
      }
      setState(() {});
      final dataOfFirebase =
          await FirebaseFirestore.instance.collection("survey").get();
      for (QueryDocumentSnapshot element in dataOfFirebase.docs) {
        if (element.exists) {
          final data = element.data();
          if (data != null) {
            final model =
                SureveyModel.fromJson(jsonEncode(element.get("question")));
            if (!(FirebaseAuth.instance.currentUser!.email != null &&
                FirebaseAuth.instance.currentUser!.email!.isNotEmpty)) {
              final box = Hive.box('info');
              UserModel userModel = UserModel.fromJson(box.get('userData'));
              dynamic ans;
              try {
                ans = element.get("${userModel.userID}");
              } catch (e) {
                if (kDebugMode) {
                  print(e);
                }
              }
              if (ans != null) {
                Map<String, dynamic> ansMap = jsonDecode(jsonEncode(ans));
                ansMap.forEach(
                  (key, value) {
                    for (int i = 0; i < model.questions.length; i++) {
                      if ("${model.questions[i].id}" == key) {
                        model.questions[i].answer = value;
                      }
                    }
                  },
                );
              }
            }
            allSurveyFirebase.add(model);
          }
        }
      }
      isGettingData = false;
    } catch (e) {
      isGettingData = false;
    }
    setState(() {});
    if (widget.surveyID != null) {
      for (int i = 0; i < allSurveyFirebase.length; i++) {
        if ("${allSurveyFirebase[i].id}" == widget.surveyID) {
          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => SurveyView(
                surevey: allSurveyFirebase[i],
                isPreview: false,
              ),
              settings: RouteSettings(name: "survey/${widget.surveyID}"),
            ),
          );
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Survey"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: breakPointWidth.toDouble(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: titleWidget(
                    "Server",
                    false,
                    alinment: MainAxisAlignment.start,
                    fontsize: 18,
                  ),
                ),
                isGettingData
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : allSurveyFirebase.isEmpty
                        ? const Center(
                            child: Text("empty"),
                          )
                        : Column(
                            children: List.generate(
                              allSurveyFirebase.length,
                              (index) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SurveyView(
                                          surevey: allSurveyFirebase[index],
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          allSurveyFirebase[index].title,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Gap(5),
                                        if (allSurveyFirebase[index]
                                            .description
                                            .isNotEmpty)
                                          Text(
                                            allSurveyFirebase[index]
                                                .description,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        if (allSurveyFirebase[index]
                                            .description
                                            .isNotEmpty)
                                          const Gap(5),
                                        Text(
                                            "ID: ${allSurveyFirebase[index].id}"),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                FlutterClipboard.copy(
                                                        '${allSurveyFirebase[index].id}')
                                                    .then((value) {
                                                  showToastedMessage(
                                                      "Copied ${allSurveyFirebase[index].id}");
                                                });
                                              },
                                              icon: const Icon(Icons.link),
                                            ),
                                            if ((FirebaseAuth.instance
                                                        .currentUser!.email !=
                                                    null &&
                                                FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .email!
                                                    .isNotEmpty))
                                              IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                          "Are you sure?"),
                                                      content: const Text(
                                                          "After delete, this will no longer exits in server"),
                                                      actions: [
                                                        TextButton.icon(
                                                          style: TextButton
                                                              .styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .red),
                                                          onPressed: () async {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "survey")
                                                                .doc(
                                                                    "${allSurveyFirebase[index].id}")
                                                                .delete();

                                                            allSurveyFirebase
                                                                .removeAt(
                                                                    index);

                                                            setState(() {});

                                                            // ignore: use_build_context_synchronously
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          label: const Text(
                                                              "Delete"),
                                                          icon: const Icon(
                                                            Icons.delete,
                                                          ),
                                                        ),
                                                        TextButton.icon(
                                                          style: TextButton
                                                              .styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .green),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          label: const Text(
                                                              "Cancel"),
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
                                            if ((FirebaseAuth.instance
                                                        .currentUser!.email !=
                                                    null &&
                                                FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .email!
                                                    .isNotEmpty))
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Survey(
                                                        previousSurveyModel:
                                                            allSurveyFirebase[
                                                                index],
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
                if (FirebaseAuth.instance.currentUser!.email != null &&
                    FirebaseAuth.instance.currentUser!.email!.isNotEmpty)
                  const Divider(),
                if (FirebaseAuth.instance.currentUser!.email != null &&
                    FirebaseAuth.instance.currentUser!.email!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: titleWidget(
                      "Local Memory",
                      false,
                      alinment: MainAxisAlignment.start,
                      fontsize: 18,
                    ),
                  ),
                if (FirebaseAuth.instance.currentUser!.email != null &&
                    FirebaseAuth.instance.currentUser!.email!.isNotEmpty)
                  allSurveyLocal.isEmpty
                      ? const Center(
                          child: Text("empty"),
                        )
                      : Column(
                          children: List.generate(
                            allSurveyLocal.length,
                            (index) {
                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SurveyView(
                                        surevey: allSurveyLocal[index],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        allSurveyLocal[index].title,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Gap(5),
                                      if (allSurveyLocal[index]
                                          .description
                                          .isNotEmpty)
                                        Text(
                                          allSurveyLocal[index].description,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      if (allSurveyLocal[index]
                                          .description
                                          .isNotEmpty)
                                        const Gap(5),
                                      Text("ID: ${allSurveyLocal[index].id}"),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              FlutterClipboard.copy(
                                                      '${allSurveyLocal[index].id}')
                                                  .then((value) {
                                                showToastedMessage(
                                                    "Copied ${allSurveyLocal[index].id}");
                                              });
                                            },
                                            icon: const Icon(Icons.link),
                                          ),
                                          if ((FirebaseAuth.instance
                                                      .currentUser!.email !=
                                                  null &&
                                              FirebaseAuth.instance.currentUser!
                                                  .email!.isNotEmpty))
                                            IconButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        "Are you sure?"),
                                                    content: const Text(
                                                        "After delete, this will no longer exits local memory."),
                                                    actions: [
                                                      TextButton.icon(
                                                        style: TextButton
                                                            .styleFrom(
                                                                foregroundColor:
                                                                    Colors.red),
                                                        onPressed: () async {
                                                          await box.delete(
                                                              "${allSurveyLocal[index].id}");
                                                          await getSurveyData();

                                                          allSurveyLocal
                                                              .removeAt(index);
                                                          setState(() {});
                                                          // ignore: use_build_context_synchronously
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        label: const Text(
                                                            "Delete"),
                                                        icon: const Icon(
                                                          Icons.delete,
                                                        ),
                                                      ),
                                                      TextButton.icon(
                                                        style: TextButton
                                                            .styleFrom(
                                                                foregroundColor:
                                                                    Colors
                                                                        .green),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        label: const Text(
                                                            "Cancel"),
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
                                          if ((FirebaseAuth.instance
                                                      .currentUser!.email !=
                                                  null &&
                                              FirebaseAuth.instance.currentUser!
                                                  .email!.isNotEmpty))
                                            IconButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Survey(
                                                      previousSurveyModel:
                                                          allSurveyLocal[index],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
