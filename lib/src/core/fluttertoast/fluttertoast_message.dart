import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showFluttertoastMessage(String msg, BuildContext context) {
  Fluttertoast.showToast(msg: msg);
}
