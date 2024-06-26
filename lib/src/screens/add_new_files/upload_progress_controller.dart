import 'package:get/get.dart';

class UploadProgressController extends GetxController {
  RxInt percentage = 0.obs;
  RxInt totalBytes = 0.obs;
  RxInt totalUploadedBytes = 0.obs;
  RxString currentJob = "Uploading Files".obs;
}
