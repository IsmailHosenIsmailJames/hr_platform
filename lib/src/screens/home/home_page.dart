// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
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
import 'package:hr_platform/src/screens/home/drawer/drawer.dart';
import 'package:hr_platform/src/theme/break_point.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/data/get_data_form_hive.dart';
import '../../core/in_app_update/cheak_for_update.dart';
import '../../models/user_model.dart';

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
      context,
      "/login",
      (route) => true,
    );
  }

  @override
  void initState() {
    cheakUpdateAvailable(context);
    super.initState();
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > breakPointWidth;
    bool isMobile = !isDesktop;
    List<String> splitedPath = widget.path.split('/');
    List<Widget> toShowWidgets = getWidgetsOfFilesFolder();
    bool isAdmin = FirebaseAuth.instance.currentUser!.email != null &&
        FirebaseAuth.instance.currentUser!.email!.isNotEmpty;
    final box = Hive.box('info');
    UserModel? userModel =
        (!isAdmin) ? UserModel.fromJson(box.get('userData')) : null;

    Widget folderNavigator = Row(
      children: List.generate(
        splitedPath.length,
        (index) {
          if (splitedPath[index].isNotEmpty) {
            return TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                String clickedPath = '';
                for (int i = 0; i <= index; i++) {
                  clickedPath += '${splitedPath[i]}/';
                }
                if (clickedPath[clickedPath.length - 1] == '/') {
                  clickedPath =
                      clickedPath.substring(0, clickedPath.length - 1);
                }
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/home$clickedPath",
                  (route) => false,
                );
              },
              child: Text(
                "${splitedPath[index]}/",
                style: const TextStyle(fontSize: 20),
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (x, didPop) async {
        bool? canPop = widget.path.split('/').length > 2;
        if (canPop == true) {
          int lastSalah = widget.path.lastIndexOf('/');
          String toGo = widget.path.substring(0, lastSalah);
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
        key: scaffoldKey,
        backgroundColor: isDesktop ? Colors.lightBlue.shade400 : null,
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
                                            isURL: false,
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
                                            isURL: true,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  label: const Text(
                                    "Add URL link",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  icon: const Icon(FluentIcons.link_24_regular),
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
        appBar: isMobile
            ? AppBar(
                title: folderNavigator,
              )
            : null,
        endDrawer: MediaQuery.of(context).size.width > breakPointWidth
            ? MyDrawer(
                isAdmin: isAdmin,
              )
            : null,
        drawer: MediaQuery.of(context).size.width <= breakPointWidth
            ? MyDrawer(
                isAdmin: isAdmin,
              )
            : null,
        body: SafeArea(
          child: toShowWidgets.isEmpty
              ? isDesktop
                  ? Column(
                      children: [
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 5,
                              bottom: 5,
                            ),
                            width: breakPointWidth.toDouble(),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: folderNavigator,
                            ),
                          ),
                        ),
                        const Gap(200),
                        const Center(child: Text("No files or folders found"))
                      ],
                    )
                  : const Center(child: Text("No files or folders found"))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      if (isDesktop)
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 5,
                              bottom: 5,
                            ),
                            width: breakPointWidth.toDouble(),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: folderNavigator,
                            ),
                          ),
                        ),
                      Container(
                        width: isDesktop
                            ? MediaQuery.of(context).size.width
                            : null,
                        height: isDesktop
                            ? MediaQuery.of(context).size.height * 0.80
                            : null,
                        padding: isDesktop
                            ? EdgeInsets.only(
                                top: MediaQuery.of(context).size.width * 0.01,
                                bottom:
                                    MediaQuery.of(context).size.width * 0.05,
                                left: MediaQuery.of(context).size.width * 0.05,
                                right: MediaQuery.of(context).size.width * 0.03,
                              )
                            : null,
                        margin: isDesktop
                            ? EdgeInsets.only(
                                top: MediaQuery.of(context).size.width * 0.01,
                                bottom:
                                    MediaQuery.of(context).size.width * 0.05,
                                left: MediaQuery.of(context).size.width * 0.05,
                                right: MediaQuery.of(context).size.width * 0.03,
                              )
                            : null,
                        decoration: isDesktop
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.blue.shade700.withOpacity(0.7),
                              )
                            : null,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isDesktop)
                                Row(
                                  children: [
                                    const Spacer(),
                                    Text(
                                      isAdmin
                                          ? "Admin"
                                          : userModel!.userName ?? "",
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        scaffoldKey.currentState!
                                            .openEndDrawer();
                                      },
                                      icon: const Icon(
                                        Icons.menu,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              const Gap(15),
                              SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Wrap(
                                  children: toShowWidgets,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
        String fileType = cureentModel.type;
        bool isImage = false;
        if (fileType == "jpg" ||
            fileType == "jpeg" ||
            fileType == "png" ||
            fileType == "webp") isImage = true;
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
                if (isImage) {
                  showDialog(
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
                } else if (await canLaunchUrl(Uri.parse(cureentModel.path))) {
                  launchUrl(Uri.parse(cureentModel.path));
                } else {
                  showFluttertoastMessage(
                    "This file type can not directly open. Download it.",
                    context,
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FastCachedImageProvider(
                      isImage
                          ? cureentModel.path
                          : cureentModel.image ??
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
                                if (directory != null) {
                                  showFluttertoastMessage(
                                    "Downloading ${cureentModel.path}",
                                    context,
                                  );
                                  try {
                                    await Dio().download(cureentModel.path,
                                        "$directory/${cureentModel.name}.${cureentModel.type}");
                                    showFluttertoastMessage(
                                      "Successfull Download ${cureentModel.path}",
                                      context,
                                    );
                                  } catch (e) {
                                    showFluttertoastMessage(
                                      "Failed Download ${cureentModel.path}",
                                      context,
                                    );
                                  }
                                }

                                if (directory == null) {
                                  showFluttertoastMessage(
                                    "Folder did not selected. Download Cancle",
                                    context,
                                  );
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
                                      "Copied : ${cureentModel.path}", context),
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
                            if (FirebaseAuth.instance.currentUser!.email !=
                                    null &&
                                FirebaseAuth
                                    .instance.currentUser!.email!.isNotEmpty)
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
                                              "Deleating ${widget.path}/${cureentModel.name}.${cureentModel.type}",
                                              context,
                                            );

                                            try {
                                              await FirebaseStorage.instance
                                                  .ref()
                                                  .child(cureentModel
                                                      .coverImageRef)
                                                  .delete();
                                            } catch (e) {
                                              showFluttertoastMessage(
                                                "Something went worng",
                                                context,
                                              );
                                            }
                                            int indexAt = -1;

                                            for (var i = 0;
                                                i < allData.length;
                                                i++) {
                                              if (cureentModel.parent ==
                                                      allData[i]["parent"] &&
                                                  cureentModel.path ==
                                                      allData[i]["path"] &&
                                                  cureentModel.name ==
                                                      allData[i]["name"]) {
                                                indexAt = i;
                                                break;
                                              }
                                            }
                                            if (indexAt == -1) {
                                              showFluttertoastMessage(
                                                "Something went worng, context",
                                                context,
                                              );
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
                                              "Successfull Deleation, context",
                                              context,
                                            );
                                            Navigator.pushNamedAndRemoveUntil(
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
                          SizedBox(
                            width: 120,
                            child: Text(
                              cureentModel.name.length > 17
                                  ? "${cureentModel.name.substring(0, 17)}...${cureentModel.type}"
                                  : "${cureentModel.name}.${cureentModel.type}",
                            ),
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
                if (cureentModel.url != null) {
                  launchUrl(Uri.parse(cureentModel.url!));
                } else {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/home${widget.path}/${cureentModel.name}",
                    (route) => false,
                  );
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
                        FirebaseAuth.instance.currentUser!.email != null &&
                                FirebaseAuth
                                    .instance.currentUser!.email!.isNotEmpty
                            ? PopupMenuButton(
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.5),
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Are you sure?"),
                                          content: const Text(
                                              "After deleten folder, it can not recover again"),
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
                                                if ((filteredMap[
                                                            "/home${widget.path}/${cureentModel.name}"] ??
                                                        [])
                                                    .isNotEmpty) {
                                                  showFluttertoastMessage(
                                                    "Remove contents under folder first",
                                                    context,
                                                  );
                                                  return;
                                                }
                                                showFluttertoastMessage(
                                                  "Deleating ${widget.path}/${cureentModel.name}.",
                                                  context,
                                                );

                                                int indexAt = -1;

                                                for (var i = 0;
                                                    i < allData.length;
                                                    i++) {
                                                  if (cureentModel.parent ==
                                                          allData[i]
                                                              ["parent"] &&
                                                      cureentModel.name ==
                                                          allData[i]["name"]) {
                                                    indexAt = i;
                                                    break;
                                                  }
                                                }
                                                if (indexAt == -1) {
                                                  showFluttertoastMessage(
                                                    "Something went worng",
                                                    context,
                                                  );
                                                }

                                                try {
                                                  await FirebaseStorage.instance
                                                      .ref()
                                                      .child(cureentModel
                                                          .coverImageRef)
                                                      .delete();
                                                } catch (e) {
                                                  showFluttertoastMessage(
                                                    "Something went worng",
                                                    context,
                                                  );
                                                }

                                                allData.removeAt(indexAt);
                                                await FirebaseFirestore.instance
                                                    .collection('data')
                                                    .doc("data-map")
                                                    .update(
                                                        {"data-map": allData});
                                                final box = Hive.box("info");
                                                await box.put(
                                                    'data',
                                                    jsonEncode(
                                                        {"data-map": allData}));
                                                showFluttertoastMessage(
                                                  "Successfull Deleation",
                                                  context,
                                                );
                                                Navigator
                                                    .pushNamedAndRemoveUntil(
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
                              )
                            : const SizedBox(),
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
                          const Icon(FluentIcons.folder_24_regular),
                          const Gap(5),
                          SizedBox(
                            width: 120,
                            child: Text(
                              cureentModel.name.length > 20
                                  ? cureentModel.name.substring(0, 20)
                                  : cureentModel.name,
                            ),
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
      }
    }
    return toReturn;
  }
}
