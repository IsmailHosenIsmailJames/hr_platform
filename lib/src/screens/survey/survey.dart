import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hr_platform/src/screens/add_user/add_user.dart';
import 'package:hr_platform/src/screens/survey/models/surevey_model.dart';
import 'package:hr_platform/src/screens/survey/models/text_answer.dart';

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
  late TextEditingController titleEditingController = TextEditingController();
  late TextEditingController descriptionEditingController =
      TextEditingController();

  @override
  void initState() {
    previousSurveyModel = widget.previousSurveyModel;
    titleEditingController = TextEditingController();
    descriptionEditingController = TextEditingController();
    super.initState();
  }

  final surveyController = Get.put(SurveyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a survey"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              label: const Text("Preview"),
              icon: const Icon(
                Icons.preview_rounded,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GetX<SurveyController>(
            builder: (controller) {
              return Column(
                children: [
                  const Gap(10),
                  titleWidget("Title of survey", true, fontsize: 17),
                  const Gap(5),
                  TextFormField(
                    onChanged: (value) {
                      controller.survey.value.title = value;
                    },
                    decoration: getInputDecooration(
                      "Title of survey",
                      "Type title of survey...",
                    ),
                  ),
                  const Gap(15),
                  titleWidget("Description of survey", false, fontsize: 17),
                  const Gap(5),
                  TextFormField(
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
                            titleWidget("Time of survey", false, fontsize: 17),
                            const Gap(5),
                            TextFormField(
                              onChanged: (value) {
                                controller.survey.value.timer =
                                    int.parse(value);
                              },
                              decoration: getInputDecooration("time in minute",
                                  "type your time as number for that minutes"),
                            ),
                          ],
                        ),
                      ),
                      const Gap(15),
                      Expanded(
                        child: Column(
                          children: [
                            titleWidget("Expired Date", false, fontsize: 17),
                            const Gap(5),
                            SizedBox(
                              width: 200,
                              height: 50,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return BottomPicker.dateTime(
                                        initialDateTime:
                                            DateTime.fromMillisecondsSinceEpoch(
                                          expairedDateTimeEpoc ??
                                              DateTime.now()
                                                  .millisecondsSinceEpoch,
                                        ),
                                        onSubmit: (date) {
                                          DateTime dateTime = date;
                                          expairedDateTime =
                                              "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                                          expairedDateTimeEpoc =
                                              dateTime.millisecondsSinceEpoch;
                                          controller.survey.value.expired =
                                              dateTime.millisecondsSinceEpoch;
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(expairedDateTime ?? "Pick time"),
                                    if (expairedDateTime != null) const Gap(5),
                                    if (expairedDateTime != null)
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            expairedDateTime = null;
                                            expairedDateTimeEpoc = null;
                                            controller.survey.value.expired =
                                                null;
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
                                      top: 20, bottom: 20, left: 10, right: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      SizedBox(
                                        width: 300,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            controller.survey.value.questions
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
                                              Icon(Icons.radio_button_checked),
                                              Gap(20),
                                              Text("Multi Choice Options"),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 300,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            controller.survey.value.questions
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
                                              Icon(Icons.radio_button_checked),
                                              Gap(20),
                                              Text("Single Choice Options"),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 300,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            controller.survey.value.questions
                                                .add(
                                              Question(
                                                id: getRandomValue(),
                                                type: "text",
                                                question: "",
                                              ),
                                            );
                                            TextAnswerQuestion.fromMap(Question(
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
                                              Icon(Icons.radio_button_checked),
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
                  const Gap(10),
                  Column(
                    children: List.generate(
                      controller.survey.value.questions.length,
                      (index) {
                        if (controller.survey.value.questions[index].type ==
                            "multi_choice") {
                          return multiCChoiceWidget(context,
                              controller.survey.value.questions[index], index);
                        } else if (controller
                                .survey.value.questions[index].type ==
                            "single_choice") {
                          return singleChoiceWidget(
                              controller.survey.value.questions[index]);
                        } else {
                          return textQuestionWidget(
                            context,
                            controller.survey.value.questions[index],
                            index,
                          );
                        }
                      },
                    ),
                  )
                ],
              );
            },
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
              IconButton(
                onPressed: () {
                  surveyController.survey.value.questions.removeAt(index);
                  setState(() {});
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          getFirstRowOfQuestionWidget(index, context),
          TextFormField(
            decoration:
                getInputDecooration("Question", "Type your question here..."),
            onChanged: (value) {
              surveyController.survey.value.questions[index].question = value;
            },
          ),
          const Gap(10),
          titleWidget("Hint", false, fontsize: 16),
          const Gap(5),
          TextFormField(
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
                            surveyController.survey.value.questions[index]
                                .maxLen = int.parse(controller.text.trim());
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

  Widget singleChoiceWidget(Question question) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget multiCChoiceWidget(
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
              titleWidget("Multipule Choice", false, fontsize: 18),
              IconButton(
                onPressed: () {
                  surveyController.survey.value.questions.removeAt(index);
                  setState(() {});
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          getFirstRowOfQuestionWidget(index, context, showLimit: false),
          const Gap(7),
          TextFormField(
            decoration:
                getInputDecooration("Question", "Type your question here..."),
            onChanged: (value) {
              surveyController.survey.value.questions[index].question = value;
            },
          ),
          const Gap(10),
          titleWidget("Hint", false, fontsize: 16),
          const Gap(5),
          TextFormField(
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
                surveyController.survey.value.questions[index].options!.length,
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

  String? expairedDateTime;
  int? expairedDateTimeEpoc;
}
