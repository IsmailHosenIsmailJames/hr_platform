import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SuspendNew extends StatefulWidget {
  const SuspendNew({super.key});

  @override
  State<SuspendNew> createState() => _SuspendNewState();
}

class _SuspendNewState extends State<SuspendNew> {
  TextEditingController idController = TextEditingController();
  Widget searchedUserIDWidget = const Expanded(
      child: Center(
    child: Text("Please search user by ID"),
  ));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suspend New"),
      ),
      body: Center(
        child: SizedBox(
          width: 600,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: idController,
                        validator: (value) {
                          var x = int.tryParse(value!);
                          return x == null ? "Not a valid ID" : null;
                        },
                        decoration: InputDecoration(
                          labelText: "User ID for Suspend",
                          hintText: "Type user id here...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const Gap(10),
                    IconButton(
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade300),
                      onPressed: () async {
                        String id = idController.text.trim();
                        if (int.tryParse(idController.text.trim()) != null) {
                          final response = await FirebaseFirestore.instance
                              .collection('general_user')
                              .doc(id)
                              .get();
                          if (response.exists) {
                            buildUserInfoWidgetForSuspend(response.data()!, id);
                          }
                        }
                      },
                      icon: const Icon(Icons.search_rounded),
                    ),
                  ],
                ),
                const Gap(20),
                searchedUserIDWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void buildUserInfoWidgetForSuspend(Map userData, String id) {
    """ {designation_name: GM, HR, password: Rs@123,
     user_name: MOSTAFA ARIF MAHMUD, 
     company_name: RADIANT PHARMACEUTICALS,
      department_name: Human Resources, 
      job_type_name: Permanent Mgt,
       date_of_joining: 01-Jul-07, 
       email: , cell_phone: }""";
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
    if ((userData['isSuspanded'] ?? "false") != "true") {
      setState(() {
        searchedUserIDWidget = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: listOfWidget +
              [
                const Gap(20),
                ElevatedButton(
                  onPressed: () {
                    suspandUser(user, id);
                  },
                  child: const Text("Suspend"),
                ),
              ],
        );
      });
    } else {
      setState(() {
        searchedUserIDWidget = const Expanded(
          child: Center(
            child: Text("This user already suspended"),
          ),
        );
      });
    }
  }

  void suspandUser(Map<String, String> userData, String id) async {
    userData.addAll({"isSuspanded": "true"});
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
      await FirebaseFirestore.instance
          .collection('general_user')
          .doc(id)
          .update(userData);
      final response = await FirebaseFirestore.instance
          .collection("suspended")
          .doc('suspendedUserMap')
          .get();
      Map<String, dynamic> suspendedList = {};
      if (response.exists && response.data() != null) {
        suspendedList = response.data()!;
      }
      suspendedList.addAll({id: userData});
      if (response.exists) {
        await FirebaseFirestore.instance
            .collection("suspended")
            .doc('suspendedUserMap')
            .update(suspendedList);
      } else {
        await FirebaseFirestore.instance
            .collection("suspended")
            .doc('suspendedUserMap')
            .set(suspendedList);
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
