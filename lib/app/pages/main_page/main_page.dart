import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/home_page/meetings_page/meetings_page.dart';
import 'package:webinar/app/pages/main_page/providers_page/providers_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/providers/page_provider.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/app/services/user_service/cart_service.dart';
import 'package:webinar/app/services/user_service/rewards_service.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/main_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/database/app_database.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/locator.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../../common/enums/page_name_enum.dart';
import '../../providers/app_language_provider.dart';
import 'blog_page/blogs_page.dart';
import 'categories_page/categories_page.dart';
import 'classes_page/classes_page.dart';
import 'home_page/home_page.dart';

class MainPage extends StatefulWidget {
  static const String pageName = '/main';

  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<int> future;

  static int _selectedIndex = 0; // Track the selected index

  final List<Widget> screens = const [
    HomePage(), // PageNames.home
    ProvidersPage(), // PageNames.providers
    BlogsPage(), // PageNames.blog
    MeetingsPage(), // PageNames.myClasses
  ];

  @override
  void initState() {
    super.initState();

    future = Future<int>(() {
      return 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      AppDataBase.getCoursesAndSaveInDB();

      // addListener();

      FirebaseMessaging.instance.getToken().then((value) {
        try {
          ////print'token : ${value}');
          UserService.sendFirebaseToken(value!);
        } catch (_) {}
      });
    });

    getData();
  }

  getData() {
    CourseService.getReasons();

    AppData.getAccessToken().then((String value) {
      if (value.isNotEmpty) {
        RewardsService.getRewards();
        CartService.getCart();
        UserService.getAllNotification();
      }
    });
  }

  @override
  void dispose() {
    // drawerController.dispose();
    // drawerController.removeListener(addListener);

    super.dispose();
  }

  // addListener(){
  //   drawerController.addListener(() {
  //     if(locator<DrawerProvider>().isOpenDrawer != drawerController.value.visible){
  //
  //       Future.delayed(const Duration(milliseconds: 300)).then((value) {
  //         if(mounted){
  //           locator<DrawerProvider>().setDrawerState(drawerController.value.visible);
  //         }
  //       });
  //     }
  //
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isIOS) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: [SystemUiOverlay.top]);
      }
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (v) {
        if (locator<PageProvider>().page == PageNames.home) {
          MainWidget.showExitDialog();
        } else {
          locator<PageProvider>().setPage(PageNames.home);
          _selectedIndex = 0;
        }
      },
      child: Consumer<AppLanguageProvider>(
          builder: (context, provider, _) {
        // drawerController = AdvancedDrawerController();
        // if (locator<DrawerProvider>().isOpenDrawer) {
        //   drawerController.showDrawer();
        // } else {
        //   drawerController.hideDrawer();
        // }

        // addListener();

        return directionality(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: green77(),
            body: Consumer<PageProvider>(
              builder: (context, pageProvider, _) {
                return SafeArea(
                  bottom: !kIsWeb && Platform.isAndroid,
                  top: false,
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    resizeToAvoidBottomInset: false,
                    extendBody: true,
                    body: PageView(
                      controller: pageProvider.pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedIndex = index;
                          pageProvider.setPage(PageNames.values[index]);
                        });
                      },
                      children: screens,
                    ),
                    bottomNavigationBar: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Consumer<DrawerProvider>(
                        builder: (context, drawerProvider, _) {
                          // Define navbarItems inside the builder so it updates when languageChangedNotifier value changes

                          final navbarItems = [
                            GButton(icon: IconlyLight.home, text: appText.home),
                            GButton(
                                icon: IconlyLight.user,
                                text: appText.providers),
                            GButton(
                                icon: IconlyLight.activity, text: appText.blog),
                            GButton(
                                icon: IconlyLight.camera,
                                text: appText.meeting),
                          ];
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: GNav(
                                rippleColor: primaryColor.withOpacity(0.2),
                                hoverColor: primaryColor.withOpacity(0.1),
                                haptic: true,
                                tabBorderRadius: 20,
                                curve: Curves.easeOutExpo,
                                duration: const Duration(milliseconds: 400),
                                gap: 8,
                                color: Colors.grey[600],
                                activeColor: primaryColor,
                                iconSize: 24,
                                tabBackgroundColor: primaryColor.withOpacity(0.15),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                backgroundColor: Colors.transparent,
                                tabs: navbarItems,
                                onTabChange: (index) {
                                  setState(() {
                                    _selectedIndex = index;
                                    pageProvider.pageController.jumpToPage(index);
                                    pageProvider.setPage(PageNames.values[index]);
                                  });
                                },
                                selectedIndex: _selectedIndex,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}



class BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    Path path = Path();

    path.lineTo(0, 0);
    path.lineTo(0, height);
    path.lineTo(width, height);

    path.lineTo(size.width, 0);
    path.quadraticBezierTo(width, 45, width - 45, 45);

    path.lineTo(45, 45);

    path.quadraticBezierTo(0, 45, 0, 0);

    // path.moveTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
