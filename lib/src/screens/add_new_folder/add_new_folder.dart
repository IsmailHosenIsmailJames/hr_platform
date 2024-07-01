import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hr_platform/src/models/folders_model.dart';

import '../../core/data/get_data_form_hive.dart';
import '../../core/fluttertoast/fluttertoast_message.dart';
import '../../theme/text_field_input_decoration.dart';

class AddNewFolder extends StatefulWidget {
  final String path;

  const AddNewFolder({super.key, required this.path});

  @override
  State<AddNewFolder> createState() => _AddNewFolderState();
}

class _AddNewFolderState extends State<AddNewFolder> {
  FilePickerResult? imagePickerResult;
  Uint8List? imageData;
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
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty && uploadTask == null) {
                  var firebaseStorageRef = FirebaseStorage.instance.ref();

                  String? imageUrl;
                  if (imagePickerResult != null) {
                    String image =
                        "${DateTime.now().millisecondsSinceEpoch}_${imagePickerResult!.files.single.name}";
                    firebaseStorageRef = FirebaseStorage.instance.ref();
                    setState(() {
                      uploadTask = firebaseStorageRef
                          .child('cover_images/$image')
                          .putFile(File(imagePickerResult!.files.single.path!));
                    });

                    final snapShot = await uploadTask!.whenComplete(() {});
                    imageUrl = await snapShot.ref.getDownloadURL();
                  }

                  final dataBaseData = FolderModel(
                    parent: widget.path,
                    isFile: false,
                    name: controller.text.trim(),
                    image: imageUrl,
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
                  Navigator.pushNamedAndRemoveUntil(
                    // ignore: use_build_context_synchronously
                    context,
                    widget.path,
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
