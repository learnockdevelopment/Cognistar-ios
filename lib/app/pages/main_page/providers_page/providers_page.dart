import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/providers_page/providers_filter.dart';
import 'package:webinar/app/pages/main_page/providers_page/user_profile_page/user_profile_page.dart';
import 'package:webinar/app/providers/app_language_provider.dart';
import 'package:webinar/app/services/guest_service/providers_service.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/shimmer_component.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/locator.dart';

import '../../../../common/utils/object_instance.dart';
import '../../../../common/utils/tablet_detector.dart';
import '../../../../config/colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/providers_provider.dart';
import '../../../widgets/main_widget/main_drawer.dart';

class ProvidersPage extends StatefulWidget {
  const ProvidersPage({super.key});

  @override
  State<ProvidersPage> createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<ProvidersPage> with SingleTickerProviderStateMixin {
  late TabController tabController;
  int currentTab = 1;
  bool _isDisposed = false;

  List<UserModel> instructorsData = [];
  List<UserModel> organizationsData = [];
  List<UserModel> consultantsData = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    locator<ProvidersProvider>().clearFilter();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted || _isDisposed) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      await Future.wait([
        getInstructors(),
        getOrganizations(),
        getConsultants(),
      ]);
    } catch (e) {
      // Handle error if needed
    }

    if (!mounted || _isDisposed) return;
    
    setState(() {
      isLoading = false;
    });
  }

  void onChangeTab(int i) {
    if (!mounted || _isDisposed) return;
    setState(() {
      currentTab = i;
    });
  }

  Future<void> getInstructors() async {
    if (!mounted || _isDisposed) return;

    try {
      final data = await ProvidersService.getInstructors(
        availableForMeetings: locator<ProvidersProvider>().availableForMeeting,
        freeMeetings: locator<ProvidersProvider>().free,
        discount: locator<ProvidersProvider>().discount,
        downloadable: locator<ProvidersProvider>().downloadable,
        sort: locator<ProvidersProvider>().sort,
        categories: locator<ProvidersProvider>().categorySelected
      );

      if (!mounted || _isDisposed) return;

      setState(() {
        instructorsData = data;
      });
    } catch (e) {
      // Handle error if needed
    }
  }
  
  Future<void> getOrganizations() async {
    if (!mounted || _isDisposed) return;

    try {
      final data = await ProvidersService.getOrganizations(
        availableForMeetings: locator<ProvidersProvider>().availableForMeeting,
        freeMeetings: locator<ProvidersProvider>().free,
        discount: locator<ProvidersProvider>().discount,
        downloadable: locator<ProvidersProvider>().downloadable,
        sort: locator<ProvidersProvider>().sort,
        categories: locator<ProvidersProvider>().categorySelected
      );

      if (!mounted || _isDisposed) return;

      setState(() {
        organizationsData = data;
      });
    } catch (e) {
      // Handle error if needed
    }
  }
  
  Future<void> getConsultants() async {
    if (!mounted || _isDisposed) return;

    try {
      final data = await ProvidersService.getConsultations(
        availableForMeetings: locator<ProvidersProvider>().availableForMeeting,
        freeMeetings: locator<ProvidersProvider>().free,
        discount: locator<ProvidersProvider>().discount,
        downloadable: locator<ProvidersProvider>().downloadable,
        sort: locator<ProvidersProvider>().sort,
        categories: locator<ProvidersProvider>().categorySelected
      );

      if (!mounted || _isDisposed) return;

      setState(() {
        consultantsData = data;
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    tabController.dispose();
    super.dispose();
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguageProvider>(
      builder: (context, appLanguageProvider, _) {
        return directionality(
          child: Scaffold(   key: _scaffoldKey,
              drawer: MainDrawer(
                scaffoldKey: _scaffoldKey,
              ),
            backgroundColor: backgroundColor,
              appBar: appbar(
                  title: appText.providers,
                  leftIcon: AppAssets.menuSvg,
                  onTapLeftIcon: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },

              ),

            body: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: NestedScrollView(
                physics: const BouncingScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      pinned: true,
                      centerTitle: true,
                      automaticallyImplyLeading: false,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      shadowColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(.2),
                      elevation: 10,
                      titleSpacing: 0,
                      title: tabBar(
                        onChangeTab,
                        tabController,
                        [
                          Tab(
                            text: appText.instrcutors,
                            height: 32,
                          ),
                          Tab(
                            text: appText.organizations,
                            height: 32,
                          ),
                          Tab(
                            text: appText.consultants,
                            height: 32,
                          ),
                        ]
                      ),
                    )
                  ];
                },
                body: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    controller: tabController,
                    children: [
                      _buildTabContent(
                        isLoading,
                        instructorsData,
                        appText.noInstructor,
                        appText.noInstructorDesc,
                        (index) => nextRoute(UserProfilePage.pageName, arguments: instructorsData[index].id),
                      ),
                      _buildTabContent(
                        isLoading,
                        organizationsData,
                        appText.noOrganization,
                        appText.noOrganizationDesc,
                        (index) => nextRoute(UserProfilePage.pageName, arguments: organizationsData[index].id),
                      ),
                      _buildTabContent(
                        isLoading,
                        consultantsData,
                        appText.noConsultants,
                        appText.noConsultantsDesc,
                        (index) => nextRoute(UserProfilePage.pageName, arguments: consultantsData[index].id),
                      ),
                    ]
                  ),
                )
              ),
            )
          ),
        );
      }
    );
  }

  Widget _buildTabContent(
    bool isLoading,
    List<UserModel> data,
    String emptyTitle,
    String emptyDesc,
    Function(int) onItemTap,
  ) {
    if (!isLoading && data.isEmpty) {
      return emptyState(AppAssets.providersEmptyStateSvg, emptyTitle, emptyDesc);
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: TabletDetector.isTablet() ? 3 : 2,
        mainAxisSpacing: 22,
        crossAxisSpacing: 22,
        mainAxisExtent: 195
      ),
      padding: const EdgeInsets.only(
        right: 21,
        left: 21,
        bottom: 100
      ),
      itemCount: isLoading ? 6 : data.length,
      itemBuilder: (context, index) {
        return isLoading
            ? userProfileCardShimmer()
            : userProfileCard(data[index], () => onItemTap(index));
      },
    );
  }
}