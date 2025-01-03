import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hr_platform/src/core/fluttertoast/fluttertoast_message.dart';
import 'package:hr_platform/src/screens/add_user/add_user.dart';
import 'package:hr_platform/src/screens/survey/models/surevey_question_model.dart';
import 'package:hr_platform/src/screens/survey/models/text_answer.dart';
import 'package:hr_platform/src/screens/survey/view_general_user.dart/survey_view.dart';
import 'package:hr_platform/src/theme/break_point.dart';
import 'package:toastification/toastification.dart';

import '../../theme/text_field_input_decoration.dart';
import 'getx/controller_getx.dart';

class Survey extends StatefulWidget {
  final SureveyModel? previousSurveyModel;
  const Survey({super.key, this.previousSurveyModel});

  @override
  State<Survey> createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  SureveyModel? previousSurveyModel;

  @override
  void initState() {
    previousSurveyModel = widget.previousSurveyModel;
    if (previousSurveyModel != null) {
      surveyController.survey.value = previousSurveyModel!;
    }
    super.initState();
  }

  final surveyController = Get.put(SurveyController());

  final formKey = GlobalKey<FormState>();
  final box = Hive.box("surveyLocal");

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a survey"),
        actions: [
          IconButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                surveyController.survey.value.lastUpdated =
                    DateTime.now().millisecondsSinceEpoch;
                await box.put("${surveyController.survey.value.id}",
                    surveyController.survey.value.toJson());
                // ignore: use_build_context_synchronously
                showFluttertoastMessage(
                  "Saved!",
                  type: ToastificationType.success,
                );
                Navigator.pushNamedAndRemoveUntil(
                  // ignore: use_build_context_synchronously
                  context,
                  "/",
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.save_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  surveyController.survey.value.lastUpdated =
                      DateTime.now().millisecondsSinceEpoch;
                  await box.put("${surveyController.survey.value.id}",
                      surveyController.survey.value.toJson());

                  // ignore: use_build_context_synchronously
                  showFluttertoastMessage(
                    "Saved!",
                    type: ToastificationType.success,
                  );
                  Navigator.push(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                      builder: (context) => SurveyView(
                        surevey: surveyController.survey.value,
                        isPreview: true,
                      ),
                    ),
                  );
                }
              },
              child: const Text("Preview"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: breakPointWidth.toDouble(),
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GetX<SurveyController>(
                  builder: (controller) {
                    return Column(
                      children: [
                        const Gap(10),
                        titleWidget("Title of survey", true,
                            fontsize: 17, alinment: MainAxisAlignment.start),
                        const Gap(5),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "title can't be empty";
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: TextEditingController(
                              text: controller.survey.value.title),
                          onChanged: (value) {
                            controller.survey.value.title = value;
                          },
                          decoration: getInputDecooration(
                            "Title of survey",
                            "Type title of survey...",
                          ),
                        ),
                        const Gap(15),
                        titleWidget("Description of survey", false,
                            fontsize: 17, alinment: MainAxisAlignment.start),
                        const Gap(5),
                        TextFormField(
                          controller: TextEditingController(
                              text: controller.survey.value.description),
                          onChanged: (value) {
                            controller.survey.value.description = value;
                          },
                          decoration: getInputDecooration(
                            "Description of survey",
                            "Type Description of survey...",
                          ),
                        ),
                        const Gap(15),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  titleWidget("Time of survey", false,
                                      fontsize: 17,
                                      alinment: MainAxisAlignment.start),
                                  const Gap(5),
                                  TextFormField(
                                    validator: (value) {
                                      if (value != null && value.isNotEmpty) {
                                        if (int.tryParse(value) == null) {
                                          return "enter valid number";
                                        }
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    controller: TextEditingController(
                                        text: surveyController
                                                    .survey.value.timer ==
                                                null
                                            ? ""
                                            : surveyController
                                                .survey.value.timer
                                                .toString()),
                                    onChanged: (value) {
                                      try {
                                        controller.survey.value.timer =
                                            int.parse(value);
                                      } catch (e) {
                                        if (kDebugMode) {
                                          print(e);
                                        }
                                      }
                                    },
                                    decoration: getInputDecooration(
                                        "time in minute",
                                        "type your time as number for that minutes"),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(15),
                            Expanded(
                              child: Column(
                                children: [
                                  titleWidget("Expired Date", false,
                                      fontsize: 17,
                                      alinment: MainAxisAlignment.start),
                                  const Gap(5),
                                  SizedBox(
                                    width: 200,
                                    height: 50,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return BottomPicker.dateTime(
                                              initialDateTime: DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                surveyController
                                                        .survey.value.expired ??
                                                    DateTime.now()
                                                        .millisecondsSinceEpoch,
                                              ),
                                              onSubmit: (date) {
                                                DateTime dateTime = date;
                                                surveyController
                                                        .survey.value.expired =
                                                    dateTime
                                                        .millisecondsSinceEpoch;

                                                setState(() {});
                                              },
                                              pickerTitle: const Text(
                                                "Pick Expired Date",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          surveyController
                                                      .survey.value.expired !=
                                                  null
                                              ? Text(
                                                  DateTime.fromMillisecondsSinceEpoch(
                                                          surveyController
                                                              .survey
                                                              .value
                                                              .expired!)
                                                      .toIso8601String()
                                                      .split("T")[0],
                                                )
                                              : const Text("Pick time"),
                                          if (surveyController
                                                  .survey.value.expired !=
                                              null)
                                            const Gap(5),
                                          if (surveyController
                                                  .survey.value.expired !=
                                              null)
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  surveyController.survey.value
                                                      .expired = null;
                                                });
                                              },
                                              icon: const Icon(Icons.close),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),
                        const Gap(10),
                        Column(
                          children: List.generate(
                            controller.survey.value.questions.length,
                            (index) {
                              if (controller
                                      .survey.value.questions[index].type ==
                                  "multi_choice") {
                                return multiCChoiceWidget(
                                    context,
                                    controller.survey.value.questions[index],
                                    index,
                                    "Multipule Choice");
                              } else if (controller
                                      .survey.value.questions[index].type ==
                                  "single_choice") {
                                return singleChoiceWidget(
                                  context,
                                  controller.survey.value.questions[index],
                                  index,
                                  "Single Choice",
                                );
                              } else {
                                return textQuestionWidget(
                                  context,
                                  controller.survey.value.questions[index],
                                  index,
                                );
                              }
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            titleWidget("Add Questions", true),
                            const Gap(20),
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: SizedBox(
                                      height: 300,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20,
                                            bottom: 20,
                                            left: 10,
                                            right: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              "Choice One",
                                              style: TextStyle(fontSize: 30),
                                            ),
                                            const Divider(),
                                            const Gap(20),
                                            Container(
                                              margin: const EdgeInsets.all(10),
                                              width: 300,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  controller
                                                      .survey.value.questions
                                                      .add(
                                                    Question(
                                                      id: getRandomValue(),
                                                      type: "multi_choice",
                                                      question: "",
                                                      options: [],
                                                    ),
                                                  );
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                },
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Icon(Icons
                                                        .radio_button_checked),
                                                    Gap(20),
                                                    Text(
                                                        "Multi Choice Options"),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.all(10),
                                              width: 300,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  controller
                                                      .survey.value.questions
                                                      .add(
                                                    Question(
                                                      id: getRandomValue(),
                                                      type: "single_choice",
                                                      question: "",
                                                      options: [],
                                                    ),
                                                  );
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                },
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Icon(Icons
                                                        .radio_button_checked),
                                                    Gap(20),
                                                    Text(
                                                        "Single Choice Options"),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.all(10),
                                              width: 300,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  controller
                                                      .survey.value.questions
                                                      .add(
                                                    Question(
                                                      id: getRandomValue(),
                                                      type: "text",
                                                      question: "",
                                                    ),
                                                  );
                                                  TextAnswerQuestion.fromMap(
                                                      Question(
                                                    id: getRandomValue(),
                                                    type: "text",
                                                    question: "",
                                                  ).toMap());
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                },
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Icon(Icons
                                                        .radio_button_checked),
                                                    Gap(20),
                                                    Text("Text answer"),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Add"),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textQuestionWidget(
      BuildContext context, Question question, int index) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleWidget("Text answer", false, fontsize: 18),
              popUpForQuestion(index),
            ],
          ),
          getFirstRowOfQuestionWidget(index, context),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Question can't be empty";
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: TextEditingController(
              text: surveyController.survey.value.questions[index].question,
            ),
            decoration:
                getInputDecooration("Question", "Type your question here..."),
            onChanged: (value) {
              surveyController.survey.value.questions[index].question = value;
            },
          ),
          const Gap(10),
          titleWidget("Hint", false,
              fontsize: 16, alinment: MainAxisAlignment.start),
          const Gap(5),
          TextFormField(
            controller: TextEditingController(
                text: surveyController.survey.value.questions[index].hint),
            decoration: getInputDecooration("Hint", "Type your hint here..."),
            onChanged: (value) {
              surveyController.survey.value.questions[index].hint = value;
            },
          ),
        ],
      ),
    );
  }

  Row getFirstRowOfQuestionWidget(int index, BuildContext context,
      {bool showLimit = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        titleWidget("${index + 1}. Question", true, fontsize: 16),
        if (showLimit)
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  TextEditingController controller = TextEditingController();
                  return AlertDialog(
                    title: const Text("Set answer size limit"),
                    content: TextFormField(
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (int.tryParse(value) == null) {
                            return "enter a valit number";
                          }
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: controller,
                      decoration: getInputDecooration(),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          if (controller.text == "") {
                            surveyController
                                .survey.value.questions[index].maxLen = null;
                          } else {
                            try {
                              surveyController.survey.value.questions[index]
                                  .maxLen = int.parse(controller.text.trim());
                            } catch (e) {
                              if (kDebugMode) {
                                print(e);
                              }
                            }
                          }
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text("ok"),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
                "Answer size: ${surveyController.survey.value.questions[index].maxLen ?? "Unlimited"}"),
          ),
      ],
    );
  }

  Widget singleChoiceWidget(
      BuildContext context, Question question, int index, String type) {
    return multiCChoiceWidget(context, question, index, type);
  }

  Widget multiCChoiceWidget(
      BuildContext context, Question question, int index, String type) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleWidget(type, false, fontsize: 18),
              popUpForQuestion(index)
            ],
          ),
          getFirstRowOfQuestionWidget(index, context, showLimit: false),
          const Gap(7),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Question can't be empty";
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: TextEditingController(
                text: surveyController.survey.value.questions[index].question),
            decoration:
                getInputDecooration("Question", "Type your question here..."),
            onChanged: (value) {
              surveyController.survey.value.questions[index].question = value;
            },
          ),
          const Gap(10),
          titleWidget("Hint", false,
              fontsize: 16, alinment: MainAxisAlignment.start),
          const Gap(5),
          TextFormField(
            controller: TextEditingController(
                text: surveyController.survey.value.questions[index].hint),
            decoration: getInputDecooration("Hint", "Type your hint here..."),
            onChanged: (value) {
              surveyController.survey.value.questions[index].hint = value;
            },
          ),
          const Gap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              titleWidget("Options", true, fontsize: 16),
              SizedBox(
                height: 30,
                child: ElevatedButton.icon(
                  onPressed: () {
                    surveyController.survey.value.questions[index].options!.add(
                      Option(
                        id: getRandomValue(),
                        text: "",
                      ),
                    );
                    setState(() {});
                  },
                  label: const Text("Add"),
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          const Gap(5),
          Container(
            margin: const EdgeInsets.only(left: 10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: List.generate(
                (surveyController.survey.value.questions[index].options ?? [])
                    .length,
                (i) {
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        titleWidget(
                          "${i + 1}.",
                          false,
                          fontsize: 16,
                        ),
                        const Gap(10),
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Option text can't be empty";
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: TextEditingController(
                                text: surveyController.survey.value
                                    .questions[index].options![i].text),
                            onChanged: (value) {
                              surveyController.survey.value.questions[index]
                                  .options![i].text = value;
                            },
                            decoration: getInputDecooration(
                                "Option text", "type option here"),
                          ),
                        ),
                        const Gap(5),
                        IconButton(
                          onPressed: () {
                            surveyController
                                .survey.value.questions[index].options!
                                .removeAt(i);
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuButton<dynamic> popUpForQuestion(int index) {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          if (index > 0)
            PopupMenuItem(
              onTap: () {
                Question tem =
                    surveyController.survey.value.questions[index - 1];
                surveyController.survey.value.questions[index - 1] =
                    surveyController.survey.value.questions[index];
                surveyController.survey.value.questions[index] = tem;
                setState(() {});
              },
              child: const Row(
                children: [
                  Icon(
                    Icons.arrow_upward,
                  ),
                  Gap(5),
                  Text("Move up"),
                ],
              ),
            ),
          if (index < surveyController.survey.value.questions.length - 1)
            PopupMenuItem(
              onTap: () {
                Question tem =
                    surveyController.survey.value.questions[index + 1];
                surveyController.survey.value.questions[index + 1] =
                    surveyController.survey.value.questions[index];
                surveyController.survey.value.questions[index] = tem;
                setState(() {});
              },
              child: const Row(
                children: [
                  Icon(
                    Icons.arrow_downward,
                  ),
                  Gap(5),
                  Text("Move down"),
                ],
              ),
            ),
          PopupMenuItem(
            onTap: () {
              surveyController.survey.value.questions.removeAt(index);
              setState(() {});
            },
            child: const Row(
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                Gap(5),
                Text("Delete"),
              ],
            ),
          ),
        ];
      },
    );
  }
}
