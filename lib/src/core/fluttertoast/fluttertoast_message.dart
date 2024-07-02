import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';

void showFluttertoastMessage(String msg) {
  if (!Platform.isWindows) {
    Fluttertoast.showToast(msg: msg);
  }
}
