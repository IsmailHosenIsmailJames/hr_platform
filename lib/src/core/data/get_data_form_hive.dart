import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

List<Map> getCurrentPossitionListOfData() {
  final box = Hive.box("info");
  final data = box.get('data', defaultValue: null);
  List<Map> toReturn = [];
  if (data != null && jsonDecode(data)['data-map'] != null) {
    toReturn = List<Map>.from(jsonDecode(data)['data-map']);
  }
  return toReturn;
}
