import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hr_platform/src/screens/auth/login/login_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart';
import 'package:url_strategy/url_strategy.dart';

import 'firebase_options.dart';
import 'src/screens/home/home_page_v2.dart';

void _isolateMain(RootIsolateToken rootIsolateToken) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    Isolate.spawn(_isolateMain, rootIsolateToken);
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Directory cachedDir = await getApplicationCacheDirectory();
  setPathUrlStrategy();
  await Hive.initFlutter("${cachedDir.path}/hr_platform");
  await Hive.openBox("info");
  await Hive.openBox("surveyLocal");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        defaultTransition: Transition.leftToRight,
        theme: ThemeData.light().copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue.shade800,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
            ),
          ),
        ),
        home: Init(),
        //   initialRoute: '/',
        //   routes: {
        //     '/': (contex) => const Initialization(
        //           namePath: "/home",
        //         ),
        //   },
        //   onGenerateRoute: (settings) {
        //     if (isAuthenticated()) {
        //       // login route
        //       if (settings.name == '/login') {
        //         return MaterialPageRoute(
        //           settings: settings,
        //           builder: (context) {
        //             return const LoginPage();
        //           },
        //         );
        //       }

        //       if (settings.name == '/') {
        //         return MaterialPageRoute(
        //           settings: settings,
        //           builder: (context) {
        //             return const Initialization(namePath: "/home");
        //           },
        //         );
        //       }

        //       if (settings.name != null && settings.name!.startsWith("/survey")) {
        //         String name = settings.name!;
        //         name = name.replaceAll("/survey", "").replaceAll("/", "");
        //         int? id = int.tryParse(name);
        //         if (id != null) {
        //           return MaterialPageRoute(
        //             settings: settings,
        //             builder: (context) {
        //               return AllSurvey(
        //                 surveyID: "$id",
        //               );
        //             },
        //           );
        //         } else {
        //           return MaterialPageRoute(
        //             settings: settings,
        //             builder: (context) {
        //               return const AllSurvey();
        //             },
        //           );
        //         }
        //       }

        //       if (settings.name!.startsWith("/home")) {
        //         return MaterialPageRoute(
        //           settings: settings,
        //           builder: (context) {
        //             return HomePage(path: settings.name!.replaceFirst("/home", ""));
        //           },
        //         );
        //       }

        //       return MaterialPageRoute(
        //         settings: settings,
        //         builder: (context) {
        //           return Scaffold(
        //             body: Center(
        //               child: Text(
        //                 "${settings.name ?? ""}\nsomething went wrong",
        //                 textAlign: TextAlign.center,
        //                 style: const TextStyle(
        //                   fontSize: 20,
        //                 ),
        //               ),
        //             ),
        //           );
        //         },
        //       );
        //     } else {
        //       return MaterialPageRoute(
        //         settings: const RouteSettings(name: '/login'),
        //         builder: (context) {
        //           return const LoginPage();
        //         },
        //       );
        //     }
        //   },
      ),
    );
  }
}

class Init extends StatelessWidget {
  const Init({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(
        Duration(seconds: 1),
        (computationCount) {
          if (FirebaseAuth.instance.currentUser != null &&
              Hive.box("info").get("userData") != null) {
            return true;
          } else {
            return false;
          }
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == true) {
            return HomePageV2();
          } else {
            return LoginPage();
          }
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey.shade300,
                color: Colors.blue,
              ),
            ),
          );
        }
      },
    );
  }
}
