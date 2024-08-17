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
import 'package:flutter/cupertino.dart';
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
import 'package:hr_platform/src/screens/pdf_view/pdf_view.dart';
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
  double boxHight = 110;
  double boxWidth = 110;
  @override
  Widget build(BuildContext context) {
    bool canPop = widget.path.split('/').length > 2;
    bool isDesktop = MediaQuery.of(context).size.width > breakPointWidth;
    bool isMobile = !isDesktop;
    List<String> splitedPath = widget.path.split('/');
    List<Widget> toShowWidgets = getWidgetsOfFilesFolder(canPop);
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

    Widget backIcon = IconButton(
      style: IconButton.styleFrom(
        iconSize: 60,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        int lastSalah = widget.path.lastIndexOf('/');
        String toGo = widget.path.substring(0, lastSalah);
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/home$toGo",
          (route) => false,
        );
      },
      icon: const Icon(
        Icons.arrow_back,
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (x, didPop) async {
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
                title: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: folderNavigator,
                ),
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
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: isDesktop
                  ? const DecorationImage(
                      image: AssetImage("assets/dashboard_bg.png"),
                      fit: BoxFit.cover)
                  : null),
          child: SafeArea(
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
                          canPop
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: backIcon,
                                )
                              : const SizedBox()
                        ],
                      )
                    : canPop
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: backIcon,
                          )
                        : const SizedBox()
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
                                      MediaQuery.of(context).size.width * 0.01,
                                  left:
                                      MediaQuery.of(context).size.width * 0.05,
                                  right:
                                      MediaQuery.of(context).size.width * 0.03,
                                )
                              : null,
                          margin: isDesktop
                              ? EdgeInsets.only(
                                  top: MediaQuery.of(context).size.width * 0.01,
                                  bottom:
                                      MediaQuery.of(context).size.width * 0.01,
                                  left:
                                      MediaQuery.of(context).size.width * 0.05,
                                  right:
                                      MediaQuery.of(context).size.width * 0.03,
                                )
                              : null,
                          decoration: isDesktop
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.blue.shade700.withOpacity(0.3),
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
                                    runSpacing: 3,
                                    spacing: 5,
                                    children: <Widget>[
                                          if (canPop)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: backIcon,
                                            )
                                        ] +
                                        toShowWidgets,
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
      ),
    );
  }

  int downloadPercentage = 0;

  List<Widget> getWidgetsOfFilesFolder(bool canBack) {
    List<Map> allData = getCurrentPossitionListOfData();
    Map<String, List<Map>> filteredMap = {};
    Map<String, List<int>> filteredMapIndex = {};
    for (int j = 0; j < allData.length; j++) {
      Map singleData = allData[j];
      String parent = singleData['parent'];
      List<Map> parentDataList = filteredMap[parent] ?? [];
      List<int> parentDataListIndex = filteredMapIndex[parent] ?? [];
      parentDataList.add(singleData);
      parentDataListIndex.add(j);
      filteredMap.addAll({parent: parentDataList});
      filteredMapIndex.addAll({parent: parentDataListIndex});
    }
    List<Map> cureentLayerData = filteredMap[widget.path] ?? [];
    List<int> cureentLayerDataIndex = filteredMapIndex[widget.path] ?? [];

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
          Padding(
            padding: const EdgeInsets.all(5),
            child: TextButton(
              style: TextButton.styleFrom(
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
                } else if (fileType == 'pdf' || fileType == 'PDF') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyPdfView(
                        url: cureentModel.path,
                        name: cureentModel.name,
                      ),
                    ),
                  );
                } else {
                  launchUrl(Uri.parse(cureentModel.path));
                }
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    height: boxHight,
                    width: boxWidth,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      height: boxHight - 50,
                      width: boxWidth - 50,
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
                    ),
                  ),
                  const Gap(5),
                  Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: boxWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Icon(
                                    (fileType == 'pdf' || fileType == 'PDF')
                                        ? FluentIcons.document_pdf_24_regular
                                        : FluentIcons.document_24_regular),
                              ),
                              SizedBox(
                                height: 35,
                                width: 35,
                                child: PopupMenuButton(
                                  style: IconButton.styleFrom(
                                    iconSize: 20,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.5),
                                  ),
                                  itemBuilder: (context) => [
                                    if (FirebaseAuth
                                                .instance.currentUser!.email !=
                                            null &&
                                        FirebaseAuth.instance.currentUser!
                                            .email!.isNotEmpty &&
                                        index > 0)
                                      PopupMenuItem(
                                        onTap: () async {
                                          await moveUPDown(
                                            cureentLayerDataIndex,
                                            index,
                                            allData,
                                            context,
                                            isMoveDown: false,
                                          );
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(FluentIcons
                                                .arrow_up_24_regular),
                                            Gap(5),
                                            Text("Move UP"),
                                          ],
                                        ),
                                      ),
                                    if (FirebaseAuth
                                                .instance.currentUser!.email !=
                                            null &&
                                        FirebaseAuth.instance.currentUser!
                                            .email!.isNotEmpty &&
                                        index < cureentLayerData.length - 1)
                                      PopupMenuItem(
                                        onTap: () async {
                                          await moveUPDown(
                                            cureentLayerDataIndex,
                                            index,
                                            allData,
                                            context,
                                            isMoveDown: true,
                                          );
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(FluentIcons
                                                .arrow_down_24_regular),
                                            Gap(5),
                                            Text("Move Down"),
                                          ],
                                        ),
                                      ),
                                    PopupMenuItem(
                                      onTap: () async {
                                        String? directory = await FilePicker
                                            .platform
                                            .getDirectoryPath();
                                        if (directory != null) {
                                          showFluttertoastMessage(
                                            "Downloading ${cureentModel.path}",
                                            context,
                                          );
                                          try {
                                            await Dio().download(
                                                cureentModel.path,
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
                                        FlutterClipboard.copy(cureentModel.path)
                                            .then(
                                          (value) => showFluttertoastMessage(
                                              "Copied : ${cureentModel.path}",
                                              context),
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
                                    if (FirebaseAuth
                                                .instance.currentUser!.email !=
                                            null &&
                                        FirebaseAuth.instance.currentUser!
                                            .email!.isNotEmpty)
                                      PopupMenuItem(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title:
                                                  const Text("Are you sure?"),
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
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red),
                                                  onPressed: () async {
                                                    showFluttertoastMessage(
                                                      "Deleating ${widget.path}/${cureentModel.name}.${cureentModel.type}",
                                                      context,
                                                    );

                                                    try {
                                                      await FirebaseStorage
                                                          .instance
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
                                                              allData[i]
                                                                  ["parent"] &&
                                                          cureentModel.path ==
                                                              allData[i]
                                                                  ["path"] &&
                                                          cureentModel.name ==
                                                              allData[i]
                                                                  ["name"]) {
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
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('data')
                                                        .doc("data-map")
                                                        .update({
                                                      "data-map": allData
                                                    });
                                                    final box =
                                                        Hive.box("info");
                                                    await box.put(
                                                        'data',
                                                        jsonEncode({
                                                          "data-map": allData
                                                        }));
                                                    showFluttertoastMessage(
                                                      "Successfull Deleation, context",
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
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: boxHight,
                          child: Text(
                            cureentModel.name,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        FolderModel cureentModel = FolderModel.fromMap(cureent);
        toReturn.add(
          Padding(
            padding: const EdgeInsets.all(5),
            child: TextButton(
              style: TextButton.styleFrom(
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
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: boxHight,
                    width: boxWidth,
                    alignment: Alignment.center,
                    child: Container(
                      height: boxHight - 50,
                      width: boxWidth - 50,
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        height: boxHight,
                        width: boxWidth,
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
                      ),
                    ),
                  ),
                  const Gap(5),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: boxWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Icon(cureentModel.url == null
                                    ? FluentIcons.folder_24_regular
                                    : FluentIcons.link_24_regular),
                              ),
                              FirebaseAuth.instance.currentUser!.email !=
                                          null &&
                                      FirebaseAuth.instance.currentUser!.email!
                                          .isNotEmpty
                                  ? SizedBox(
                                      height: 35,
                                      width: 35,
                                      child: PopupMenuButton(
                                        style: IconButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          iconSize: 20,
                                          backgroundColor:
                                              Colors.white.withOpacity(0.5),
                                        ),
                                        itemBuilder: (context) => [
                                          if (FirebaseAuth.instance.currentUser!
                                                      .email !=
                                                  null &&
                                              FirebaseAuth.instance.currentUser!
                                                  .email!.isNotEmpty &&
                                              index > 0)
                                            PopupMenuItem(
                                              onTap: () async {
                                                await moveUPDown(
                                                  cureentLayerDataIndex,
                                                  index,
                                                  allData,
                                                  context,
                                                  isMoveDown: false,
                                                );
                                              },
                                              child: const Row(
                                                children: [
                                                  Icon(FluentIcons
                                                      .arrow_up_24_regular),
                                                  Gap(5),
                                                  Text("Move UP"),
                                                ],
                                              ),
                                            ),
                                          if (FirebaseAuth.instance.currentUser!
                                                      .email !=
                                                  null &&
                                              FirebaseAuth.instance.currentUser!
                                                  .email!.isNotEmpty &&
                                              index <
                                                  cureentLayerData.length - 1)
                                            PopupMenuItem(
                                              onTap: () async {
                                                await moveUPDown(
                                                  cureentLayerDataIndex,
                                                  index,
                                                  allData,
                                                  context,
                                                  isMoveDown: true,
                                                );
                                              },
                                              child: const Row(
                                                children: [
                                                  Icon(FluentIcons
                                                      .arrow_down_24_regular),
                                                  Gap(5),
                                                  Text("Move Down"),
                                                ],
                                              ),
                                            ),
                                          if (FirebaseAuth.instance.currentUser!
                                                      .email !=
                                                  null &&
                                              FirebaseAuth.instance.currentUser!
                                                  .email!.isNotEmpty)
                                            PopupMenuItem(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        "Are you sure?"),
                                                    content: const Text(
                                                        "After deleten folder, it can not recover again"),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            "Cancel"),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    Colors.red),
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
                                                              i <
                                                                  allData
                                                                      .length;
                                                              i++) {
                                                            if (cureentModel
                                                                        .parent ==
                                                                    allData[i][
                                                                        "parent"] &&
                                                                cureentModel
                                                                        .name ==
                                                                    allData[i][
                                                                        "name"]) {
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
                                                            await FirebaseStorage
                                                                .instance
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

                                                          allData.removeAt(
                                                              indexAt);
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'data')
                                                              .doc("data-map")
                                                              .update({
                                                            "data-map": allData
                                                          });
                                                          final box =
                                                              Hive.box("info");
                                                          await box.put(
                                                              'data',
                                                              jsonEncode({
                                                                "data-map":
                                                                    allData
                                                              }));
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
                                                        child: const Text(
                                                            "Delete"),
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
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: boxWidth,
                          child: Text(
                            cureentModel.name,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return toReturn;
  }

  Future<void> moveUPDown(List<int> cureentLayerDataIndex, int index,
      List<Map<dynamic, dynamic>> allData, BuildContext context,
      {bool isMoveDown = false}) async {
    int destinationUpIndex = isMoveDown
        ? cureentLayerDataIndex[index + 1]
        : cureentLayerDataIndex[index - 1];
    int currentIndex = cureentLayerDataIndex[index];
    final tem = allData[destinationUpIndex];
    allData[destinationUpIndex] = allData[currentIndex];
    allData[currentIndex] = tem;
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.grey.withOpacity(0.2),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
    await FirebaseFirestore.instance
        .collection('data')
        .doc("data-map")
        .update({"data-map": allData});

    await Hive.box("info").put("data", jsonEncode({"data-map": allData}));
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      "/home${widget.path}",
      (route) => false,
    );
  }
}
