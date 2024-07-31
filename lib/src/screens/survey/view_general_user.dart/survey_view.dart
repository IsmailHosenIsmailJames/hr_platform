import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hr_platform/src/screens/add_user/add_user.dart';
import 'package:hr_platform/src/screens/survey/getx/controller_getx.dart';
import 'package:hr_platform/src/screens/survey/models/surevey_model.dart';

import '../../../theme/text_field_input_decoration.dart';

class SurveyView extends StatefulWidget {
  final SureveyModel surevey;
  final bool isPreview;
  const SurveyView({super.key, required this.surevey, required this.isPreview});

  @override
  State<SurveyView> createState() => _SurveyViewState();
}

class _SurveyViewState extends State<SurveyView> {
  late SureveyModel surevey;
  @override
  void initState() {
    surevey = widget.surevey;
    super.initState();
  }

  final surveyController = Get.put(SurveyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Survey"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () {},
              child: Text(
                widget.isPreview ? "Publish" : "Submit",
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget(
                surevey.title,
                false,
                fontsize: 20,
                alinment: MainAxisAlignment.start,
              ),
              const Gap(5),
              Text(surevey.description),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  titleWidget("Date: ", false, fontsize: 16),
                  Text(
                    DateTime.fromMillisecondsSinceEpoch(surevey.date)
                        .toIso8601String()
                        .split("T")[0],
                  ),
                  const Gap(15),
                  if (surevey.timer != null)
                    titleWidget("Time: ", false, fontsize: 16),
                  if (surevey.timer != null)
                    Text(
                      surevey.timer.toString(),
                    ),
                  const Gap(15),
                  if (surevey.expired != null)
                    titleWidget("Expired: ", false, fontsize: 16),
                  if (surevey.expired != null)
                    Text(
                      DateTime.fromMillisecondsSinceEpoch(surevey.expired!)
                          .toIso8601String()
                          .split("T")[0],
                    ),
                ],
              ),
              const Divider(),
              Column(
                children: List.generate(
                  surevey.questions.length,
                  (index) {
                    if (surevey.questions[index].type == "multi_choice") {
                      return getMultiChoiceViewWidget(index);
                    } else if (surevey.questions[index].type ==
                        "single_choice") {
                      return getSingleChoiceViewWidget(index);
                    } else {
                      return getTextAnswerViewWidget(index);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container getTextAnswerViewWidget(int index) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                child: titleWidget("${index + 1}. ", false,
                    fontsize: 18, alinment: MainAxisAlignment.center),
              ),
              titleWidget(
                "Text Answer",
                false,
                fontsize: 16,
              ),
            ],
          ),
          Text(
            surevey.questions[index].question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (surevey.questions[index].hint != null)
            Text("Hint: ${surevey.questions[index].hint}"),
          Divider(
            color: Colors.grey.shade700,
          ),
          TextFormField(
            decoration: getInputDecooration(
              "Your Answer",
              "Type here your answer",
            ),
            maxLines: 1000,
            minLines: 2,
            maxLength: surevey.questions[index].maxLen,
            controller: TextEditingController(
                text: surevey.questions[index].answer ?? ""),
            onChanged: (value) {
              surevey.questions[index].answer = value;
            },
          ),
        ],
      ),
    );
  }

  Container getSingleChoiceViewWidget(
    int index,
  ) {
    return getMultiChoiceViewWidget(index, isSingleChoice: true);
  }

  Container getMultiChoiceViewWidget(int index, {bool isSingleChoice = false}) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                child: titleWidget("${index + 1}. ", false,
                    fontsize: 18, alinment: MainAxisAlignment.center),
              ),
              titleWidget(
                isSingleChoice ? "Single Choice" : "Multi Choice",
                false,
                fontsize: 16,
              ),
            ],
          ),
          Text(
            surevey.questions[index].question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (surevey.questions[index].hint != null)
            Text("Hint: ${surevey.questions[index].hint}"),
          Divider(
            color: Colors.grey.shade700,
          ),
          Column(
            children: List.generate(
              (surevey.questions[index].options ?? []).length,
              (i) {
                List<int> ans = [];
                if (isSingleChoice) {
                  if (surevey.questions[index].answer != null) {
                    ans = List<int>.from(surevey.questions[index].answer);
                  }
                } else {
                  ans = List<int>.from(surevey.questions[index].answer ?? []);
                }
                bool isSelected = false;
                int id = surevey.questions[index].options![i].id;

                if (ans.contains(id)) {
                  isSelected = true;
                }

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (isSelected) {
                      ans.remove(id);
                    } else {
                      if (isSingleChoice) {
                        ans = [id];
                      } else {
                        ans.add(id);
                      }
                    }
                    surevey.questions[index].answer = ans;
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.grey.shade300,
                    ),
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.all(5),
                    child: SingleChildScrollView(
                      child: Row(
                        children: [
                          isSelected
                              ? Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.blue.shade900,
                                )
                              : const Icon(Icons.radio_button_unchecked),
                          const Gap(15),
                          Text(
                            surevey.questions[index].options![i].text,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
