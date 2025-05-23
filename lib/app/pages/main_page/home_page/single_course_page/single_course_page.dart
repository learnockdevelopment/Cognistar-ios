import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webinar/app/models/course_model.dart';
import 'package:webinar/app/models/single_course_model.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/learning_page.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/app/services/user_service/cart_service.dart';
import 'package:webinar/app/services/user_service/purchase_service.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/single_course_widget/pod_video_player.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/single_course_widget/course_video_player.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/single_course_widget/single_course_widget.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/single_course_widget/special_offer_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import 'package:webinar/locator.dart';
import '../../../../../common/enums/error_enum.dart';
import '../../../../../common/shimmer_component.dart';
import '../../../../widgets/floating dev id.dart';
import '../../../../../common/utils/currency_utils.dart';
import '../../../../models/content_model.dart';
import '../../../../widgets/main_widget/blog_widget/blog_widget.dart';
import '../../../../widgets/qr.dart';
import '../cart_page/cart_page.dart';

class SingleCoursePage extends StatefulWidget {
  static const String pageName = '/single-course';
  const SingleCoursePage({super.key});

  @override
  State<SingleCoursePage> createState() => _SingleCoursePageState();
}

class _SingleCoursePageState extends State<SingleCoursePage>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  bool isPrivate = false;

  bool isEnrollLoading = false;
  bool isSubscribeLoading = false;
  bool viewMore = false;

  SingleCourseModel? courseData;

  late TabController tabController;
  int currentTab = 0;

  bool showInformationButton = false;
  bool showContentButton = false;
  bool canSubmitComment = false;
  bool canSubmitReview = false;

  String token = '';
  ScrollController scrollController = ScrollController();
  bool isBundleCourse = false;
  List<CourseModel> bundleCourses = [];
  List<ContentModel> contentData = [];
  int? commentId;

  bool isLoading2 = true; // Start with shimmer visible
  bool isVideoReady = false; // To track if the video is ready to show

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    getData();

    scrollController.addListener(() {
      if (scrollController.position.pixels > 250) {
        if (currentTab == 0) {
          // information
          if (!showInformationButton) {
            offAllTabs();
            setState(() {
              showInformationButton = true;
            });
          }
        }
      }
    });

    tabController.addListener(() {
      if (tabController.index == 0) {
        // Information
        if (!showInformationButton) {
          offAllTabs();
          setState(() {
            showInformationButton = true;
          });
        }
      }

      if (tabController.index == 1) {
        // Content
        if (!showContentButton) {
          offAllTabs();
          setState(() {
            showContentButton = true;
          });
        }
      }

      if (tabController.index == 2) {
        // Review
        if (!canSubmitReview) {
          offAllTabs();
          setState(() {
            canSubmitReview = true;
          });
        }
      }

      if (tabController.index == 3) {
        // Comments
        if (!canSubmitComment) {
          offAllTabs();
          setState(() {
            canSubmitComment = true;
          });
        }
      }
    });
  }

  offAllTabs() {
    showContentButton = false;
    showInformationButton = false;
    canSubmitReview = false;
    canSubmitComment = false;
  }

  onChangeTab(int i) {
    setState(() {
      currentTab = i;
    });
  }

  void getData() async {
    if (!mounted) return;
    
    token = await AppData.getAccessToken();
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    // Getting the course ID (bundle id or course id)
    int id = courseData?.id ??
        ((ModalRoute.of(context)?.settings.arguments as List?)?.first ?? 0);

    // Determine if this is a bundle course
    isBundleCourse = courseData != null
        ? courseData?.type == 'bundle'
        : (ModalRoute.of(context)!.settings.arguments as List)[1];

    // Store the ID and type for use in other pages
    if (isBundleCourse) {
      AppData.setBundleId(id);
      AppData.setCourseId(null);
    } else {
      AppData.setCourseId(id);
      AppData.setBundleId(null);
    }

    try {
      commentId =
          commentId ?? (ModalRoute.of(context)!.settings.arguments as List)[2];
    } catch (_) {}

    try {
      isPrivate = (ModalRoute.of(context)!.settings.arguments as List)[3];
    } catch (_) {}

    try {
      // Fetching course data
      courseData = await CourseService.getSingleCourseData(id, isBundleCourse,
          isPrivate: isPrivate);

      if (!mounted) return;

      // Check if it's a bundle course and fetch the bundle courses
      if (courseData != null && isBundleCourse) {
        await getBundleCourses();
      }

      // Fetch regular content if it's not a bundle course
      if (!isBundleCourse) {
        await getContent();
      }

      // Show comment section if commentId is available
      if (commentId != null) {
        showComment();
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching course data: $e');
    }
  }

  Future<void> getContent() async {
    if (!mounted) return;
    
    try {
      contentData = await CourseService.getContent(courseData!.id!);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error fetching content: $e');
    }
  }

  Future<void> getBundleCourses() async {
    if (!mounted) return;
    
    try {
      bundleCourses = await CourseService.bundleCourses(courseData!.id!);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error fetching bundle courses: $e');
    }
  }

  void showComment() {
    if (!mounted) return;
    
    currentTab = 3;
    tabController.animateTo(3);

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      for (var i = 0; i < (courseData?.comments.length ?? 0); i++) {
        if (commentId == courseData?.comments[i].id) {
          scrollController.animateTo(
              (courseData!.comments[i].globalKey.findWidget ?? 0.0) > 230
                  ? (courseData!.comments[i].globalKey.findWidget ?? 0.0) - 230
                  : 0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.linearToEaseOut);
        }
      }

      commentId = null;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                appText.courseDetails,
                style: TextStyle(color: Colors.black),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                
                  IconButton(
                    icon: Icon(Icons.shopping_cart, color: Colors.black),
                    onPressed: () {
                      if (token.isEmpty) {
                        nextRoute(LoginPage.pageName);
                        showSnackBar(ErrorEnum.alert, appText.loginDesc);
                      } else
                        nextRoute(CartPage.pageName);
                    },
                  ),
                
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0), // Optional padding between icons

                    child: IconButton(
                      icon: Icon(Icons.qr_code_scanner,
                          color: Colors.black), // Scanner icon with black color
                      onPressed: () {
                        if (token.isEmpty) {
                          nextRoute(LoginPage.pageName);
                          showSnackBar(ErrorEnum.alert, appText.loginDesc);
                        } else
                          nextRoute(ScannerPage.pageName);
                      },
                    ),
                  ),
              ],
            ),
            body: isLoading
                // ? loading()
                ? singleCourseShimmer()
                : courseData == null
                    ? const SizedBox()
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: (token.isEmpty &&
                                    (PublicData.apiConfigData?[
                                                'webinar_private_content_status'] ??
                                            '0') ==
                                        '1')
                                ? SingleCourseWidget.privateContent()
                                : (token.isNotEmpty &&
                                        (PublicData.apiConfigData?[
                                                    'sequence_content_status'] ??
                                                '0') ==
                                            '1' &&
                                        locator<UserProvider>()
                                                .profile
                                                ?.accessContent ==
                                            0)
                                    ? SingleCourseWidget.pendingVerification()
                                    : NestedScrollView(
                                        controller: scrollController,
                                        physics: const BouncingScrollPhysics(),
                                        floatHeaderSlivers: false,
                                        headerSliverBuilder:
                                            (context, innerBoxIsScrolled) {
                                          return [
                                            // course video + title + teacher info
                                            SliverToBoxAdapter(
                                              child: Padding(
                                                padding: padding(),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (courseData
                                                            ?.activeSpecialOffer !=
                                                        null) ...{
                                                      SpecialOfferWidget(
                                                          courseData
                                                                  ?.activeSpecialOffer
                                                                  ?.toDate ??
                                                              0,
                                                          courseData
                                                                  ?.activeSpecialOffer
                                                                  ?.percent
                                                                  ?.toString() ??
                                                              '0'),
                                                    },

                                                    space(14),

                                                    // title
                                                    Text(
                                                      courseData?.title ?? '',
                                                      style: style16Bold(),
                                                    ),

                                                    space(8),

                                                    // rate
                                                    Row(
                                                      children: [
                                                        ratingBar(courseData
                                                                ?.rate
                                                                ?.toString() ??
                                                            '0'),
                                                        space(0, width: 4),
                                                        Container(
                                                          padding: padding(
                                                              horizontal: 6,
                                                              vertical: 3),
                                                          decoration: BoxDecoration(
                                                              color: greyE7,
                                                              borderRadius:
                                                                  borderRadius()),
                                                          child: Text(
                                                            courseData
                                                                    ?.reviewsCount
                                                                    ?.toString() ??
                                                                '',
                                                            style: style10Regular()
                                                                .copyWith(
                                                                    color:
                                                                        greyB2),
                                                          ),
                                                        )
                                                      ],
                                                    ),

                                                    space(18),

                                                    if (courseData?.videoDemo !=
                                                        null) ...{
                                                      if (courseData
                                                                  ?.videoDemoSource ==
                                                              'youtube' ||
                                                          courseData
                                                                  ?.videoDemoSource ==
                                                              'vimeo') ...{
                                                        PodVideoPlayerDev(
                                                            courseData
                                                                    ?.videoDemo ??
                                                                '',
                                                            courseData
                                                                    ?.videoDemoSource ??
                                                                '',
                                                            Constants
                                                                .singleCourseRouteObserver),
                                                      } else ...{
                                                        CourseVideoPlayer(
                                                            courseData
                                                                    ?.videoDemo ??
                                                                '',
                                                            courseData
                                                                    ?.imageCover ??
                                                                '',
                                                            Constants
                                                                .singleCourseRouteObserver)
                                                      }
                                                    } else ...{
                                                      ClipRRect(
                                                        borderRadius:
                                                            borderRadius(),
                                                        child: fadeInImage(
                                                            courseData?.image ??
                                                                '',
                                                            getSize().width,
                                                            210),
                                                      )
                                                    },

                                                    space(24),

                                                    // teacher profile
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        userProfile(
                                                            courseData!
                                                                .teacher!,
                                                            showRate: true),
                                                        closeButton(
                                                            AppAssets
                                                                .menuCircleSvg,
                                                            icColor: greyB2,
                                                            onTap: () {
                                                          SingleCourseWidget
                                                              .showOptionsDialog(
                                                                  courseData!,
                                                                  token,
                                                                  isBundle:
                                                                      isBundleCourse);
                                                        }),
                                                      ],
                                                    ),

                                                    if ((courseData
                                                                ?.authHasBought ==
                                                            false) &&
                                                        (courseData
                                                                ?.cashbackRules
                                                                .isNotEmpty ??
                                                            false)) ...{
                                                      space(16),
                                                      helperBox(
                                                          AppAssets.walletSvg,
                                                          appText.getCashback,
                                                          '${isBundleCourse ? appText.purchaseThisProductAndGet : appText.purchaseThisCourseAndGet}${courseData?.cashbackRules.first.amountType == 'percent' ? '%${courseData!.cashbackRules.first.amount ?? 0}' : CurrencyUtils.calculator(courseData!.cashbackRules.first.amount ?? 0)} ${appText.cashback}',
                                                          horizontalPadding: 0),
                                                    }
                                                  ],
                                                ),
                                              ),
                                            ),

                                            // tabs
                                            SliverAppBar(
                                              pinned: true,
                                              centerTitle: true,
                                              automaticallyImplyLeading: false,
                                              backgroundColor: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              shadowColor: Theme.of(context)
                                                  .scaffoldBackgroundColor
                                                  .withOpacity(.2),
                                              elevation: 10,
                                              titleSpacing: 0,
                                              title: tabBar(
                                                  onChangeTab, tabController, [
                                                Tab(
                                                  text: appText.information,
                                                  height: 32,
                                                ),
                                                Tab(
                                                  text: appText.content,
                                                  height: 32,
                                                ),
                                                Tab(
                                                  text: appText.reviews,
                                                  height: 32,
                                                ),
                                                Tab(
                                                  text: appText.comments,
                                                  height: 32,
                                                ),
                                              ]),
                                            ),
                                          ];
                                        },
                                        body: TabBarView(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            controller: tabController,
                                            children: [
                                              // information page
                                              SingleCourseWidget
                                                  .informationPage(
                                                      courseData!, viewMore,
                                                      () {
                                                setState(() {
                                                  viewMore = !viewMore;
                                                });
                                              }, () => setState(() {}),
                                                      bundleCourses:
                                                          bundleCourses),

                                              // content page
                                              SingleCourseWidget.contentPage(
                                                  courseData!, contentData,
                                                  bundleCourses: bundleCourses),

                                              // reviews page
                                              SingleCourseWidget.reviewsPage(
                                                courseData!,
                                              ),

                                              // comments page
                                              SingleCourseWidget.commentsPage(
                                                courseData!,
                                              ),
                                            ]),
                                      ),
                          ),
                          if ((token.isEmpty &&
                              (PublicData.apiConfigData?[
                                          'webinar_private_content_status'] ??
                                      '0') ==
                                  '1')) ...{
                            // login buttons
                            AnimatedPositioned(
                                duration: const Duration(milliseconds: 350),
                                bottom: 0,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 20, bottom: 30),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        boxShadow(Colors.black.withOpacity(.1),
                                            blur: 15, y: -3)
                                      ],
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(30))),
                                  child: button(
                                      onTap: () async {
                                        nextRoute(LoginPage.pageName,
                                            isClearBackRoutes: true);
                                      },
                                      width: MediaQuery.of(context).size.width,
                                      height: 52,
                                      text: appText.login,
                                      bgColor: green77(),
                                      textColor: Colors.white),
                                )),
                          } else ...{
                            // information buttons
                            AnimatedPositioned(
                                duration: const Duration(milliseconds: 350),
                                bottom: showInformationButton ? 0 : -150,
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 20,
                                        bottom: 30),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          boxShadow(
                                              Colors.black.withOpacity(.1),
                                              blur: 15,
                                              y: -3)
                                        ],
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(30))),
                                    child: Column(
                                      children: [
                                        // price or percent
                                        if ((courseData?.authHasBought ==
                                            false)) ...{
                                          if (token.isNotEmpty) ...{
                                            Row(
                                              children: [
                                                Text(
                                                  appText.price,
                                                  style: style14Regular()
                                                      .copyWith(color: greyA5),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  ((courseData?.price ?? 0) ==
                                                          0)
                                                      ? appText.free
                                                      : CurrencyUtils
                                                          .calculator(
                                                              courseData!
                                                                      .price ??
                                                                  0),
                                                  style:
                                                      style12Regular().copyWith(
                                                    color:
                                                        (courseData!.discountPercent ??
                                                                    0) >
                                                                0
                                                            ? greyCF
                                                            : green77(),
                                                    decoration: (courseData!
                                                                    .discountPercent ??
                                                                0) >
                                                            0
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : TextDecoration.none,
                                                    decorationColor:
                                                        (courseData!.discountPercent ??
                                                                    0) >
                                                                0
                                                            ? greyCF
                                                            : green77(),
                                                  ),
                                                ),
                                                if ((courseData!
                                                            .discountPercent ??
                                                        0) >
                                                    0) ...{
                                                  space(0, width: 8),
                                                  Text(
                                                    CurrencyUtils.calculator(
                                                        (courseData!.price ??
                                                                0) -
                                                            ((courseData!
                                                                        .price ??
                                                                    0) *
                                                                (courseData!
                                                                        .discountPercent ??
                                                                    0) ~/
                                                                100)),
                                                    style: style14Regular()
                                                        .copyWith(
                                                      color: green77(),
                                                    ),
                                                  ),
                                                },
                                              ],
                                            ),
                                            space(16),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: button(
                                                        onTap: () async {
                                                          if (((courseData
                                                                      ?.price ??
                                                                  0) ==
                                                              0)) {
                                                            setState(() {
                                                              isEnrollLoading =
                                                                  true;
                                                            });

                                                            bool res = isBundleCourse
                                                                ? await PurchaseService
                                                                    .bundlesFree(
                                                                        courseData!
                                                                            .id!)
                                                                : await PurchaseService
                                                                    .courseFree(
                                                                        courseData!
                                                                            .id!);

                                                            if (res) {
                                                              getData();
                                                            }

                                                            setState(() {
                                                              isEnrollLoading =
                                                                  false;
                                                            });

                                                            return;
                                                          }

                                                          if (courseData!
                                                                  .tickets
                                                                  .isNotEmpty ||
                                                              (courseData!.points !=
                                                                      null &&
                                                                  courseData!
                                                                          .points !=
                                                                      0)) {
                                                            SingleCourseWidget
                                                                    .pricingPlanDialog(
                                                                        courseData!)
                                                                .then((value) {
                                                              if (value !=
                                                                      null &&
                                                                  value) {
                                                                courseData =
                                                                    null;
                                                                getData();
                                                              }
                                                            });
                                                            return;
                                                          } else {
                                                            setState(() {
                                                              isEnrollLoading =
                                                                  true;
                                                            });
                                                            await CartService.add(
                                                                context,
                                                                courseData?.id
                                                                        ?.toString() ??
                                                                    '',
                                                                isBundleCourse
                                                                    ? 'bundle'
                                                                    : 'webinar',
                                                                '');

                                                            setState(() {
                                                              isEnrollLoading =
                                                                  false;
                                                              getData();
                                                            });
                                                          }
                                                        },
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 52,
                                                        text: appText
                                                            .enrollOnClass,
                                                        bgColor: green77(),
                                                        textColor: Colors.white,
                                                        isLoading:
                                                            isEnrollLoading)),
                                                if (courseData?.subscribe ??
                                                    false) ...{
                                                  space(0, width: 16),
                                                  Expanded(
                                                      child: button(
                                                          onTap: () async {
                                                            setState(() {
                                                              isSubscribeLoading =
                                                                  true;
                                                            });

                                                            bool res = await CartService
                                                                .subscribeApplay(
                                                                    context,
                                                                    courseData!
                                                                        .id!);

                                                            if (res) {
                                                              getData();
                                                            }

                                                            setState(() {
                                                              isSubscribeLoading =
                                                                  false;
                                                              getData();
                                                            });
                                                          },
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          height: 52,
                                                          text:
                                                              appText.subscribe,
                                                          bgColor:
                                                              Colors
                                                                  .transparent,
                                                          textColor: green77(),
                                                          borderColor:
                                                              green77(),
                                                          isLoading:
                                                              isSubscribeLoading,
                                                          loadingColor:
                                                              green77())),
                                                }
                                              ],
                                            )
                                          } else ...{
                                            button(
                                                onTap: () {
                                                  nextRoute(LoginPage.pageName,
                                                      isClearBackRoutes: true);
                                                },
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 53,
                                                text: appText.login,
                                                bgColor: green77(),
                                                textColor: Colors.white),
                                          }
                                        } else ...{
                                          // progress
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${courseData?.progressPercent ?? 0}% ${appText.completed}',
                                                style: style10Regular()
                                                    .copyWith(color: greyA5),
                                              ),
                                              space(6),
                                              LayoutBuilder(
                                                builder:
                                                    (context, constraints) {
                                                  return Container(
                                                    width: constraints.maxWidth,
                                                    height: 4,
                                                    alignment:
                                                        AlignmentDirectional
                                                            .centerStart,
                                                    child: Container(
                                                      width: ((courseData
                                                                      ?.progressPercent ??
                                                                  0) >
                                                              0)
                                                          ? constraints
                                                                  .maxWidth *
                                                              ((courseData?.progressPercent ??
                                                                      0) /
                                                                  100)
                                                          : 5,
                                                      height: 4,
                                                      decoration: BoxDecoration(
                                                        color: green77(),
                                                        borderRadius:
                                                            borderRadius(),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              space(12),
                                              button(
                                                  onTap: () {
                                                    if (courseData?.type ==
                                                        'bundle') {
                                                      tabController
                                                          .animateTo(1);
                                                    } else {
                                                      nextRoute(
                                                          LearningPage.pageName,
                                                          arguments:
                                                              courseData);
                                                    }
                                                  },
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 52,
                                                  text:
                                                      appText.goToLearningPage,
                                                  bgColor: green77(),
                                                  textColor: Colors.white,
                                                  raduis: 15)
                                            ],
                                          ),
                                        },
                                      ],
                                    ))),

                            if ((courseData?.authHasBought ?? false)) ...{
                              // write a review
                              AnimatedPositioned(
                                  duration: const Duration(milliseconds: 350),
                                  bottom: canSubmitReview ? 0 : -150,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 20,
                                        bottom: 30),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          boxShadow(
                                              Colors.black.withOpacity(.1),
                                              blur: 15,
                                              y: -3)
                                        ],
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(30))),
                                    child: button(
                                        onTap: () async {
                                          bool? res = await SingleCourseWidget
                                              .showSetReviewDialog(courseData!);

                                          if (res != null && res) {
                                            getData();
                                          }
                                        },
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 52,
                                        text: appText.writeReview,
                                        bgColor: green77(),
                                        textColor: Colors.white),
                                  )),
                            },
                            FloatingDeviceInfoWidget(),

                            AnimatedPositioned(
                                duration: const Duration(milliseconds: 350),
                                bottom: canSubmitComment ? 0 : -150,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 20, bottom: 30),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        boxShadow(Colors.black.withOpacity(.1),
                                            blur: 15, y: -3)
                                      ],
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(30))),
                                  child: button(
                                      onTap: () async {
                                        bool? res =
                                            await BlogWidget.showReplayDialog(
                                                courseData!.id!, null,
                                                itemName: isBundleCourse
                                                    ? 'bundle'
                                                    : 'webinar');

                                        if (res != null && res) {
                                          getData();
                                        }
                                      },
                                      width: MediaQuery.of(context).size.width,
                                      height: 52,
                                      text: appText.leaveAComment,
                                      bgColor: green77(),
                                      textColor: Colors.white),
                                )),
                          }
                        ],
                      )));
  }

  @override
  void dispose() {
    scrollController.dispose();
    tabController.dispose();
    super.dispose();
  }
}

extension GlobalKeyExtension on GlobalKey {
  double? get findWidget {
    // final renderObject = currentContext?.findRenderObject();
    // final translation = renderObject?.getTransformTo(null).getTranslation();
    // if (translation != null && renderObject?.paintBounds != null) {
    //   final offset = Offset(translation.x, translation.y);
    //   return renderObject!.paintBounds.shift(offset);
    // } else {
    //   return null;
    // }

    RenderBox box = currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero); //this is global position
    double y = position.dy;
    return y;
  }
}
