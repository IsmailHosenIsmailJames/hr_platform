// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../android/in_app_update_android.dart';
import '../api.dart';

void showDialogForDeskTopUpdate(
  BuildContext context,
  String deviceV,
  String lastV,
  Map<String, dynamic> jsonData,
) async {
  String changes = jsonData['changes'];
  List files = jsonData['files'];
  String? apkURL;
  for (var e in files) {
    if (e['filename'].toString().contains("exe") ||
        e['filename'].toString().contains("msi")) {
      apkURL = ApiOfInAppUpdate().base + e['path'];
    }
  }
  if (apkURL == null) {
    return;
  }

  String? apkFilePathOnDevice;

  final directory = await getApplicationDocumentsDirectory();
  String p = join(directory.path, lastV, apkURL.split("/").last);

  bool isExitsErliter = await File(p).exists();

  if (!isExitsErliter) {
    await showDialog(
      context: context,
      builder: (context) {
        final processController = Get.put(ProcessInicator());
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Gap(20),
                const Icon(
                  Icons.system_update_alt_rounded,
                  size: 60,
                ),
                const Gap(20),
                GetX<ProcessInicator>(
                  builder: (controller) => Text(
                    controller.percentage.value,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                const Gap(10),
                const Text(
                  "Changes : ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(changes),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(10)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Not now",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    const Gap(20),
                    ElevatedButton(
                      onPressed: () async {
                        final dio = Dio();

                        await dio.download(
                          apkURL!,
                          p,
                          onReceiveProgress: (received, total) {
                            if (total != -1) {
                              processController.percentage.value =
                                  "Downloading : ${(received / total * 100).toStringAsFixed(0)}%";
                            }
                          },
                        );

                        apkFilePathOnDevice = p;
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Download",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  } else {
    apkFilePathOnDevice = p;
  }

  if (apkFilePathOnDevice != null) {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Gap(20),
                const Icon(
                  Icons.system_update_alt_rounded,
                  size: 60,
                ),
                const Gap(20),
                const Text(
                  "Ready for install the update!",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const Gap(10),
                const Text(
                  "Changes : ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(changes),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(10)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Not now",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    const Gap(10),
                    ElevatedButton(
                      onPressed: () async {
                        Process.run(apkFilePathOnDevice!, [])
                            .then((ProcessResult results) {});
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Install",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
