import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hr_platform/src/auth/is_authenticated.dart';
import 'package:hr_platform/src/core/initialization.dart';
import 'package:hr_platform/src/screens/auth/login/login_page.dart';
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
  await FastCachedImageConfig.init();
  setPathUrlStrategy();
  await Hive.initFlutter("hr_platform");
  await Hive.openBox("info");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
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
      initialRoute: '/',
      routes: {
        '/': (contex) => const Initialization(),
      },
      onGenerateRoute: (settings) {
        if (isAuthenticated()) {
          // login route
          if (settings.name == '/login') {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) {
                return const LoginPage();
              },
            );
          }

          if (settings.name!.startsWith("/home")) {
            Initialization(
              namePath: settings.name!.replaceFirst("/home", ""),
            );
          }

          return MaterialPageRoute(
            settings: settings,
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: Text(
                    "${settings.name ?? ""}\nsomething went worng",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return MaterialPageRoute(
            settings: const RouteSettings(name: '/login'),
            builder: (context) {
              return const LoginPage();
            },
          );
        }
      },
    );
  }
}
