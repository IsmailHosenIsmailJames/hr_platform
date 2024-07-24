// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'android/in_app_update_android.dart';
import 'api.dart';
import 'windows/in_app_update_windows.dart';

bool didCheckedOnceForUpdate = false;

void cheakUpdateAvailable(BuildContext context) async {
  try {
    if (!didCheckedOnceForUpdate) {
      didCheckedOnceForUpdate = true;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String deviceAppVersion = packageInfo.version;

      final client = Dio();
      final Response response = await client.get(
          "${ApiOfInAppUpdate().base}${ApiOfInAppUpdate().lastVersionInfo}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsondata =
            Map<String, dynamic>.from(response.data);
        if (kDebugMode) {
          print(jsondata);
        }
        String version = jsondata["version"];

        int vLast = getExtendedVersionNumber(version);
        int vDevice = getExtendedVersionNumber(deviceAppVersion);

        if (vDevice < vLast) {
          if (Platform.isAndroid) {
            showDialogForMobileUpdate(
                context, deviceAppVersion, version, jsondata);
          } else if (Platform.isWindows) {
            showDialogForDeskTopUpdate(
                context, deviceAppVersion, version, jsondata);
          }
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
}

int getExtendedVersionNumber(String version) {
  List versionCells = version.split('.');
  versionCells = versionCells.map((i) => int.parse(i)).toList();
  return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
}
