import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
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
    CategoriesPage(), // PageNames.categories
    ProvidersPage(), // PageNames.providers
    BlogsPage(), // PageNames.blog
    ClassesPage(), // PageNames.myClasses
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
                                icon: IconlyLight.category,
                                text: appText.categories),
                            GButton(
                                icon: IconlyLight.user,
                                text: appText.providers),
                            GButton(
                                icon: IconlyLight.activity, text: appText.blog),
                            GButton(
                                icon: IconlyLight.profile,
                                text: appText.myClassess),
                          ];
                          return Container(
                            width: double.infinity, // Full width of the screen
                            // Background color for the navbar
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    24), // Top-left corner radius
                                topRight: Radius.circular(
                                    24), // Top-right corner radius
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom:
                                      8.0), // Adjust padding only at the top if needed
                              child: GNav(
                                rippleColor: primaryColor.withOpacity(0.3),
                                hoverColor: Colors.grey.shade700,
                                haptic: true, // Haptic feedback
                                tabBorderRadius: 16,
                                curve: Curves.easeIn, // Tab animation curves
                                duration: const Duration(
                                    milliseconds:
                                        300), // Tab animation duration
                                gap: 8,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal:
                                        12), // Increased vertical padding
                                color: Colors.grey, // Unselected icon color
                                activeColor:
                                    primaryColor, // Selected icon and text color
                                iconSize: 24, // Tab button icon size
                                tabBackgroundColor:
                                    primaryColor.withOpacity(0.1),
                                backgroundColor: Colors.transparent,
                                tabs: navbarItems,
                                onTabChange: (index) {
                                  setState(() {
                                    setState(() {
                                      _selectedIndex = index;
                                      pageProvider.pageController.jumpToPage(index);
                                      pageProvider.setPage(PageNames.values[index]);
                                    });
                                  });
                                },
                                selectedIndex: _selectedIndex,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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

            // AdvancedDrawer(
            //   key: UniqueKey(),
            //   backdropColor: Colors.transparent,
            //   drawer:  const MainDrawer(),
            //   openRatio: .6,
            //   openScale: .75,
            //   animationDuration: const Duration(milliseconds: 150),
            //   animateChildDecoration: false,
            //   animationCurve: Curves.linear,
            //   controller: drawerController,
            //   childDecoration: BoxDecoration(
            //     color: Colors.transparent,
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black.withOpacity(.12),
            //         blurRadius: 30,
            //         offset: const Offset(0, 10),
            //       )
            //     ],
            //   ),
            //   rtlOpening: locator<AppLanguage>().isRtl(),
            //   // backdrop: Container(
            //   //   width: getSize().width,
            //   //   height: getSize().height,
            //   //   color: green63,
            //   //   child: Column(
            //   //     crossAxisAlignment: CrossAxisAlignment.start,
            //   //     children: [
            //   //       space(60),
            //   //       Image.asset(AppAssets.worldPng, width: getSize().width * .8, fit: BoxFit.cover),
            //   //     ],
            //   //   ),
            //   // ),
            //   child:
            // ),
          ),
        );
      }),
    );
  }
}

