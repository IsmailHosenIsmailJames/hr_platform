import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hr_platform/src/screens/add_new_files/upload_progress_controller.dart';
import 'package:hr_platform/src/theme/text_field_input_decoration.dart';

class AddNewFile extends StatefulWidget {
  final String path;
  const AddNewFile({super.key, required this.path});

  @override
  State<AddNewFile> createState() => _AddNewFileState();
}

class _AddNewFileState extends State<AddNewFile> {
  Uint8List? data;
  Uint8List? imageData;
  String? slectedFilePath;
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const Text(
              "Add a new file at: ",
              style: TextStyle(fontSize: 14),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.withOpacity(0.5),
                ),
                padding: const EdgeInsets.only(left: 7, top: 3, bottom: 3),
                child: SingleChildScrollView(
                  child: Text(
                    widget.path,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            const Gap(20),
            const Row(
              children: [
                Text(
                  "File title",
                  style: TextStyle(fontSize: 18),
                ),
                Gap(10),
                Text(
                  "*",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.red,
                  ),
                )
              ],
            ),
            const Gap(10),
            TextFormField(
              controller: controller,
              decoration:
                  getInputDecooration("file title", "Type file title here..."),
            ),
            const Gap(15),
            const Text(
              "Preview image",
              style: TextStyle(fontSize: 18),
            ),
            const Gap(7),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: imageData == null
                  ? IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.withOpacity(0.3),
                      ),
                      onPressed: () async {
                        final filesPicked = await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'png'],
                        );
                        if (filesPicked != null) {
                          print("files\nPicked\n");
                          print(filesPicked.files.single.path);

                          imageData = await File(filesPicked.files.single.path!)
                              .readAsBytes();
                          setState(() {});
                        } else {
                          print("files \nnot \npicked\n");
                        }
                      },
                      icon: const Icon(
                        Icons.add_a_photo_rounded,
                        size: 40,
                      ),
                    )
                  : Image.memory(imageData!),
            ),
            const Gap(10),
            const Row(
              children: [
                Text(
                  "Selected File",
                  style: TextStyle(fontSize: 18),
                ),
                Gap(10),
                Text(
                  "*",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.red,
                  ),
                )
              ],
            ),
            const Gap(5),
            data == null
                ? OutlinedButton.icon(
                    onPressed: () async {
                      FilePicker.platform.pickFiles(
                        allowMultiple: false,
                      );
                    },
                    label: const Text(
                      "Select a file",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    icon: const Icon(
                      FluentIcons.document_24_regular,
                    ),
                  )
                : Text(slectedFilePath!),
            const Gap(20),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty && data != null) {
                  final uploadProgressController =
                      Get.put(UploadProgressController());
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        insetPadding: EdgeInsets.zero,
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Obx(
                                () => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      uploadProgressController.currentJob.value,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const Gap(10),
                                    CircularProgressIndicator(
                                      value: uploadProgressController
                                          .percentage.value
                                          .toDouble(),
                                      backgroundColor: Colors.grey,
                                    ),
                                    const Gap(10),
                                    Text(
                                        '${uploadProgressController.totalUploadedBytes}/${uploadProgressController.totalBytes}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => const Center(
                        child: Text("title and file are required")),
                  );
                }
              },
              child: const Text("Let's add the file"),
            ),
          ],
        ),
      ),
    );
  }
}
