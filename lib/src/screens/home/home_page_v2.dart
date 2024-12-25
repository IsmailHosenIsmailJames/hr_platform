import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hr_platform/src/theme/break_point.dart';

class HomePageV2 extends StatefulWidget {
  const HomePageV2({super.key});

  @override
  State<HomePageV2> createState() => _HomePageV2State();
}

class _HomePageV2State extends State<HomePageV2> {
  int tabIndex = 0;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final hight = MediaQuery.of(context).size.height;

    bool isMobileView = width < breakPointWidth;

    Widget drawerWidget = Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset("assets/logo_hr.png"),
            ),
            Gap(50),
            getTabs(
              index: 0,
              icon: Icon(FluentIcons.home_24_regular),
              toolTip: "Home",
            ),
            Gap(10),
            getTabs(
              index: 2,
              icon: Icon(FluentIcons.person_24_regular),
              toolTip: "Profile",
            ),
            Gap(10),
            getTabs(
              index: 3,
              icon: Icon(FluentIcons.alert_24_regular),
              toolTip: "Notifications",
            ),
            Gap(10),
            getTabs(
              index: 4,
              icon: Icon(FluentIcons.settings_24_regular),
              toolTip: "Setting",
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: isMobileView ? AppBar() : null,
      drawer: isMobileView
          ? Drawer(
              child: Container(
                width: 80,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                child: drawerWidget,
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobileView)
            Container(
              width: 80,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              child: drawerWidget,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: isMobileView
                  ? EdgeInsets.all(7)
                  : EdgeInsets.only(
                      top: hight * 0.05,
                      left: width * 0.03,
                      right: width * 0.01,
                    ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Good Morning,\nRahim Md. Earteza",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Gap(30),
                  Wrap(
                    children: [
                      generateCard(
                        index: 0,
                        titleName: "Company Policy",
                        description: "Core rules and operationaln guidelines.",
                        iconSVG:
                            """<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="67" height="67" viewBox="0 0 67 67">
                    <image id="insurance" width="67" height="67" xlink:href="data:image/png;base64,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"/>
                  </svg>
                  """,
                      ),
                      generateCard(
                        index: 1,
                        titleName: "Employee Handbook",
                        description:
                            "Key reference for employees' responsibilities.",
                        iconSVG:
                            """<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="67" height="67" viewBox="0 0 67 67">
                    <image id="handbook_1_" data-name="handbook (1)" width="67" height="67" xlink:href="data:image/png;base64,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"/>
                  </svg>
                  """,
                      ),
                      generateCard(
                        index: 2,
                        titleName: "Leaver Management",
                        description: "Structured process for employee exits.",
                        iconSVG:
                            """<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="68" height="68" viewBox="0 0 68 68">
                    <image id="leave" width="68" height="68" xlink:href="data:image/png;base64,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"/>
                  </svg>
                  """,
                      ),
                      generateCard(
                        index: 3,
                        titleName: "Knowledge Management",
                        description:
                            "Capturing and sharing organizational knowledge.",
                        iconSVG:
                            """<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="67" height="67" viewBox="0 0 67 67">
                    <image id="knowledge" width="67" height="67" xlink:href="data:image/png;base64,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"/>
                  </svg>
                  """,
                      ),
                      generateCard(
                        index: 4,
                        titleName: "Forms",
                        description:
                            "Standardized documents for company processes.",
                        iconSVG:
                            """<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="67" height="67" viewBox="0 0 67 67">
                    <image id="request" width="67" height="67" xlink:href="data:image/png;base64,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"/>
                  </svg>
                  """,
                      ),
                      generateCard(
                        index: 5,
                        titleName: "Future Development Plan",
                        description: "Roadmap for company and employee growth.",
                        iconSVG:
                            """<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="67" height="67" viewBox="0 0 67 67">
                    <image id="fast-forward" width="67" height="67" xlink:href="data:image/png;base64,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"/>
                  </svg>
                  """,
                      ),
                      generateCard(
                        index: 6,
                        titleName: "E-Learning",
                        description:
                            "Training platform for employee development.",
                        iconSVG:
                            """<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="67" height="67" viewBox="0 0 67 67">
                    <image id="online-learning" width="67" height="67" xlink:href="data:image/png;base64,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"/>
                  </svg>
                  """,
                      ),
                      generateCard(
                        index: 7,
                        titleName: "Employee Survey",
                        description:
                            "Measure employee satisfaction and engagement.",
                        iconSVG:
                            """<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="67" height="67" viewBox="0 0 67 67">
                    <image id="customer-survey" width="67" height="67" xlink:href="data:image/png;base64,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"/>
                  </svg>
                  """,
                      ),
                      generateCard(
                        index: 8,
                        titleName: "Radiant Chronicle",
                        description:
                            "Internal updates and communication bulletin.",
                        iconSVG:
                            """<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="67" height="67" viewBox="0 0 67 67">
                    <image id="magazine" width="67" height="67" xlink:href="data:image/png;base64,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"/>
                  </svg>
                  """,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget generateCard({
    required int index,
    required String titleName,
    required String description,
    required String iconSVG,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        onPressed: () {},
        child: Container(
          width: 372 * 0.8,
          height: 172 * 0.8,
          decoration: BoxDecoration(
            color: [
              Color.fromARGB(150, 220, 255, 220),
              Color.fromARGB(150, 220, 220, 255),
              Color.fromARGB(150, 255, 220, 220),
            ][index % 3],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              SvgPicture.string(
                """<svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
                                   viewBox="0 0 372 172" style="enable-background:new 0 0 372 172;" xml:space="preserve">
                                <style type="text/css">
                                  .st0{fill:#9DCE91;}
                                </style>
                                <path class="st0" d="M170.99,23.48c0.55,49.04-39.1,89.79-88.14,90.51C46.05,114.53,14.25,92.86,0,61.53V10C0,4.48,4.48,0,10,0
                                  h157.6C169.73,7.47,170.9,15.34,170.99,23.48z"/>
                                <path class="st0" d="M372,82.4V162c0,5.52-4.48,10-10,10h-69.8c-12.04-11.17-19.48-27.22-19.19-45c0.52-31.66,26-57.74,57.63-58.95
                                  C346.45,67.44,360.96,72.96,372,82.4z"/>
                                </svg>
                                """,
                colorFilter: ColorFilter.mode(
                  [
                    Color.fromARGB(150, 200, 255, 200),
                    Color.fromARGB(150, 200, 200, 255),
                    Color.fromARGB(150, 255, 200, 200),
                  ][index % 3],
                  BlendMode.srcIn,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 15),
                    child: Text(
                      titleName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Gap(5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 220,
                            padding: const EdgeInsets.only(top: 15, left: 15),
                            child: Text(
                              description,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          // Spacer(),
                          Padding(
                            padding: EdgeInsets.only(left: 15, top: 10),
                            child: Icon(
                              Icons.arrow_forward,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 15, bottom: 15),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: SvgPicture.string(
                            iconSVG,
                            colorFilter: ColorFilter.mode(
                              [
                                Color.fromARGB(255, 62, 182, 32),
                                Color.fromARGB(255, 34, 173, 145),
                                Color.fromARGB(255, 178, 120, 54),
                              ][index % 3],
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTabs({
    required int index,
    String? svgIcon,
    Widget? icon,
    String? toolTip,
  }) {
    assert(svgIcon != null || icon != null,
        "Both svgIcon and Icon cant be null at the same time");
    return Container(
      height: 54,
      width: 54,
      decoration: BoxDecoration(
        color: tabIndex == index ? Color(0xFFE1FFD9) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          setState(() {
            tabIndex = index;
          });
        },
        tooltip: toolTip,
        icon: icon ??
            SvgPicture.string(
              svgIcon!,
              colorFilter: ColorFilter.mode(
                tabIndex == index ? Colors.green : Colors.black,
                BlendMode.srcIn,
              ),
            ),
      ),
    );
  }
}
