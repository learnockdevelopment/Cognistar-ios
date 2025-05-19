import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/models/blog_model.dart';
import 'package:webinar/app/pages/main_page/blog_page/details_blog_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/app/widgets/main_widget/blog_widget/blog_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/shimmer_component.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/object_instance.dart';
import 'package:webinar/config/assets.dart';

import '../../../../config/colors.dart';
import '../../../models/basic_model.dart';
import '../../../services/user_service/blog_service.dart';
import '../../../widgets/main_widget/main_drawer.dart';

class BlogsPage extends StatefulWidget {
  const BlogsPage({super.key});

  @override
  State<BlogsPage> createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage> {
  List<BlogModel> blogData = [];
  bool isLoading = true;

  bool canStoreComment = false;

  ScrollController scrollController = ScrollController();

  List<BasicModel> categories = [];
  BasicModel? selectedCategory;

  @override
  void initState() {
    super.initState();
    getData();
    getCategories();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!mounted) return;
    var max = scrollController.position.maxScrollExtent;
    var min = scrollController.position.pixels;
    if (max - min < 200 && !isLoading) {
      getData();
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  getCategories() async {
    if (!mounted) return;
    categories = await BlogService.categories();
    if (mounted) {
      setState(() {});
    }
  }

  getData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    final newBlogs = await BlogService.getBlog(blogData.length,
        category: selectedCategory?.id);

    if (mounted) {
      setState(() {
        blogData.addAll(newBlogs);
        isLoading = false;
      });
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return directionality(
        child: Consumer<DrawerProvider>(builder: (context, drawerProvider, _) {
      return ClipRRect(
        borderRadius:
            borderRadius(radius: drawerProvider.isOpenDrawer ? 20 : 0),
        child: Scaffold(
          key: _scaffoldKey,
          drawer: MainDrawer(
            scaffoldKey: _scaffoldKey,
          ),
          backgroundColor: backgroundColor,
          appBar: appbar(
              title: appText.blog,
              leftIcon: AppAssets.menuSvg,
              onTapLeftIcon: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              rightIcon: AppAssets.filterSvg,
              onTapRightIcon: () async {
                BasicModel? cat = await BlogWidget.showCategoriesDialog(
                    selectedCategory, categories);

                if (cat != null) {
                  if (cat.id != selectedCategory?.id) {
                    selectedCategory = cat;
                    blogData.clear();
                    getData();
                  }
                }
              },
              rightWidth: 22),
          body: !isLoading && blogData.isEmpty
              ? Center(
                  child: emptyState(AppAssets.blogEmptyStateSvg,
                      appText.noBlogPosts, appText.noBlogPostsDesc))
              : SingleChildScrollView(
                  controller: scrollController,
                  padding: padding(vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      ...List.generate(
                          (isLoading && blogData.isEmpty) ? 3 : blogData.length,
                          (index) {
                        return (isLoading && blogData.isEmpty)
                            ? blogItemShimmer()
                            : blogItem(blogData[index], () {
                                nextRoute(DetailsBlogPage.pageName,
                                    arguments: blogData[index]);
                              });
                      }),
                      space(100),
                    ],
                  ),
                ),
        ),
      );
    }));
  }
}
