import 'package:flutter/material.dart';

class DocumentsPage extends StatefulWidget {
  final int index;
  final String titleName;
  final String description;
  final String iconSVG;
  final String id;
  final Color colorLight;
  final Color colorMedium;
  final Color colorStrong;
  const DocumentsPage({
    super.key,
    required this.index,
    required this.titleName,
    required this.description,
    required this.iconSVG,
    required this.id,
    required this.colorLight,
    required this.colorMedium,
    required this.colorStrong,
  });

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.colorLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
          onPressed: () {
            setState(() {});
          },
          icon: Icon(Icons.repartition)),
    );
  }
}
