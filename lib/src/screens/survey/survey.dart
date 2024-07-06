import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hr_platform/src/screens/survey/controller_getx.dart';
import 'package:hr_platform/src/screens/survey/surevey_model.dart';

class Survey extends StatefulWidget {
  const Survey({super.key});

  @override
  State<Survey> createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleTextEditingController =
      TextEditingController();
  final questionsController = Get.put(QuestionsController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a Survey"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: titleTextEditingController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "title is required";
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  labelText: "Title of Survey",
                  hintText: "Type title of survey here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton.icon(
                onPressed: () {
                  questionsController.listOfQuestions.add(
                    Question(
                      question: "",
                      isRequires: false,
                      answerType: "Text",
                    ),
                  );
                },
                label: const Text(
                  "Add New Question",
                ),
                icon: const Icon(Icons.add),
              ),
            ),
            Expanded(
              child: GetX<QuestionsController>(
                builder: (controller) {
                  return Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: controller.listOfQuestions.isEmpty
                        ? const Center(
                            child: Text("Empty"),
                          )
                        : ListView.builder(
                            itemCount: controller.listOfQuestions.length,
                            padding: const EdgeInsets.only(
                              top: 15,
                              bottom: 15,
                              left: 5,
                              right: 5,
                            ),
                            itemBuilder: (context, index) {
                              Question current =
                                  controller.listOfQuestions[index];
                              List<String> listOfOptions =
                                  current.options ?? [];
                              List<Widget> listOfOptionWidgets = [];
                              for (String s in listOfOptions) {
                                listOfOptionWidgets.add(Row(
                                  children: [
                                    const Icon(Icons.radio),
                                    const Gap(10),
                                    Text(s)
                                  ],
                                ));
                              }
                              return Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              labelText: "Question",
                                              hintText: "Type question here...",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              current.question = value;
                                            },
                                          ),
                                        ),
                                        const Gap(10),
                                        DropdownButton(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          value: current.answerType,
                                          items: const [
                                            DropdownMenuItem(
                                              value: "Text",
                                              child: Text("Text"),
                                            ),
                                            DropdownMenuItem(
                                              value: "Options",
                                              child: Text("Options"),
                                            ),
                                            DropdownMenuItem(
                                              value: "Check Boxs",
                                              child: Text("Check Boxs"),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            current.answerType = value!;
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                    const Gap(10),
                                    if (current.answerType == "Options" ||
                                        current.answerType == "Check Boxs")
                                      Column(
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  child: TextFormField(),
                                                ),
                                              );
                                            },
                                            label: Text(
                                              "Add a ${current.answerType.toLowerCase().replaceAll("s", "")}",
                                            ),
                                            icon: const Icon(Icons.add),
                                          ),
                                        ],
                                      ),
                                    if ((current.answerType == "Options" ||
                                            current.answerType ==
                                                "Check Boxs") &&
                                        current.options != null &&
                                        current.options!.isNotEmpty)
                                      Column(
                                        children: listOfOptionWidgets,
                                      )
                                  ],
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
