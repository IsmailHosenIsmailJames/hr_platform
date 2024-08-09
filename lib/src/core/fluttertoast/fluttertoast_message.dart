import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showFluttertoastMessage(String msg, BuildContext context) {
  if (!Platform.isWindows) {
    Fluttertoast.showToast(msg: msg);
  } else {
    showModalBottomSheet(
      context: context,
      builder: (context) => Center(
        child: Text(
          msg,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
