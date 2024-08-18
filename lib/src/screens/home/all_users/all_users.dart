import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/adapters.dart';

import '../../../models/user_model.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({super.key});

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  Map<String, UserModel>? allUserMap;
  Map<String, UserModel> constSearchAllUserMap = {};
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
    } else {
      Map data = box.get("data");

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
                              onPressed: () {},
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
    List<Widget> listOfWidget = [];
    user.forEach(
      (key, value) {
        if ((value ?? "").isNotEmpty) {
          listOfWidget.add(
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Row(
                children: [
                  Text(
                    "$key: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Gap(20),
                  Text(value.toString())
                ],
              ),
            ),
          );
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
      child: Column(
        children: <Widget>[
              Center(
                child: Text(
                  "User ID: $id",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Divider()
            ] +
            listOfWidget,
      ),
    );
  }
}
