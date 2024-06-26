import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/adapters.dart';

bool isAuthenticated() {
  return Hive.box('info').get("userData", defaultValue: null) != null &&
      FirebaseAuth.instance.currentUser != null;
}
