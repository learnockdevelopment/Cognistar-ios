import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/home_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/shimmer_component.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/colors.dart';
import '../../../../locator.dart';
import '../../../models/course_model.dart';
import '../../../providers/app_language_provider.dart';
import '../../../../common/components.dart';
import '../../../providers/filter_course_provider.dart';
import '../../../widgets/main_widget/main_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String token = '';
  String name = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();

  late AnimationController appBarController;
  late Animation<double> appBarAnimation;

  double appBarHeight = 230;

  ScrollController scrollController = ScrollController();

  PageController sliderPageController = PageController();
  int currentSliderIndex = 0;

  PageController adSliderPageController = PageController();
  int currentAdSliderIndex = 0;

  bool isLoadingFeaturedListData = false;
  List<CourseModel> featuredListData = [];

  bool isLoadingNewsetListData = false;
  List<CourseModel> newsetListData = [];

  bool isLoadingBestRatedListData = false;
  List<CourseModel> bestRatedListData = [];

  bool isLoadingBestSellingListData = false;
  List<CourseModel> bestSellingListData = [];

  bool isLoadingDiscountListData = false;
  List<CourseModel> discountListData = [];

  bool isLoadingFreeListData = false;
  List<CourseModel> freeListData = [];

  bool isLoadingBundleData = false;
  List<CourseModel> bundleData = [];

  @override
  void initState() {
    super.initState();

    getToken();

    appBarController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    appBarAnimation = Tween<double>(
      begin: 70 + MediaQuery.of(navigatorKey.currentContext!).viewPadding.top,
      end: 70 + MediaQuery.of(navigatorKey.currentContext!).viewPadding.top,
    ).animate(appBarController);

    scrollController.addListener(() {
      if (scrollController.position.pixels > 100) {
        if (!appBarController.isAnimating) {
          if (appBarController.status == AnimationStatus.dismissed) {
            appBarController.forward();
          }
        }
      } else if (scrollController.position.pixels < 50) {
        if (!appBarController.isAnimating) {
          if (appBarController.status == AnimationStatus.completed) {
            appBarController.reverse();
          }
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        if (AppData.canShowFinalizeSheet) {
          AppData.canShowFinalizeSheet = false;

          // finalize signup
          HomeWidget.showFinalizeRegister(
                  (ModalRoute.of(context)!.settings.arguments as int))
              .then((value) {
            if (value) {
              getToken();
            }
          });
        }
      }
    });

    getData();
  }

  void getData() {
    //print("Fetching data started.");

    isLoadingFeaturedListData = true;
    isLoadingNewsetListData = true;
    isLoadingBundleData = true;
    isLoadingBestRatedListData = true;
    isLoadingBestSellingListData = true;
    isLoadingDiscountListData = true;
    isLoadingFreeListData = true;

    CourseService.featuredCourse().then((value) {
      //print("Featured courses fetched: $value");
      if (mounted) {
        setState(() {
          isLoadingFeaturedListData = false;
          featuredListData = value;
        });
      }
    });

    CourseService.getAll(offset: 0, bundle: true).then((value) {
      //print("Bundle courses fetched: $value");
      if (mounted) {
        setState(() {
          isLoadingBundleData = false;
          bundleData = value;
        });
      }
    });

    CourseService.getAll(offset: 0, sort: 'newest').then((value) {
      //print("Newest courses fetched: $value");
      if (mounted) {
        setState(() {
          isLoadingNewsetListData = false;
          newsetListData = value;
        });
      }
    });

    CourseService.getAll(offset: 0, sort: 'best_rates').then((value) {
      //print("Best-rated courses fetched: $value");
      if (mounted) {
        setState(() {
          isLoadingBestRatedListData = false;
          bestRatedListData = value;
        });
      }
    });

    CourseService.getAll(offset: 0, sort: 'bestsellers').then((value) {
      //print("Best-selling courses fetched: $value");
      if (mounted) {
        setState(() {
          isLoadingBestSellingListData = false;
          bestSellingListData = value;
        });
      }
    });

    CourseService.getAll(offset: 0, discount: true).then((value) {
      // //print("Discounted courses fetched: $value");
      if (mounted) {
        setState(() {
          isLoadingDiscountListData = false;
          discountListData = value;
        });
      }
    });

    CourseService.getAll(offset: 0, free: true).then((value) {
      // print("Free courses fetched: $value");
      if (mounted) {
        setState(() {
          isLoadingFreeListData = false;
          freeListData = value;
        });
      }
    });
  }

  void getToken() async {
    // print("Fetching token started.");
    AppData.getAccessToken().then((value) {
      // print("Access token fetched: $value");
      if (mounted) {
        setState(() {
          token = value;
        });
      }

      if (token.isNotEmpty) {
        // print("Token is not empty. Fetching user profile.");
        UserService.getProfile().then((value) async {
          // print("User profile fetched: $value");
          if (value != null) {
            await AppData.saveName(value.fullName ?? '');
            // print("User name saved: ${value.fullName}");
            getUserName();
          }
        });
      }
    });

    getUserName();
  }

  void getUserName() {
    // print("Fetching user name.");
    AppData.getName().then((value) {
      // print("User name fetched: $value");
      if (mounted) {
        setState(() {
          name = value;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguageProvider>(builder: (context, provider, _) {
      return directionality(child:
          Consumer<DrawerProvider>(builder: (context, drawerProvider, _) {
        return ClipRRect(
          borderRadius:
              borderRadius(radius: drawerProvider.isOpenDrawer ? 20 : 0),
          child: Scaffold(
            key: _scaffoldKey,
            drawer: MainDrawer(
              scaffoldKey: _scaffoldKey,
            ),
            body: Container(
              color: backgroundColor, // Set the background
              child: Column(
                children: [
                  // app bar
                  HomeWidget.homeAppBar(appBarController, appBarAnimation,
                      token, searchController, searchNode, name, _scaffoldKey),
                  // body
                  Expanded(
                      child: CustomScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // Newest Classes
                            Column(
                              children: [
                                if (newsetListData.isNotEmpty ||
                                    isLoadingNewsetListData) ...{
                                  if (newsetListData.isNotEmpty)
                                    HomeWidget.titleAndMore(
                                        appText.newestClasses,
                                        onTapViewAll: () {
                                      locator<FilterCourseProvider>()
                                          .clearFilter();
                                      locator<FilterCourseProvider>().sort =
                                          'newest';
                                      nextRoute(FilterCategoryPage.pageName);
                                    }),
                                  SizedBox(
                                    width: getSize().width,
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      padding: padding(),
                                      scrollDirection: Axis.vertical,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: List.generate(
                                          isLoadingNewsetListData
                                              ? 3
                                              : newsetListData.length,
                                          (index) {
                                            return isLoadingNewsetListData
                                                ? courseItemVerticallyShimmer()
                                                : courseItemVertically(
                                                    newsetListData[index]);
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                }
                              ],
                            ),

                            // Bundle
                            Column(
                              children: [
                                if (bundleData.isNotEmpty ||
                                    isLoadingBundleData) ...{
                                  if (bundleData.isNotEmpty)
                                    HomeWidget.titleAndMore(
                                      appText.latestBundles,
                                      onTapViewAll: () {
                                        locator<FilterCourseProvider>()
                                            .clearFilter();
                                        locator<FilterCourseProvider>()
                                            .bundleCourse = true;
                                        nextRoute(FilterCategoryPage.pageName);
                                      },
                                    ),
                                  SizedBox(
                                    width: getSize().width,
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      padding: padding(),
                                      scrollDirection: Axis.horizontal,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: List.generate(
                                          isLoadingBundleData
                                              ? 3
                                              : bundleData.length,
                                          (index) {
                                            return isLoadingBundleData
                                                ? courseItemVerticallyShimmer()
                                                : courseItemVertically(
                                                    bundleData[index]);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                }
                              ],
                            ),
                            space(150),
                          ],
                        ),
                      )
                    ],
                  ))
                ],
              ), // The current page content
            ),
          ),
        );
      }));
    });
  }
}
