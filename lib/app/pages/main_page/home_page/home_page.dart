import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
import 'package:webinar/app/pages/main_page/home_page/subscription_page/subscription_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/home_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/shimmer_component.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import '../../../../common/enums/error_enum.dart';
import '../../../../common/utils/currency_utils.dart';
import '../../../../locator.dart';
import '../../../models/course_model.dart';
import '../../../models/subscription_model.dart';
import '../../../providers/app_language_provider.dart';
import '../../../../common/components.dart';
import '../../../providers/filter_course_provider.dart';
import '../../../providers/CategoryDataManagerProvider.dart';
import '../../../services/user_service/subscription_service.dart';
import '../../../widgets/main_widget/main_drawer.dart';
import '../../authentication_page/login_page.dart';

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

  bool isLoadingSubscriptionData = false;
  SubscriptionModel? subscriptionData;

  @override
  void initState() {
    super.initState();

    getToken();

    appBarController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 200),
    );

    appBarAnimation = Tween<double>(
      begin: 70 + MediaQuery.of(navigatorKey.currentContext!).viewPadding.top,
      end: 70 + MediaQuery.of(navigatorKey.currentContext!).viewPadding.top,
    ).animate(appBarController);

    scrollController.addListener(_scrollListener);

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

      // Initialize category data
      Provider.of<CategoryDataManagerProvider>(context, listen: false).fetchData();
    });

    getData();
  }

  @override
  void deactivate() {
    // Stop animations when widget is deactivated (e.g., during navigation)
    appBarController.stop();
    super.deactivate();
  }

  void _scrollListener() {
    if (!mounted) return;
    
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
  }

  void getData() {
    if (!mounted) return;

    setState(() {
      isLoadingFeaturedListData = true;
      isLoadingNewsetListData = true;
      isLoadingBundleData = true;
      isLoadingBestRatedListData = true;
      isLoadingBestSellingListData = true;
      isLoadingDiscountListData = true;
      isLoadingFreeListData = true;
      isLoadingSubscriptionData = true;
    });

    CourseService.featuredCourse().then((value) {
      if (!mounted) return;
      setState(() {
        isLoadingFeaturedListData = false;
        featuredListData = value;
      });
    });

    CourseService.getAll(offset: 0, bundle: true).then((value) {
      if (!mounted) return;
      setState(() {
        isLoadingBundleData = false;
        bundleData = value;
      });
    });

    CourseService.getAll(offset: 0, sort: 'newest').then((value) {
      if (!mounted) return;
      setState(() {
        isLoadingNewsetListData = false;
        newsetListData = value;
      });
    });

    CourseService.getAll(offset: 0, sort: 'best_rates').then((value) {
      if (!mounted) return;
      setState(() {
        isLoadingBestRatedListData = false;
        bestRatedListData = value;
      });
    });

    CourseService.getAll(offset: 0, sort: 'bestsellers').then((value) {
      if (!mounted) return;
      setState(() {
        isLoadingBestSellingListData = false;
        bestSellingListData = value;
      });
    });

    CourseService.getAll(offset: 0, discount: true).then((value) {
      if (!mounted) return;
      setState(() {
        isLoadingDiscountListData = false;
        discountListData = value;
      });
    });

    CourseService.getAll(offset: 0, free: true).then((value) {
      if (!mounted) return;
      setState(() {
        isLoadingFreeListData = false;
        freeListData = value;
      });
    });

    SubscriptionService.getSubscription().then((value) {
      if (!mounted) return;
      setState(() {
        isLoadingSubscriptionData = false;
        subscriptionData = value;
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoadingSubscriptionData = false;
      });
      print('Error fetching subscriptions: $error');
    });
  }

  void getToken() async {
    if (!mounted) return;
    
    AppData.getAccessToken().then((value) {
      if (!mounted) return;
      setState(() {
        token = value;
      });

      if (token.isNotEmpty) {
        UserService.getProfile().then((value) async {
          if (!mounted) return;
          if (value != null) {
            await AppData.saveName(value.fullName ?? '');
            getUserName();
          }
        });
      }
    });

    getUserName();
  }

  void getUserName() {
    if (!mounted) return;
    
    AppData.getName().then((value) {
      if (!mounted) return;
      setState(() {
        name = value;
      });
    });
  }

  @override
  void dispose() {
    // Ensure all controllers are disposed
    if (mounted) {
      scrollController.removeListener(_scrollListener);
      scrollController.dispose();
      sliderPageController.dispose();
      adSliderPageController.dispose();
      searchController.dispose();
      searchNode.dispose();
    }
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
            appBar: appbar(
                title: appText.home,
                leftIcon: AppAssets.menuSvg,
                onTapLeftIcon: () {
                  _scaffoldKey.currentState?.openDrawer();
                },

            ), 
            body: Container(
              color: backgroundColor,
              child: CustomScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // New Hero Section (shown when not authenticated)
                  SliverToBoxAdapter(
                    child: Container(
                      height: 500,
                      child: Stack(
                        children: [
                          // Blurred background image with gradient overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    green77().withOpacity(0.1),
                                    blueFE.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: ClipRRect(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ImageFiltered(
                                      imageFilter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                                      child: Image.asset(
                                        AppAssets.design1,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.2),
                                            Colors.black.withOpacity(0.4),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Content (text and buttons)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Welcome to Cognistar',
                                      style: style16Bold().copyWith(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  space(24),
                                  Text(
                                    'The Ultimate Online Learning Platform for IGCSE Success',
                                    style: style24Bold().copyWith(
                                      color: Colors.white,
                                      height: 1.3,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  space(16),
                                  Text(
                                    'Live interactive lessons tailored for IGCSE success—learn, engage, and excel!',
                                    style: style16Regular().copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  space(32),
                                  Row(
                                    children: [
                                      if(token.isEmpty)
                                      Expanded(
                                        child: Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [green77(), green77().withOpacity(0.8)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(28),
                                            boxShadow: [
                                              BoxShadow(
                                                color: green77().withOpacity(0.3),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                nextRoute(LoginPage.pageName);
                                              },
                                              borderRadius: BorderRadius.circular(28),
                                              child: Center(
                                                child: Text(
                                                  'Login',
                                                  style: style16Bold().copyWith(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      space(0, width: 16),
                                      Expanded(
                                        child: Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(28),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                locator<FilterCourseProvider>().clearFilter();
                                                nextRoute(FilterCategoryPage.pageName);
                                              },
                                              borderRadius: BorderRadius.circular(28),
                                              child: Center(
                                                child: Text(
                                                  'Categories',
                                                  style: style16Bold().copyWith(color: green77()),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Featured Courses Slider
                  if (featuredListData.isNotEmpty || isLoadingFeaturedListData)
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 32, bottom: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Featured Courses',
                                      style: style24Bold().copyWith(color: grey33),
                                    ),
                                    space(4),
                                    Text(
                                      'Handpicked courses for you',
                                      style: style14Regular().copyWith(color: greyA5),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: green77().withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${featuredListData.length} Courses',
                                    style: style12Bold().copyWith(color: green77()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 320,
                            child: PageView.builder(
                              controller: sliderPageController,
                              onPageChanged: (index) {
                                setState(() {
                                  currentSliderIndex = index;
                                });
                              },
                              itemCount: isLoadingFeaturedListData ? 1 : featuredListData.length,
                              itemBuilder: (context, index) {
                                if (isLoadingFeaturedListData) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    child: courseItemVerticallyShimmer(),
                                  );
                                }
                                
                                final course = featuredListData[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Course Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(32),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              course.image ?? '',
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: greyE7,
                                                  child: Icon(Icons.image_not_supported, color: greyA5, size: 40),
                                                );
                                              },
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black.withOpacity(0.7),
                                                    Colors.black.withOpacity(0.9),
                                                  ],
                                                  stops: const [0.0, 0.5, 1.0],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Gradient Overlay
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(32),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.7),
                                                Colors.black.withOpacity(0.9),
                                              ],
                                              stops: const [0.0, 0.5, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Content
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: green77().withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.star_rounded, color: green77(), size: 16),
                                                    space(0, width: 8),
                                                    Text(
                                                      'Featured',
                                                      style: style12Bold().copyWith(color: green77()),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              space(16),
                                              Text(
                                                course.title ?? '',
                                                style: style24Bold().copyWith(
                                                  color: Colors.white,
                                                  height: 1.3,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              space(12),
                                              Text(
                                                course.description ?? '',
                                                style: style14Regular().copyWith(
                                                  color: Colors.white.withOpacity(0.9),
                                                  height: 1.5,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              space(20),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(30),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.1),
                                                          blurRadius: 10,
                                                          offset: const Offset(0, 5),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      CurrencyUtils.calculator(course.price),
                                                      style: style16Bold().copyWith(color: green77()),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [green77(), green77().withOpacity(0.8)],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                      borderRadius: BorderRadius.circular(30),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: green77().withOpacity(0.3),
                                                          blurRadius: 10,
                                                          offset: const Offset(0, 5),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.star_rounded, color: Colors.white, size: 16),
                                                        space(0, width: 8),
                                                        Text(
                                                          course.rate?.toString() ?? '0.0',
                                                          style: style14Bold().copyWith(color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
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
                              },
                            ),
                          ),
                          space(24),
                          // Page Indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              isLoadingFeaturedListData ? 1 : featuredListData.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: currentSliderIndex == index ? 32 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: currentSliderIndex == index ? green77() : greyE7,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: currentSliderIndex == index ? [
                                    BoxShadow(
                                      color: green77().withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ] : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Categories Section
                  SliverToBoxAdapter(
                    child: Consumer<CategoryDataManagerProvider>(
                      builder: (context, categoryProvider, _) {
                        if (categoryProvider.isLoading) {
                          return Container(
                            height: 160,
                            margin: const EdgeInsets.only(top: 32),
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              children: List.generate(
                                5,
                                (index) => Container(
                                  width: 140,
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final categories = categoryProvider.categories;
                        if (categories.isEmpty) return const SizedBox.shrink();

                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 32, bottom: 20),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Categories',
                                        style: style24Bold().copyWith(color: grey33),
                                      ),
                                      space(4),
                                      Text(
                                        'Browse by category',
                                        style: style14Regular().copyWith(color: greyA5),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: green77().withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${categories.length} Categories',
                                      style: style12Bold().copyWith(color: green77()),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 160,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  final categoryColor = _getCategoryColor(index);
                                  
                                  return GestureDetector(
                                    onTap: () {
                                      nextRoute(FilterCategoryPage.pageName, arguments: category);
                                    },
                                    child: Container(
                                      width: 140,
                                      margin: const EdgeInsets.only(right: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: categoryColor.withOpacity(0.1),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: categoryColor.withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  categoryColor.withOpacity(0.2),
                                                  categoryColor.withOpacity(0.1),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _getCategoryIcon(index),
                                              color: categoryColor,
                                              size: 28,
                                            ),
                                          ),
                                          space(16),
                                          Text(
                                            category.title ?? '',
                                            style: style14Bold().copyWith(
                                              color: categoryColor,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Newest Classes Section
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        if (subscriptionData?.subscribed == true) ...{
                          if (newsetListData.isNotEmpty || isLoadingNewsetListData) ...{
                            if (newsetListData.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 32, bottom: 20),
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appText.newestClasses,
                                          style: style24Bold().copyWith(color: grey33),
                                        ),
                                        space(4),
                                        Text(
                                          'Discover our latest courses',
                                          style: style14Regular().copyWith(color: greyA5),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: green77().withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${newsetListData.length} Courses',
                                        style: style12Bold().copyWith(color: green77()),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                  isLoadingNewsetListData ? 3 : newsetListData.length,
                                  (index) {
                                    return isLoadingNewsetListData
                                        ? courseItemVerticallyShimmer()
                                        : Container(
                                            margin: const EdgeInsets.only(bottom: 20),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(24),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.08),
                                                  blurRadius: 25,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                              border: Border.all(color: greyE7, width: 1),
                                            ),
                                            child: courseItemVertically(newsetListData[index]),
                                          );
                                  },
                                ),
                              ),
                            )
                          }
                        } else if (!isLoadingSubscriptionData) ...{
                          // Enhanced Subscription Prompt
                          Container(
                            margin: const EdgeInsets.all(24),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                              border: Border.all(color: greyE7, width: 1),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        green77().withOpacity(0.1),
                                        green77().withOpacity(0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 56,
                                    color: green77(),
                                  ),
                                ),
                                space(32),
                                Text(
                                  'Unlock Premium Content',
                                  style: style24Bold().copyWith(
                                    color: grey33,
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                space(16),
                                Text(
                                  'Get unlimited access to all courses and features with our premium subscription plans',
                                  style: style16Regular().copyWith(
                                    color: greyA5,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                space(32),
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [green77(), green77().withOpacity(0.8)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: green77().withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        if (token.isEmpty) {
                                          nextRoute(LoginPage.pageName);
                                          showSnackBar(ErrorEnum.alert, appText.loginDesc);
                                        } else {
                                          nextRoute(SubscriptionPage.pageName);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(28),
                                      child: Center(
                                        child: Text(
                                          'View Subscription Plans',
                                          style: style16Bold().copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        }
                      ],
                    ),
                  ),

                  // Bottom padding
                  SliverToBoxAdapter(
                    child: space(150),
                  ),
                ],
              ),
            ),
          ),
        );
      }));
    });
  }

  Color _getCategoryColor(int index) {
    final colors = [
      green77(),
      blueFE,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(int index) {
    final icons = [
      Icons.school,
      Icons.computer,
      Icons.business,
      Icons.psychology,
      Icons.science,
      Icons.architecture,
      Icons.music_note,
      Icons.sports_esports,
      Icons.language,
      Icons.health_and_safety,
      Icons.brush,
      Icons.code,
    ];
    return icons[index % icons.length];
  }
}
