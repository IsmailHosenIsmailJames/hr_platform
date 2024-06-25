import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hr_platform/src/routes/routes.dart';
import 'package:url_strategy/url_strategy.dart';

import 'firebase_options.dart';

// void _isolateMain(RootIsolateToken rootIsolateToken) async {
//   BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isWindows) {
  //   RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
  //   Isolate.spawn(_isolateMain, rootIsolateToken);
  // }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setPathUrlStrategy();
  await Hive.initFlutter("hr_platform");
  await Hive.openBox("info");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade800,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
          ),
        ),
      ),
      routerConfig: AppRoutes.routes(),
    );
  }
}
