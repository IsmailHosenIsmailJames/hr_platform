import 'package:flutter/material.dart';
import 'package:hr_platform/src/screens/survey/models/surevey_model.dart';

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
    return Scaffold();
  }
}
