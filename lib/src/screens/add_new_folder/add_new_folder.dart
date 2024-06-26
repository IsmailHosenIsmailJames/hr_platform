import 'package:flutter/material.dart';

class AddNewFolder extends StatefulWidget {
  final String path;

  const AddNewFolder({super.key, required this.path});

  @override
  State<AddNewFolder> createState() => _AddNewFolderState();
}

class _AddNewFolderState extends State<AddNewFolder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
    );
  }
}
