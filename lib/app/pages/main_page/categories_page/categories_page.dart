import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
import 'package:webinar/app/services/guest_service/categories_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import '../../../../common/components.dart';
import '../../../../config/assets.dart';
import '../../../models/category_model.dart';
import '../../../widgets/main_widget/main_drawer.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  static const String pageName = '/categories';

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<CategoryModel> trendCategories = [];
  List<CategoryModel> categories = [];
  List<CategoryModel> filteredCategories = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isDisposed = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted || _isDisposed) return;

    try {
      final results = await Future.wait([
        getCategoriesData(),
        getTrendCategoriessData(),
      ]);

      if (!mounted || _isDisposed) return;

      setState(() {
        isLoading = false;
        filteredCategories = categories;
      });
    } catch (e) {
      if (!mounted || _isDisposed) return;

      setState(() {
        isLoading = false;
        filteredCategories = categories;
      });
    }
  }

  Future<void> getCategoriesData() async {
    if (!mounted) return;
    categories = await CategoriesService.categories();
  }

  Future<void> getTrendCategoriessData() async {
    if (!mounted) return;
    trendCategories = await CategoriesService.trendCategories();
  }

  void _filterCategories(String query) {
    if (!mounted || _isDisposed) return;

    setState(() {
      if (query.isEmpty) {
        filteredCategories = categories;
      } else {
        final searchTerms = query.toLowerCase().split(' ');
        filteredCategories = categories.where((category) {
          final title = category.title?.toLowerCase() ?? '';

          // Check if all search terms are found in either title or description
          return searchTerms.every((term) => title.contains(term)
          );
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MainDrawer(
        scaffoldKey: _scaffoldKey,
      ),
      backgroundColor: backgroundColor,
      appBar: appbar(
        title: appText.categories,
        leftIcon: AppAssets.menuSvg,
        onTapLeftIcon: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        rightIcon: AppAssets.filterSvg,
        rightWidth: 22
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    blueFE.withOpacity(0.15),
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        boxShadow(Colors.black.withOpacity(.05), blur: 10, y: 5),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterCategories,
                      decoration: InputDecoration(
                        hintText: 'Search categories...',
                        hintStyle: style14Regular().copyWith(color: greyA5),
                        prefixIcon: Icon(IconlyLight.search, color: greyA5),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty) ...[
                    space(16),
                    Text(
                      'Found ${filteredCategories.length} categories',
                      style: style14Regular().copyWith(color: greyA5),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Add extra spacing between header and cards
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20, // Increased spacing between cards
                crossAxisSpacing: 20, // Increased spacing between cards
                childAspectRatio: 1.1, // Slightly taller cards
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (isLoading) return const CategoryShimmer();
                  if (filteredCategories.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: blueFE.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                IconlyLight.search,
                                size: 48,
                                color: blueFE,
                              ),
                            ),
                            space(24),
                            Text(
                              'No categories found',
                              style: style16Bold().copyWith(color: grey33),
                            ),
                            space(12),
                            Text(
                              'Try different keywords',
                              style: style14Regular().copyWith(color: greyA5),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final category = filteredCategories[index];
                  return ModernCategoryCard(category: category);
                },
                childCount: isLoading ? 6 : (filteredCategories.isEmpty ? 1 : filteredCategories.length),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class ModernCategoryCard extends StatelessWidget {
  final CategoryModel category;

  const ModernCategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'category_${category.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => nextRoute(FilterCategoryPage.pageName, arguments: category),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                boxShadow(Colors.black.withOpacity(.08), blur: 15, y: 8),
              ],
            ),
            child: Stack(
              children: [
                // Background Pattern
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CustomPaint(
                      painter: CategoryPatternPainter(
                        color: category.color?.withOpacity(0.12) ?? blueFE.withOpacity(0.12),
                      ),
                    ),
                  ),
                ),
                // Content
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: category.color?.withOpacity(0.15) ?? blueFE.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            IconlyLight.category,
                            color: category.color ?? blueFE,
                            size: 28,
                          ),
                        ),
                        space(16),
                        Flexible(
                          child: Text(
                            category.title ?? '',
                            style: style16Bold().copyWith(
                              color: grey33,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        space(16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: category.color?.withOpacity(0.15) ?? blueFE.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Details',
                                style: style12Regular().copyWith(
                                  color: category.color ?? blueFE,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              space(4),
                              Icon(
                                IconlyLight.arrowRight,
                                size: 14,
                                color: category.color ?? blueFE,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class CategoryPatternPainter extends CustomPainter {
  final Color color;

  CategoryPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.5,
      size.width,
      size.height * 0.7,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          boxShadow(Colors.black.withOpacity(.05), blur: 10, y: 5),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
            ),
            space(16),
            Container(
              height: 16,
              width: double.infinity,
              color: Colors.grey[200],
            ),
            space(8),
            Container(
              height: 12,
              width: 80,
              color: Colors.grey[200],
            ),
          ],
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

