import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
                  builder: (context) => SuspendNew(),
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
                  Map suspendedUserMap = Map.from(snapshot.data!.data()!);
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: suspendedUserMap.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 100,
                        color: Colors.green,
                        margin: const EdgeInsets.all(5),
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
          )),
    );
  }
}
