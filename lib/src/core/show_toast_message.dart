import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToastedMessage(String msg, BuildContext context) {
  Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_LONG);
}
