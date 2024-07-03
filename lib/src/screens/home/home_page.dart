import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hr_platform/src/core/fluttertoast/fluttertoast_message.dart';
import 'package:hr_platform/src/models/files_model.dart';
import 'package:hr_platform/src/models/folders_model.dart';
import 'package:hr_platform/src/screens/add_new_files/add_new_file.dart';
import 'package:hr_platform/src/screens/add_new_folder/add_new_folder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/data/get_data_form_hive.dart';

class HomePage extends StatefulWidget {
  final String path;
  const HomePage({super.key, required this.path});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    }
    await Hive.box("info").delete("userData");
    Navigator.pushNamedAndRemoveUntil(
      // ignore: use_build_context_synchronously
      context,
      "/login",
      (route) => true,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> toShowWidgets = getWidgetsOfFilesFolder();
    bool isAdmin = FirebaseAuth.instance.currentUser!.email != null &&
        FirebaseAuth.instance.currentUser!.email!.isNotEmpty;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        bool? canPop = widget.path.split('/').length > 2;
        if (canPop == true) {
          int lastSalah = widget.path.lastIndexOf('/');
          String toGo = widget.path.substring(0, lastSalah);
          print(widget.path);
          print(toGo);
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/home$toGo",
            (route) => false,
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        floatingActionButton: isAdmin
            ? FloatingActionButton(
                onPressed: null,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      size: 30,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Add new",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const Divider(),
                              const Gap(20),
                              SizedBox(
                                width: 300,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AddNewFile(
                                            path: widget.path,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  label: const Text(
                                    "Add new file",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  icon: const Icon(
                                      FluentIcons.document_24_regular),
                                ),
                              ),
                              const Gap(10),
                              SizedBox(
                                width: 300,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AddNewFolder(
                                            path: widget.path,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  label: const Text(
                                    "Add new folder",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  icon:
                                      const Icon(FluentIcons.folder_24_regular),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
              )
            : null,
        appBar: AppBar(
          title: Text(widget.path),
        ),
        drawer: const Drawer(),
        body: SafeArea(
          child: toShowWidgets.isEmpty
              ? const Center(child: Text("No files or folders found"))
              : Wrap(
                  children: toShowWidgets,
                ),
        ),
      ),
    );
  }

  int downloadPercentage = 0;

  List<Widget> getWidgetsOfFilesFolder() {
    List<Map> allData = getCurrentPossitionListOfData();
    Map<String, List<Map>> filteredMap = {};
    for (Map singleData in allData) {
      String parent = singleData['parent'];
      List<Map> parentDataList = filteredMap[parent] ?? [];
      parentDataList.add(singleData);
      filteredMap.addAll({parent: parentDataList});
    }
    List<Map> cureentLayerData = filteredMap[widget.path] ?? [];
    List<Widget> toReturn = [];

    for (int index = 0; index < cureentLayerData.length; index++) {
      Map<String, dynamic> cureent =
          Map<String, dynamic>.from(cureentLayerData[index]);

      bool isFile = cureent['is-file'];
      if (isFile) {
        FilesModel cureentModel = FilesModel.fromMap(cureent);
        toReturn.add(
          Container(
            height: 180,
            width: 180,
            margin: const EdgeInsets.all(10),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.withOpacity(0.5),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(cureentModel.path))) {
                  launchUrl(Uri.parse(cureentModel.path));
                } else {
                  if (cureentModel.type == "jpeg" ||
                      cureentModel.type == "jpg" ||
                      cureentModel.type == "png") {
                    showDialog(
                      // ignore: use_build_context_synchronously
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: FastCachedImage(
                            url: cureentModel.path,
                            loadingBuilder: (p0, p1) {
                              return CircularProgressIndicator(
                                value: p1.progressPercentage.value,
                              );
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    showFluttertoastMessage(
                        "This file type can not directly open. Download it.");
                  }
                }
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FastCachedImageProvider(
                      cureentModel.image ??
                          "http://116.68.200.97:6027/static/media/form.54693b5d.png",
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PopupMenuButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.5),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: () async {
                                String? directory = await FilePicker.platform
                                    .getDirectoryPath();
                                showFluttertoastMessage("Downloading");
                                if (directory == null) {
                                  showFluttertoastMessage(
                                      "Folder did not selected. Download Cancle");
                                }
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.download),
                                  Gap(5),
                                  Text("Download"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                FlutterClipboard.copy(cureentModel.path).then(
                                  (value) => showFluttertoastMessage(
                                      "Copied : ${cureentModel.path}"),
                                );
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.link),
                                  Gap(5),
                                  Text("Copy link"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Are you sure?"),
                                    content: const Text(
                                        "After deleten data, it can not recover again"),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        onPressed: () async {
                                          showFluttertoastMessage(
                                              "Deleating ${widget.path}/${cureentModel.name}.${cureentModel.type}");
                                          try {
                                            await FirebaseStorage.instance
                                                .ref()
                                                .child(cureentModel.fileRef)
                                                .delete();
                                          } catch (e) {
                                            showFluttertoastMessage(
                                                "Something went worng");
                                          }
                                          try {
                                            await FirebaseStorage.instance
                                                .ref()
                                                .child(
                                                    cureentModel.coverImageRef)
                                                .delete();
                                          } catch (e) {
                                            showFluttertoastMessage(
                                                "Something went worng");
                                          }
                                          int indexAt = -1;

                                          for (var i = 0;
                                              i < allData.length;
                                              i++) {
                                            if (cureentModel.parent ==
                                                    allData[i]["parent"] &&
                                                cureentModel.path ==
                                                    allData[i]["path"]) {
                                              indexAt = i;
                                              break;
                                            }
                                          }
                                          if (indexAt == -1) {
                                            showFluttertoastMessage(
                                                "Something went worng");
                                          }
                                          allData.removeAt(indexAt);
                                          await FirebaseFirestore.instance
                                              .collection('data')
                                              .doc("data-map")
                                              .update({"data-map": allData});
                                          final box = Hive.box("info");
                                          await box.put(
                                              'data',
                                              jsonEncode(
                                                  {"data-map": allData}));
                                          showFluttertoastMessage(
                                              "Successfull Deleation");
                                          Navigator.pushNamedAndRemoveUntil(
                                            // ignore: use_build_context_synchronously
                                            context,
                                            "/home${widget.path}",
                                            (route) => false,
                                          );
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  Gap(5),
                                  Text("Delete"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding:
                          const EdgeInsets.only(left: 3, top: 1, bottom: 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          const Icon(FluentIcons.document_24_regular),
                          const Gap(5),
                          Text(
                            cureentModel.name.length > 17
                                ? "${cureentModel.name.substring(0, 17)}...${cureentModel.type}"
                                : "${cureentModel.name}.${cureentModel.type}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        FolderModel cureentModel = FolderModel.fromMap(cureent);
        toReturn.add(
          Container(
            height: 180,
            width: 180,
            margin: const EdgeInsets.all(10),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.withOpacity(0.5),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/home${widget.path}/${cureentModel.name}",
                  (route) => false,
                );
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FastCachedImageProvider(
                      cureentModel.image ??
                          "http://116.68.200.97:6027/static/media/form.54693b5d.png",
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
                alignment: Alignment.bottomRight,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.5),
                      child: const Icon(FluentIcons.folder_24_regular),
                    ),
                    const Gap(10),
                    Text(
                      cureentModel.name.length > 20
                          ? cureentModel.name.substring(0, 20)
                          : cureentModel.name,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
    return toReturn;
  }
}
