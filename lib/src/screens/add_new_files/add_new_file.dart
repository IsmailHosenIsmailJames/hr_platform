import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hr_platform/src/core/fluttertoast/fluttertoast_message.dart';
import 'package:hr_platform/src/models/files_model.dart';
import 'package:hr_platform/src/theme/text_field_input_decoration.dart';

import '../../core/data/get_data_form_hive.dart';

class AddNewFile extends StatefulWidget {
  final String path;
  const AddNewFile({super.key, required this.path});

  @override
  State<AddNewFile> createState() => _AddNewFileState();
}

class _AddNewFileState extends State<AddNewFile> {
  Uint8List? data;
  FilePickerResult? imagePickerResult;
  FilePickerResult? filePickerResult;
  Uint8List? imageData;
  String? selectedFilePath;
  UploadTask? uploadTask;
  TextEditingController controller = TextEditingController();
  String tsakState = "Let's add the file";

  void selectCoverImageForFile() async {
    imagePickerResult = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );
    setState(() {});
    if (imagePickerResult != null) {
      imageData =
          await File(imagePickerResult!.files.single.path!).readAsBytes();
      setState(() {});
    } else {
      showFluttertoastMessage("Please select a files");
    }
  }

  void selectFile() async {
    filePickerResult = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );
    setState(() {});
    if (filePickerResult != null) {
      selectedFilePath = filePickerResult!.files.single.path!;
      data = await File(filePickerResult!.files.single.path!).readAsBytes();
      setState(() {});
    } else {
      showFluttertoastMessage("Please select a files");
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.path);
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
            Row(
              children: [
                const Text(
                  "Preview image",
                  style: TextStyle(fontSize: 18),
                ),
                const Spacer(),
                if (imageData != null)
                  TextButton(
                    onPressed: () {
                      selectCoverImageForFile();
                    },
                    child: const Text("Change"),
                  ),
              ],
            ),
            if (imageData == null) const Gap(7),
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
                        selectCoverImageForFile();
                      },
                      icon: const Icon(
                        Icons.add_a_photo_rounded,
                        size: 40,
                      ),
                    )
                  : Image.memory(imageData!),
            ),
            const Gap(10),
            Row(
              children: [
                const Text(
                  "Selected File",
                  style: TextStyle(fontSize: 18),
                ),
                const Gap(10),
                const Text(
                  "*",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.red,
                  ),
                ),
                const Spacer(),
                if (data != null)
                  TextButton(
                    onPressed: () {
                      selectFile();
                    },
                    child: const Text("Change"),
                  ),
              ],
            ),
            if (data == null) const Gap(5),
            data == null
                ? OutlinedButton.icon(
                    onPressed: () async {
                      selectFile();
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
                : Text(selectedFilePath!),
            const Gap(20),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty &&
                    data != null &&
                    uploadTask == null) {
                  String fileName =
                      "${DateTime.now().millisecondsSinceEpoch}_${filePickerResult!.files.single.name}";
                  var firebaseStorageRef = FirebaseStorage.instance.ref();
                  setState(() {
                    uploadTask = firebaseStorageRef
                        .child('files/$fileName')
                        .putFile(File(selectedFilePath!));
                  });

                  var snapShot = await uploadTask!.whenComplete(() {});

                  String fileUrl = await snapShot.ref.getDownloadURL();
                  String? imageUrl;
                  String? image;
                  if (imagePickerResult != null) {
                    image =
                        "${DateTime.now().millisecondsSinceEpoch}_${imagePickerResult!.files.single.name}";
                    firebaseStorageRef = FirebaseStorage.instance.ref();
                    setState(() {
                      uploadTask = firebaseStorageRef
                          .child('cover_images/$image')
                          .putFile(File(imagePickerResult!.files.single.path!));
                    });

                    snapShot = await uploadTask!.whenComplete(() {});
                    imageUrl = await snapShot.ref.getDownloadURL();
                  }

                  final dataBaseData = FilesModel(
                    coverImageRef: image == null ? "" : 'cover_images/$image',
                    fileRef: "files/$fileName",
                    parent: widget.path,
                    isFile: true,
                    name: controller.text.trim(),
                    path: fileUrl,
                    image: imageUrl,
                    type: filePickerResult!.files.single.extension ?? "unknown",
                  );

                  setState(() {
                    uploadTask = null;
                    tsakState = "Updating Data Base";
                  });

                  List<Map> localData = getCurrentPossitionListOfData();
                  localData.add(dataBaseData.toMap());
                  await FirebaseFirestore.instance
                      .collection('data')
                      .doc("data-map")
                      .update({"data-map": localData});
                  setState(() {
                    tsakState = "Done all Task";
                  });
                  await Hive.box("info")
                      .put("data", jsonEncode({"data-map": localData}));
                  Navigator.pushNamedAndRemoveUntil(
                    // ignore: use_build_context_synchronously
                    context,
                    "/home${widget.path}",
                    (route) => false,
                  );
                } else if (uploadTask != null) {
                  showFluttertoastMessage("upload task is not yet finished");
                } else {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => const Center(
                      child: Text(
                        "title and file are required",
                      ),
                    ),
                  );
                }
              },
              child: uploadTask == null
                  ? Text(tsakState)
                  : StreamBuilder(
                      stream: uploadTask!.snapshotEvents,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("File Uploading :"),
                              const Gap(10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  value: (snapshot.data!.bytesTransferred /
                                      snapshot.data!.totalBytes),
                                  color: Colors.green,
                                  backgroundColor: Colors.white,
                                ),
                              )
                            ],
                          );
                        } else {
                          return const Text("Wait...");
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
