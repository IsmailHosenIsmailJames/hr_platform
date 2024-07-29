import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hr_platform/src/screens/add_user/add_user.dart';
import 'package:hr_platform/src/screens/survey/models/surevey_model.dart';

import '../../theme/text_field_input_decoration.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a survey"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            const Gap(10),
            titleWidget("Title of survey", true),
            const Gap(5),
            TextFormField(
              decoration: getInputDecooration(
                "Title of survey",
                "Type title of survey...",
              ),
            ),
            const Gap(15),
            titleWidget("Description of survey", false),
            const Gap(5),
            TextFormField(
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
                      titleWidget("Time of survey", false),
                      const Gap(5),
                      TextFormField(
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
                      titleWidget("Expired Date", false),
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
                                        DateTime.now().millisecondsSinceEpoch,
                                  ),
                                  onSubmit: (date) {
                                    DateTime dateTime = date;
                                    expairedDateTime =
                                        "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                                    expairedDateTimeEpoc =
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
          ],
        ),
      ),
    );
  }

  String? expairedDateTime;
  int? expairedDateTimeEpoc;
}
