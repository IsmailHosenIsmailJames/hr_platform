import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class MyPdfView extends StatelessWidget {
  final String url;
  final String name;
  const MyPdfView({super.key, required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SfPdfViewer.network(
        url,
      ),
    );
  }
}
