import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToastedMessage(String msg, BuildContext context) {
  bool possibleToShowTwoatsedMessage =
      Platform.isIOS || Platform.isAndroid || kIsWeb;
  if (possibleToShowTwoatsedMessage) {
    Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_LONG);
  } else {
    showModalBottomSheet(
      context: context,
      builder: (context) => Center(
        child: Text(msg),
      ),
    );
  }
}
