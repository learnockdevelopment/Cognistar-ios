import 'package:flutter/material.dart';
import 'package:webinar/app/models/category_model.dart';
import 'package:webinar/app/models/course_model.dart';
import 'package:webinar/app/models/filter_model.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/dynamiclly_filter.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/options_filter.dart';
import 'package:webinar/app/providers/filter_course_provider.dart';
import 'package:webinar/app/services/guest_service/categories_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/shimmer_component.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/tablet_detector.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/locator.dart';

import '../../../../services/guest_service/course_service.dart';
import '../../../../../common/components.dart';
import '../../../../widgets/main_widget/home_widget/home_widget.dart';

class FilterCategoryPage extends StatefulWidget {
  static const String pageName = '/filter-caregory';
  const FilterCategoryPage({super.key});

  @override
  State<FilterCategoryPage> createState() => _FilterCategoryPageState();
}

class _FilterCategoryPageState extends State<FilterCategoryPage> {
  bool isLoading = false;
  bool isGrid = true;

  CategoryModel? category;

  List<CourseModel> data = [];
  List<CourseModel> featuredListData = [];
  List<FilterModel> filters = [];

  ScrollController scrollController = ScrollController();

  PageController sliderPageController = PageController();
  int currentSliderIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      
      category = (ModalRoute.of(context)!.settings.arguments as CategoryModel?);
      _initializeData();
    });

    scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!mounted) return;
    
    var min = scrollController.position.pixels;
    var max = scrollController.position.maxScrollExtent;

    if ((max - min) < 300) {
      if (!isLoading) {
        getData();
      }
    }
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    
    await Future.wait([
      getData(),
      getFilters(),
      getFeatured(),
    ]);
  }

  Future<void> getData() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final newData = await CourseService.getAll(
        offset: data.length,
        cat: category?.id?.toString(),
        filterOption: locator<FilterCourseProvider>().filterSelected,
        upcoming: locator<FilterCourseProvider>().upcoming,
        free: locator<FilterCourseProvider>().free,
        discount: locator<FilterCourseProvider>().discount,
        downloadable: locator<FilterCourseProvider>().downloadable,
        sort: locator<FilterCourseProvider>().sort,
        bundle: locator<FilterCourseProvider>().bundleCourse,
        reward: locator<FilterCourseProvider>().rewardCourse
      );

      if (!mounted) return;
      
      setState(() {
        data.addAll(newData);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
      });
      // Handle error if needed
    }
  }

  Future<void> getFilters() async {
    if (!mounted || category == null) return;
    
    try {
      filters = await CategoriesService.getFilters(category!.id!);
      locator<FilterCourseProvider>().filters = filters;

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> getFeatured() async {
    if (!mounted || category == null) return;
    
    try {
      final featured = await CourseService.featuredCourse(cat: category!.id!.toString());
      
      if (!mounted) return;
      
      setState(() {
        featuredListData = featured;
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
        child: Scaffold(
      backgroundColor: backgroundColor,
      appBar: appbar(
        title: category?.title ?? appText.courses,
        // leftIcon: AppAssets.backSvg,
        // onTapLeftIcon: () {
        //   backRoute();
        // },
        // isBasket: true
      ),
      body: Column(
        children: [
          space(20),

          // filters
          Padding(
            padding: padding(),
            child: Row(
              children: [
                // options
                Expanded(
                  child: button(
                      onTap: () async {
                        var res =
                            await baseBottomSheet(child: const OptionsFilter());

                        if (res != null && res) {
                          data.clear();
                          getData();
                        }
                      },
                      width: getSize().width,
                      height: 48,
                      text: appText.options,
                      bgColor: Colors.transparent,
                      textColor: green77(),
                      borderColor: green77(),
                      iconPath: AppAssets.optionSvg,
                      raduis: 15),
                ),

                space(0, width: 18),

                // filters
                Expanded(
                  child: button(
                      onTap: () async {
                        if (filters.isNotEmpty) {
                          var res = await baseBottomSheet(
                              child: const DynamicllyFilter());

                          if (res != null && res) {
                            data.clear();
                            getData();
                          }
                        }
                      },
                      width: getSize().width,
                      height: 48,
                      text: appText.filters,
                      bgColor: Colors.transparent,
                      textColor: filters.isEmpty
                          ? green77().withOpacity(.35)
                          : green77(),
                      borderColor: filters.isEmpty
                          ? green77().withOpacity(.35)
                          : green77(),
                      iconColor: filters.isEmpty
                          ? green77().withOpacity(.35)
                          : green77(),
                      iconPath: AppAssets.filterSvg,
                      raduis: 15),
                ),

                space(0, width: 18),

                button(
                    onTap: () {
                      setState(() {
                        isGrid = !isGrid;
                      });
                    },
                    width: 60,
                    height: 48,
                    text: '',
                    bgColor: Colors.transparent,
                    textColor: Colors.white,
                    borderColor: green77(),
                    iconPath: AppAssets.listSvg,
                    //isGrid ? AppAssets.gridSvg :
                    raduis: 15)
              ],
            ),
          ),

          space(8),

          // List

          Expanded(
              child: data.isEmpty && featuredListData.isEmpty && !isLoading
                  ? emptyState(AppAssets.filterEmptyStateSvg,
                      appText.dataNotFound, appText.dataNotFoundDesc)
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (featuredListData.isNotEmpty) ...{
                            // Featured Classes
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HomeWidget.titleAndMore(appText.featuredClasses,
                                    isViewAll: false),

                                SizedBox(
                                  width: getSize().width,
                                  height: 215,
                                  child: PageView(
                                    controller: sliderPageController,
                                    onPageChanged: (value) async {
                                      await Future.delayed(
                                          const Duration(milliseconds: 500));

                                      setState(() {
                                        currentSliderIndex = value;
                                      });
                                    },
                                    physics: const BouncingScrollPhysics(),
                                    children: List.generate(
                                        featuredListData.length, (index) {
                                      return courseSliderItem(
                                          featuredListData[index]);
                                    }),
                                  ),
                                ),

                                space(18),

                                // indecator
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ...List.generate(featuredListData.length,
                                        (index) {
                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: currentSliderIndex == index
                                            ? 16
                                            : 7,
                                        height: 7,
                                        margin: padding(horizontal: 2),
                                        decoration: BoxDecoration(
                                            color: green77(),
                                            borderRadius: borderRadius()),
                                      );
                                    }),
                                  ],
                                ),

                                space(14),
                              ],
                            ),
                          },

                          space(14),

                          // list data
                          SizedBox(
                            width: getSize().width,
                            child:
                                isGrid
                                    ? GridView(
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20, bottom: 40),
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    TabletDetector.isTablet()
                                                        ? 3
                                                        : 2,
                                                mainAxisExtent: 260,
                                                crossAxisSpacing: 2,
                                                mainAxisSpacing: 8),
                                        children: List.generate(
                                            (isLoading && data.isEmpty)
                                                ? 8
                                                : data.length, (index) {
                                          return (isLoading && data.isEmpty)
                                              ? courseItemShimmer()
                                              : courseItem(data[index],
                                                  isSmallSize: true);
                                        }),
                                      )
                                    :
                                ListView(
                              shrinkWrap: true,
                              padding: padding(),
                              physics: const NeverScrollableScrollPhysics(),
                              children: List.generate(
                                  (isLoading && data.isEmpty) ? 8 : data.length,
                                  (index) {
                                return (isLoading && data.isEmpty)
                                    ? courseItemVerticallyShimmer()
                                    : courseItemVertically(data[index],
                                        isShowReward:
                                            locator<FilterCourseProvider>()
                                                .rewardCourse);
                              }),
                            ),
                          ),
                        ],
                      ),
                    ))
        ],
      ),
    ));
  }

  @override
  void dispose() {
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    sliderPageController.dispose();
    locator<FilterCourseProvider>().clearFilter();
    super.dispose();
  }
}
