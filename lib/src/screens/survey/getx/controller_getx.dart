import 'dart:math';

import 'package:get/state_manager.dart';
import 'package:hr_platform/src/screens/survey/models/surevey_question_model.dart';

class SurveyController extends GetxController {
  Rx<SureveyModel> survey = SureveyModel(
    id: getRandomValue(),
    title: "",
    description: "",
    date: DateTime.now().millisecondsSinceEpoch,
    questions: <Question>[],
  ).obs;
}

int getRandomValue() {
  return Random().nextInt(999999999) + 100000000;
}
