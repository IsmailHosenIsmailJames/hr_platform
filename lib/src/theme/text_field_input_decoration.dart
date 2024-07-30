import 'package:flutter/material.dart';

InputDecoration getInputDecooration([String? label, String? hint]) {
  return InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    hintText: hint,
    labelText: label,
  );
}
