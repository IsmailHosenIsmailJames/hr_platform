import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showFluttertoastMessage(String msg,
    {String? description, ToastificationType? type}) {
  toastification.show(
    title: Text(msg),
    description: description != null ? Text(description) : null,
    type: type,
  );
}
