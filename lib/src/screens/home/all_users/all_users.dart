import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hr_platform/src/screens/edit_profile/edit_profile.dart';

import '../../../models/user_model.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({super.key});

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  Map<String, UserModel>? allUserMap;
  Map<String, UserModel> constSearchAllUserMap = {};
  Map<String, dynamic>? userMapedData;
  bool isDownloading = false;
  Future<void> getAllUserData() async {
    setState(() {
      isDownloading = true;
    });
    final box = await Hive.openBox("allUserCached");
    Map<String, UserModel> allUser = {};

    if (box.get("data", defaultValue: null) == null) {
      final data =
          await FirebaseFirestore.instance.collection("general_user").get();
      for (QueryDocumentSnapshot<Map<String, dynamic>> element in data.docs) {
        String id = element.id;
        Map<String, dynamic> userData = element.data();
        allUser.addAll({id: UserModel.fromMap(userData)});
      }
      Map toSave = {};
      allUser.forEach(
        (key, value) {
          toSave.addAll({key: value.toMap()});
        },
      );
      await box.put("data", toSave);
      await box.put("time", DateTime.now().millisecondsSinceEpoch);
      setState(() {
        userMapedData = Map<String, dynamic>.from(toSave);
      });
    } else {
      Map data = box.get("data");
      setState(() {
        userMapedData = Map<String, dynamic>.from(data);
      });
      data.forEach(
        (key, value) {
          allUser.addAll({
            key.toString(): UserModel.fromMap(Map<String, dynamic>.from(value))
          });
        },
      );
    }
    setState(() {
      allUserMap = allUser;
      constSearchAllUserMap = allUser;
      searchFieldController.clear();
      isDownloading = false;
    });
  }

  @override
  void initState() {
    getAllUserData();
    super.initState();
  }

  TextEditingController searchFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("All Users"),
        actions: [
          isDownloading
              ? const CircularProgressIndicator()
              : IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Are you sure?"),
                          content: const Text(
                              "This task is heavy and spend resources. If not necessary, try to avoid it."),
                          actions: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              label: const Text("Cancel"),
                              icon: const Icon(Icons.close),
                            ),
                            const Gap(10),
                            ElevatedButton.icon(
                              onPressed: () {
                                getAllUserData();
                                Navigator.pop(context);
                              },
                              label: const Text("Download"),
                              icon: const Icon(Icons.download),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.restore),
                ),
        ],
      ),
      body: Center(
        child: allUserMap != null
            ? Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.shade100,
                ),
                width: 600,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey.shade300,
                        ),
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          controller: searchFieldController,
                          onChanged: (value) {
                            List<String> splited =
                                value.replaceAll(" ", "").split(',');
                            Map<String, UserModel> searchedAllUserMap = {};

                            constSearchAllUserMap.forEach(
                              (key, val) {
                                String toSearch = key + val.toJson();
                                for (var element in splited) {
                                  if (toSearch.contains(element)) {
                                    searchedAllUserMap.addAll({key: val});
                                    break;
                                  }
                                }
                              },
                            );
                            setState(() {
                              allUserMap = searchedAllUserMap;
                            });
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search...",
                            prefixIcon: Icon(
                              FluentIcons.search_24_regular,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: allUserMap!.length,
                        itemBuilder: (context, index) {
                          var tem = allUserMap!.keys.toList();
                          return allUserMap!.isNotEmpty
                              ? buildUserInfoWidgetForSuspend(
                                  allUserMap![tem[index]]!.toMap(), tem[index])
                              : const Text("No Data Found");
                        },
                      ),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  Widget buildUserInfoWidgetForSuspend(Map userData, String id) {
    Map<String, dynamic> user = Map<String, dynamic>.from(userData);
    List<InlineSpan> listOfWidget = [];
    user.forEach(
      (key, value) {
        if ((value ?? "").isNotEmpty) {
          listOfWidget.add(TextSpan(
            text: "$key: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ));
          listOfWidget.add(TextSpan(text: "\t \t \t \t$value\n"));
        }
      },
    );

    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade300,
      ),
      child: Column(children: <Widget>[
        Row(
          children: [
            const Spacer(
              flex: 5,
            ),
            Center(
              child: SelectableText(
                "User ID: $id",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(
              flex: 4,
            ),
            IconButton(
              onPressed: () {
                UserModel model = UserModel.fromMap(
                  Map<String, dynamic>.from(userData),
                );
                model.userID = id;
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditProfile(
                    userModel: model,
                    extraDataTOSave: userMapedData,
                  ),
                ));
              },
              icon: const Icon(Icons.edit),
            ),
            const Gap(10),
          ],
        ),
        const Divider(),
        SelectableText.rich(TextSpan(children: listOfWidget)),
      ]),
    );
  }
}