// @override
// Widget build(BuildContext context) {
//   bottomNavHeight = 110;
//
//
//   if( !kIsWeb ){
//     if(Platform.isIOS){
//
//       SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
//         SystemUiOverlay.top
//       ]);
//     }
//   }
//
//   return PopScope(
//     canPop: false,
//     onPopInvoked: (v){
//       if(locator<PageProvider>().page == PageNames.home){
//         MainWidget.showExitDialog();
//       }else{
//         locator<PageProvider>().setPage(PageNames.home);
//       }
//     },
//     child: Consumer<AppLanguageProvider>(
//       builder: (context, languageProvider, _) {
//
//         drawerController = AdvancedDrawerController();
//         if(locator<DrawerProvider>().isOpenDrawer){
//           drawerController.showDrawer();
//         }else{
//           drawerController.hideDrawer();
//         }
//
//         addListener();
//
//         return directionality(
//           child: Scaffold(
//             resizeToAvoidBottomInset: false,
//             backgroundColor: green77(),
//             body: AdvancedDrawer(
//               key: UniqueKey(),
//               backdropColor: Colors.transparent,
//               drawer: const MainDrawer(),
//               openRatio: .6,
//               openScale: .75,
//               animationDuration: const Duration(milliseconds: 150),
//               animateChildDecoration: false,
//               animationCurve: Curves.linear,
//               controller: drawerController,
//               childDecoration: BoxDecoration(
//                 // borderRadius: Platform.isIOS ? borderRadius() : const BorderRadius.vertical(top: Radius.circular(21)),
//                 // borderRadius: kIsWeb ? null : borderRadius(radius: isOpen ? 20 : 0),
//                 color: Colors.transparent,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(.12),
//                     blurRadius: 30,
//                     offset: const Offset(0, 10)
//                   )
//                 ]
//               ),
//
//               rtlOpening: locator<AppLanguage>().isRtl(),
//               // background
//               backdrop: Container(
//                 width: getSize().width,
//                 height: getSize().height,
//                 color: green63,
//                 // decoration: const BoxDecoration(
//                 //   image: DecorationImage(
//                 //     image: AssetImage(AppAssets.splashPng),
//                 //     fit: BoxFit.cover,
//                 //   )
//                 // ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//
//                     space(60),
//
//                     Image.asset(AppAssets.worldPng,width: getSize().width * .8, fit: BoxFit.cover,),
//                   ],
//                 ),
//               ),
//
//               child: Consumer<PageProvider>(
//                 builder: (context, pageProvider, _) {
//                   return SafeArea(
//                     bottom: !kIsWeb && Platform.isAndroid,
//                     top: false,
//                     child: Scaffold(
//                       backgroundColor: Colors.transparent,
//                       resizeToAvoidBottomInset: false,
//                       extendBody: true,
//                       body: pageProvider.pages[pageProvider.page],
//                       bottomNavigationBar: Directionality(
//                         textDirection: TextDirection.ltr,
//                         child: Consumer<DrawerProvider>(
//                           builder: (context, drawerProvider, _) {
//                             return GNav(
//                               backgroundColor: Colors.transparent,
//                               color: Colors.white,
//                               activeColor: Colors.amber, // Choose the color you want for the active icon
//                               gap: 8,
//                               onTabChange: (index) {
//                                 setState(() {
//                                   _selectedIndex = index;
//                                   // Set the page based on selected index
//                                   switch (index) {
//                                     case 0:
//                                       pageProvider.setPage(PageNames.home);
//                                       break;
//                                     case 1:
//                                       pageProvider.setPage(PageNames.categories);
//                                       break;
//                                     case 2:
//                                       pageProvider.setPage(PageNames.providers);
//                                       break;
//                                     case 3:
//                                       pageProvider.setPage(PageNames.blog);
//                                       break;
//                                     case 4:
//                                       pageProvider.setPage(PageNames.myClasses);
//                                       break;
//                                   }
//                                 });
//                               },
//                               tabItems: [
//                                 GButton(
//                                   icon: Icons.home,
//                                   text: appText.home,
//                                 ),
//                                 GButton(
//                                   icon: Icons.category,
//                                   text: appText.categories,
//                                 ),
//                                 GButton(
//                                   icon: Icons.people,
//                                   text: appText.providers,
//                                 ),
//                                 GButton(
//                                   icon: Icons.library_books,
//                                   text: appText.blog,
//                                 ),
//                                 GButton(
//                                   icon: Icons.camera_alt_rounded,
//                                   text: appText.myClassess,
//                                 ),
//                               ],
//                             );
//
//                             // return Stack(
//                             //   children: [
//                             //
//                             //     // background
//                             //     Positioned.fill(
//                             //       bottom: 0,
//                             //       top: getSize().height - bottomNavHeight,
//                             //       child: ClipRRect(
//                             //         borderRadius: BorderRadius.vertical(
//                             //           bottom: drawerProvider.isOpenDrawer ? const Radius.circular(kIsWeb ? 0 : 20) : Radius.zero
//                             //         ),
//                             //         child: ClipPath(
//                             //           clipper: BottomNavClipper(),
//                             //
//                             //           child: Container(
//                             //             width: getSize().width,
//                             //             height: bottomNavHeight,
//                             //             decoration: BoxDecoration(
//                             //               gradient: LinearGradient(
//                             //                 colors: [
//                             //                   green77(),
//                             //                   Color(0xff8c30e9)
//                             //                 ],
//                             //                 begin: Alignment.topLeft,
//                             //                 end: Alignment.bottomRight
//                             //               )
//                             //             ),
//                             //           ),
//                             //
//                             //
//                             //         ),
//                             //       ),
//                             //     ),
//                             //
//                             //     Positioned.fill(
//                             //       bottom: 0,
//                             //       top: getSize().height - bottomNavHeight,
//                             //       child: Row(
//                             //         mainAxisAlignment: MainAxisAlignment.center,
//                             //         children: [
//                             //
//                             //           MainWidget.navItem(PageNames.categories, pageProvider.page, appText.categories, AppAssets.categorySvg, (){
//                             //             pageProvider.setPage(PageNames.categories);
//                             //           }),
//                             //
//                             //           MainWidget.navItem(PageNames.providers, pageProvider.page, appText.providers, AppAssets.provideresSvg, (){
//                             //             pageProvider.setPage(PageNames.providers);
//                             //           }),
//                             //
//                             //
//                             //           MainWidget.homeNavItem(PageNames.home, pageProvider.page, (){
//                             //             pageProvider.setPage(PageNames.home);
//                             //           }),
//                             //
//                             //
//                             //           MainWidget.navItem(PageNames.blog, pageProvider.page, appText.blog, AppAssets.blogSvg, (){
//                             //             pageProvider.setPage(PageNames.blog);
//                             //           }),
//                             //
//                             //           MainWidget.navItem(PageNames.myClasses, pageProvider.page, appText.myClassess, AppAssets.classesSvg, (){
//                             //             pageProvider.setPage(PageNames.myClasses);
//                             //           }),
//                             //
//                             //         ],
//                             //       )
//                             //     )
//                             //   ],
//                             // );
//                             //
//                             //
//
//                           }
//                         ),
//                       ),
//
//                     ),
//                   );
//                 }
//               )
//             ),
//           )
//         );
//       }
//     ),
//   );
// }
//
//
//
//

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
