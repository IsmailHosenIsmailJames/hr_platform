import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hr_platform/src/screens/home/suspended_user/suspend_new.dart';

class SuspendedUser extends StatefulWidget {
  const SuspendedUser({super.key});

  @override
  State<SuspendedUser> createState() => _SuspendedUserState();
}

class _SuspendedUserState extends State<SuspendedUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Suspended Users",
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SuspendNew(),
                ),
              );
            },
            label: const Text(
              "Suspend New",
              style: TextStyle(fontSize: 14),
            ),
            icon: const Icon(
              Icons.add,
              size: 18,
            ),
          ),
          const Gap(5)
        ],
      ),
      body: SizedBox(
        width: 600,
        child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection("suspended")
              .doc('suspendedUserMap')
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.exists) {
                Map<String, dynamic> suspendedUserMap =
                    Map<String, dynamic>.from(snapshot.data!.data()!);
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: suspendedUserMap.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: getBuildOfUserInfoWidget(suspendedUserMap[
                                suspendedUserMap.keys.toList()[index]]) +
                            [
                              const Gap(10),
                              ElevatedButton(
                                onPressed: () {
                                  undoSuspend(
                                      suspendedUserMap.keys.toList()[index],
                                      suspendedUserMap);
                                },
                                child: const Text("Undo Suspend"),
                              ),
                            ],
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text("No users are suspended"),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  List<Widget> getBuildOfUserInfoWidget(Map userData) {
    Map<String, String> user = Map<String, String>.from(userData);
    List<Widget> listOfWidget = [];
    user.forEach(
      (key, value) {
        if (value.isNotEmpty) {
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
    return listOfWidget;
  }

  void undoSuspend(String id, Map<String, dynamic> previousData) async {
    try {
      showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.grey.withOpacity(0.1),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
      final response1 = await FirebaseFirestore.instance
          .collection('general_user')
          .doc(id)
          .get();
      if (response1.exists && response1.data() != null) {
        Map<String, dynamic> data = response1.data()!;
        data["isSuspanded"] = "false";
        await FirebaseFirestore.instance
            .collection('general_user')
            .doc(id)
            .update(data);
        previousData.remove(id);
        if (previousData.isEmpty) {
          await FirebaseFirestore.instance
              .collection("suspended")
              .doc('suspendedUserMap')
              .delete();
        } else {
          await FirebaseFirestore.instance
              .collection("suspended")
              .doc('suspendedUserMap')
              .update(previousData);
        }
      }

      Navigator.pushNamedAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        "/",
        (route) => false,
      );
    } on FirebaseException catch (e) {
      showModalBottomSheet(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => Center(
          child: Text(e.message.toString()),
        ),
      );
    }
  }
}
