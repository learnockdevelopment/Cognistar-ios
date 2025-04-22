// import 'package:flutter/material.dart';
// import 'package:flutter_iconly/flutter_iconly.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';
// import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
// import 'package:webinar/app/providers/app_language_provider.dart';
// import 'package:webinar/app/providers/drawer_provider.dart';
// import 'package:webinar/app/services/guest_service/categories_service.dart';
// import 'package:webinar/common/common.dart';
// import 'package:webinar/common/data/app_language.dart';
// import 'package:webinar/common/shimmer_component.dart';
// import 'package:webinar/common/utils/app_text.dart';
// import 'package:webinar/config/assets.dart';
// import 'package:webinar/config/colors.dart';
// import 'package:webinar/config/styles.dart';
// import 'package:webinar/locator.dart';
//
// import '../../../../common/utils/object_instance.dart';
// import '../../../models/category_model.dart';
// import '../../../../common/components.dart';
//
// class CategoriesPage extends StatefulWidget {
//   const CategoriesPage({super.key});
//
//   @override
//   State<CategoriesPage> createState() => _CategoriesPageState();
// }
//
// class _CategoriesPageState extends State<CategoriesPage> {
//   bool isLoading = true;
//   List<CategoryModel> trendCategories = [];
//   List<CategoryModel> categories = [];
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.wait([getCategoriesData(), getTrendCategoriessData()]).then((value) {
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }
//
//   Future getCategoriesData() async {
//     categories = await CategoriesService.categories();
//   }
//
//   Future getTrendCategoriessData() async {
//     trendCategories = await CategoriesService.trendCategories();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AppLanguageProvider>(
//         builder: (context, appLanguageProvider, _) {
//       return directionality(child:
//           Consumer<DrawerProvider>(builder: (context, drawerProvider, _) {
//         return ClipRRect(
//           borderRadius:
//               borderRadius(radius: drawerProvider.isOpenDrawer ? 20 : 0),
//           child: Scaffold(
//             backgroundColor: backgroundColor,
//             appBar: appbar(
//               title: appText.categories,
//               leftIcon: null,
//               onTapLeftIcon: () {},
//             ),
//             body: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   space(15),
//
//                   Padding(
//                     padding: padding(),
//                     child: Text(
//                       appText.trending,
//                       style: style16Regular(),
//                     ),
//                   ),
//
//                   space(14),
//
//                   // trend categories
//                   SizedBox(
//                     width: getSize().width,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       physics: const BouncingScrollPhysics(),
//                       padding: padding(),
//                       child: Row(
//                         children: List.generate(
//                             isLoading ? 3 : trendCategories.length, (index) {
//                           return isLoading
//                               ? horizontalCategoryItemShimmer()
//                               : horizontalCategoryItem(
//                                   trendCategories[index].color ?? green77(),
//                                   trendCategories[index].icon ?? '',
//                                   trendCategories[index].title ?? '',
//                                   trendCategories[index]
//                                           .webinarsCount
//                                           ?.toString() ??
//                                       '0', () {
//                                   nextRoute(FilterCategoryPage.pageName,
//                                       arguments: trendCategories[index]);
//                                 });
//                         }),
//                       ),
//                     ),
//                   ),
//
//                   space(30),
//
//                   Padding(
//                     padding: padding(),
//                     child: Text(
//                       appText.browseCategories,
//                       style: style16Regular().copyWith(color: grey3A),
//                     ),
//                   ),
//
//                   space(14),
//
//                   // categories
//                   Container(
//                     width: getSize().width,
//                     margin: padding(),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: borderRadius(),
//                     ),
//                     child: Column(
//                       children: [
//                         ...List.generate(isLoading ? 8 : categories.length,
//                             (index) {
//                           return isLoading
//                               ? categoryItemShimmer()
//                               : Container(
//                                   width: getSize().width,
//                                   padding: padding(),
//                                   child: Column(
//                                     children: [
//                                       space(16),
//
//                                       // category
//                                       GestureDetector(
//                                         onTap: () {
//                                           if ((categories[index]
//                                                   .subCategories
//                                                   ?.isEmpty ??
//                                               false)) {
//                                             nextRoute(
//                                                 FilterCategoryPage.pageName,
//                                                 arguments: categories[index]);
//                                           } else {
//                                             setState(() {
//                                               categories[index].isOpen =
//                                                   !categories[index].isOpen;
//                                             });
//                                           }
//                                         },
//                                         behavior: HitTestBehavior.opaque,
//                                         child: Row(
//                                           children: [
//                                             if (categories[index].icon !=
//                                                 null) ...{
//                                               Container(
//                                                 width: 34,
//                                                 height: 34,
//                                                 decoration: BoxDecoration(
//                                                   color: greyF8,
//                                                   shape: BoxShape.circle,
//                                                 ),
//                                                 alignment: Alignment.center,
//                                                 child: Image.network(
//                                                   categories[index].icon ?? '',
//                                                   width: 22,
//                                                 ),
//                                               ),
//                                             } else ...{
//                                               Container(
//                                                 width: 34,
//                                                 height: 34,
//                                                 decoration: BoxDecoration(
//                                                   color: greyF8,
//                                                   shape: BoxShape.circle,
//                                                 ),
//                                                 alignment: Alignment.center,
//                                                 child: const Icon(
//                                                     IconlyLight.image),
//                                               ),
//                                             },
//                                             space(0, width: 10),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Text(
//                                                   categories[index].title ?? '',
//                                                   style: style14Bold(),
//                                                 ),
//                                                 Text(
//                                                   '${categories[index].webinarsCount} ${appText.courses}',
//                                                   style: style12Regular()
//                                                       .copyWith(color: greyA5),
//                                                 ),
//                                               ],
//                                             ),
//                                             const Spacer(),
//                                             if (categories[index]
//                                                     .subCategories
//                                                     ?.isNotEmpty ??
//                                                 false) ...{
//                                               AnimatedRotation(
//                                                 turns: categories[index].isOpen
//                                                     ? 90 / 360
//                                                     : locator<AppLanguage>()
//                                                             .isRtl()
//                                                         ? 180 / 360
//                                                         : 0,
//                                                 duration: const Duration(
//                                                     milliseconds: 200),
//                                                 child: SvgPicture.asset(
//                                                     AppAssets.arrowRightSvg),
//                                               )
//                                             }
//                                           ],
//                                         ),
//                                       ),
//
//                                       // subCategories
//                                       AnimatedCrossFade(
//                                           firstChild: Stack(
//                                             children: [
//                                               // vertical dash
//                                               PositionedDirectional(
//                                                 start: 15,
//                                                 top: 0,
//                                                 bottom: 35,
//                                                 child: CustomPaint(
//                                                   size: const Size(
//                                                       .5, double.infinity),
//                                                   painter:
//                                                       DashedLineVerticalPainter(),
//                                                   child: const SizedBox(),
//                                                 ),
//                                               ),
//
//                                               // sub category
//                                               SizedBox(
//                                                 child: Column(
//                                                   children: List.generate(
//                                                       categories[index]
//                                                               .subCategories
//                                                               ?.length ??
//                                                           0, (i) {
//                                                     return GestureDetector(
//                                                       onTap: () {
//                                                         nextRoute(
//                                                             FilterCategoryPage
//                                                                 .pageName,
//                                                             arguments: categories[
//                                                                     index]
//                                                                 .subCategories![i]);
//                                                       },
//                                                       behavior: HitTestBehavior
//                                                           .opaque,
//                                                       child: Column(
//                                                         children: [
//                                                           space(15),
//
//                                                           // sub categories item
//                                                           Padding(
//                                                             padding: padding(
//                                                                 horizontal: 10),
//                                                             child: Row(
//                                                               children: [
//                                                                 // circle
//                                                                 Container(
//                                                                   width: 10,
//                                                                   height: 10,
//                                                                   decoration: BoxDecoration(
//                                                                       color: Colors
//                                                                           .white,
//                                                                       border: Border.all(
//                                                                           color:
//                                                                               greyE7,
//                                                                           width:
//                                                                               1),
//                                                                       shape: BoxShape
//                                                                           .circle),
//                                                                 ),
//
//                                                                 space(0,
//                                                                     width: 22),
//
//                                                                 // sub category details
//                                                                 Column(
//                                                                   crossAxisAlignment:
//                                                                       CrossAxisAlignment
//                                                                           .start,
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .center,
//                                                                   children: [
//                                                                     Text(
//                                                                       categories[index]
//                                                                               .subCategories?[i]
//                                                                               .title ??
//                                                                           '',
//                                                                       style:
//                                                                           style14Bold(),
//                                                                       maxLines:
//                                                                           1,
//                                                                     ),
//                                                                     Text(
//                                                                       categories[index].subCategories?[i].webinarsCount ==
//                                                                               0
//                                                                           ? appText
//                                                                               .noCourse
//                                                                           : '${categories[index].subCategories?[i].webinarsCount} ${appText.courses}',
//                                                                       style: style12Regular().copyWith(
//                                                                           color:
//                                                                               greyA5),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//
//                                                           space(15),
//                                                         ],
//                                                       ),
//                                                     );
//                                                   }),
//                                                 ),
//                                               )
//                                             ],
//                                           ),
//                                           secondChild: SizedBox(
//                                             width: getSize().width,
//                                           ),
//                                           crossFadeState:
//                                               categories[index].isOpen
//                                                   ? CrossFadeState.showFirst
//                                                   : CrossFadeState.showSecond,
//                                           duration: const Duration(
//                                               milliseconds: 300)),
//
//                                       space(15),
//
//                                       Container(
//                                         width: getSize().width,
//                                         height: 1,
//                                         decoration:
//                                             BoxDecoration(color: greyF8),
//                                       )
//                                     ],
//                                   ),
//                                 );
//                         })
//                       ],
//                     ),
//                   ),
//
//                   space(120),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }));
//     });
//   }
// }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//



import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
import 'package:webinar/app/providers/app_language_provider.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/services/guest_service/categories_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/common/shimmer_component.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import 'package:webinar/locator.dart';

import '../../../../common/utils/object_instance.dart';
import '../../../models/category_model.dart';
import '../../../../common/components.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  bool isLoading = true;
  List<CategoryModel> trendCategories = [];
  List<CategoryModel> categories = [];

  @override
  void initState() {
    super.initState();

    Future.wait([getCategoriesData(), getTrendCategoriessData()]).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future getCategoriesData() async {
    categories = await CategoriesService.categories();
  }

  Future getTrendCategoriessData() async {
    trendCategories = await CategoriesService.trendCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(
              title: appText.categories,
              leftIcon: null,
              onTapLeftIcon: () {},
            ),
      body: CustomScrollView(
        slivers: [
          // Trending Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appText.trending,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: isLoading ? 3 : trendCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        if (isLoading) return const TrendCategoryShimmer();
                        return TrendCategoryCard(
                            category: trendCategories[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // All Categories
          SliverPadding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 60), // Changed from left: 24
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (isLoading) return const CategoryShimmer();
                  return CategoryExpansionTile(category: categories[index]);
                },
                childCount: isLoading ? 8 : categories.length,
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class TrendCategoryCard extends StatelessWidget {
  final CategoryModel category;

  const TrendCategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        // onTap: () => navigateToFilter(category),
        onTap: () => {
          nextRoute(FilterCategoryPage.pageName, arguments: category)
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: CachedNetworkImageProvider(category.icon ?? ''),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(category.title ?? '',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    )),
                Text(
                  '${category.webinarsCount} ${appText.courses}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryExpansionTile extends StatelessWidget {
  final CategoryModel category;

  const CategoryExpansionTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category.color?.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(IconlyLight.category,
                  color: category.color ?? Theme.of(context).primaryColor),
            ),
          ),
          title: Text(category.title ?? '',
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            '${category.webinarsCount} ${appText.courses}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: category.subCategories?.isEmpty ?? true
              ? null
              : Icon(
            category.isOpen
                ? Icons.expand_less_rounded
                : Icons.expand_more_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onExpansionChanged: (open) {
            // Handle expansion state
          },
          children: [
            if (category.subCategories?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 16, bottom: 16),
                child: Column(
                  children: category.subCategories!
                      .map((sub) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(sub.title ?? '',
                        style: Theme.of(context).textTheme.bodyMedium),
                    subtitle: Text(
                      sub.webinarsCount == 0
                          ? appText.noCourse
                          : '${sub.webinarsCount} ${appText.courses}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => {nextRoute(FilterCategoryPage.pageName, arguments: sub)},

                  ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TrendCategoryShimmer extends StatelessWidget {
  const TrendCategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
      ),
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.grey[200]),
        title: Container(
          height: 16,
          width: 100,
          color: Colors.grey[200],
        ),
        subtitle: Container(
          height: 12,
          width: 60,
          color: Colors.grey[200],
        ),
      ),
    );
  }
}



class DashedLineVerticalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 6, dashSpace = 5, startY = 0;
    final paint = Paint()
      ..color = Colors.grey.withOpacity(.5)
      ..strokeWidth = .4;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
