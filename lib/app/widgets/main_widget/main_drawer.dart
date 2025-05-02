import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/pages/authentication_page/register_page.dart';
import 'package:webinar/app/pages/main_page/categories_page/categories_page.dart';
import 'package:webinar/app/pages/main_page/home_page/certificates_page/certificates_page.dart';
import 'package:webinar/app/pages/main_page/home_page/financial_page/financial_page.dart';
import 'package:webinar/app/pages/main_page/home_page/setting_page/setting_page.dart';
import 'package:webinar/app/pages/main_page/home_page/subscription_page/subscription_page%20copy.dart';
import 'package:webinar/app/providers/app_language_provider.dart';
import 'package:webinar/app/providers/page_provider.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/storage_service.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/main_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/common/database/app_database.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/enums/page_name_enum.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/currency_utils.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import 'package:webinar/locator.dart';
import '../../pages/main_page/home_page/comments_page/comments_page.dart';
import '../../pages/main_page/home_page/dashboard_page/dashboard_page.dart';
import '../../pages/main_page/home_page/favorites_page/favorites_page.dart';
import '../../pages/main_page/home_page/quizzes_page/quizzes_page.dart';
import '../../pages/main_page/home_page/support_message_page/support_message_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MainDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const MainDrawer({super.key, required this.scaffoldKey});
  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  String token = '';
  bool showCurrencySelector = false;
  Map<String, dynamic> systemSettings = {};
  bool enableSignup = false;
  String currentLanguage = '';
  @override
  void initState() {
    super.initState();
    getToken();
  }

  Future<void> getToken() async {
    final value = await AppData.getAccessToken();

    if (mounted) {
      setState(() {
        token = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppLanguageProvider, UserProvider>(
        builder: (context, provider, userProvider, _) {
      getToken();

      return Directionality(
        textDirection: locator<AppLanguage>().currentLanguage == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.grey[100], // Light background
          body: Column(
            children: [
              // User Profile Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                height: 260, // Set desired height

                decoration: BoxDecoration(
                  color: green77(),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 60),
                    GestureDetector(
                      onTap: () {
                        if (hasAccess()) {
                          nextRoute(SettingPage.pageName);
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: token.isEmpty
                              ? SvgPicture.asset(
                                  AppAssets.splashLogoSvg,
                                  width: 85,
                                  height: 85,
                                )
                              : Image.network(
                                  userProvider.profile?.avatar ?? '',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      AppAssets.placePng,
                                      width: 85,
                                      height: 85,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userProvider.profile?.fullName ?? appText.webinar,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 100,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    space(20),
                  ],
                ),
              ),

              // Drawer Items
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Column(
                      children: [
                        _buildMenuItem(appText.home, AppAssets.homeSvg, () {
                          if (locator<PageProvider>().page != PageNames.home) {
                            locator<PageProvider>().setPage(PageNames.home);
                          }
                          widget.scaffoldKey.currentState?.closeDrawer();
                        }),
                        if (StorageService.getCanPurchase())
                          _buildMenuItem(
                              appText.dashboard, AppAssets.dashboardSvg, () {
                            if (hasAccess(canRedirect: true)) {
                              nextRoute(DashboardPage.pageName);
                            }
                          }),

                        // _buildMenuItem(
                        //     appText.assignments, AppAssets.assignmentsSvg, () {
                        //   if (hasAccess(canRedirect: true)) {
                        //     nextRoute(AssignmentsPage.pageName);
                        //   }
                        // }),
                        _buildMenuItem(appText.quizzes, AppAssets.quizzesSvg,
                            () {
                          if (hasAccess(canRedirect: true)) {
                            nextRoute(QuizzesPage.pageName);
                          }
                        }),
                        _buildMenuItem(
                            appText.certificates, AppAssets.certificatesSvg,
                            () {
                          if (hasAccess(canRedirect: true)) {
                            nextRoute(CertificatesPage.pageName);
                          }
                        }),
                        _buildMenuItem(
                            appText.favorites, AppAssets.favoritesSvg, () {
                          if (hasAccess(canRedirect: true)) {
                            nextRoute(FavoritesPage.pageName);
                          }
                        }),
                        _buildMenuItem(appText.comments, AppAssets.commentsSvg,
                            () {
                          if (hasAccess(canRedirect: true)) {
                            nextRoute(CommentsPage.pageName);
                          }
                        }),
                        if (StorageService.getCanPurchase())
                          _buildMenuItem(
                              appText.financial, AppAssets.financialSvg, () {
                            if (hasAccess(canRedirect: true)) {
                              nextRoute(FinancialPage.pageName);
                            }
                          }),
                        _buildMenuItem(
                            appText.subscription, AppAssets.subscriptionSvg,
                            () {
                          if (hasAccess(canRedirect: true)) {
                            nextRoute(SubscriptionPage.pageName);
                          }
                        }),
                        _buildMenuItem(appText.support, AppAssets.supportSvg,
                            () {
                          if (hasAccess(canRedirect: true)) {
                            nextRoute(SupportMessagePage.pageName);
                          }
                        }),
                        _languageMenuItem(context), // Language Menu
                        _currencyMenuItem(
                            context), // Currency Menu (conditionally shown)
                        authCardView(),
                        space(70),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget authCardView() {
    return Column(
      children: [
        if (token.isEmpty) ...[
          _authMenuItem(
            appText.login,
            AppAssets.loginArrow,
            () => nextRoute(LoginPage.pageName, isClearBackRoutes: true),
          ),
        ] else
          _authMenuItem(
            appText.logOut,
            AppAssets.logoutArrow,
            () => confirmLogout(context),
          ),
      ],
    );
  }

// Function to show the confirmation dialog before logout
  Future<void> confirmLogout(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.exit_to_app, size: 60, color: Colors.blueGrey),
                SizedBox(height: 16),
                Text(
                  "Confirm Logout",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.cancel, color: Colors.white),
                      label: Text(appText.cancel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close dialog
                        _performLogout();
                        await Future.delayed(Duration(seconds: 3));

                        // Perform logout operations
                        UserService.logout();
                        AppData.saveAccessToken('');
                        AppDataBase.clearBox();
                        locator<UserProvider>().clearAll();
                        locator<AppLanguageProvider>().changeState();

                        if (context.mounted)
                          Navigator.of(context).pop(); // Close loading
                        nextRoute(LoginPage.pageName, isClearBackRoutes: true);
                      },
                      icon: Icon(Icons.exit_to_app, color: Colors.white),
                      label: Text(appText.logOut),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Function to handle the logout process
  Future<void> _performLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppAssets.logoPng, width: 90, height: 90),
                SizedBox(height: 20),
                SpinKitThreeBounce(color: Colors.blueAccent, size: 15.0),
                SizedBox(height: 20),
                Text(
                  appText.mayTakeSeconds,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    // Perform logout operations
    UserService.logout();
    AppData.saveAccessToken('');
    AppDataBase.clearBox();
    locator<UserProvider>().clearAll();
    locator<AppLanguageProvider>().changeState();

    // Simulate delay
    await Future.delayed(const Duration(seconds: 3));

    if (context.mounted) Navigator.of(context).pop(); // Close loading dialog

    widget.scaffoldKey.currentState?.closeDrawer();
    nextRoute(LoginPage.pageName, isClearBackRoutes: true);
  }

// Menu Item Widget with Modern Design

  Widget _authMenuItem(String name, String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Directly pass the function
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: green77(),
          borderRadius:
              BorderRadius.circular(10), // Optional for rounded corners
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centers t he entire row
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              color:
                  Colors.white, // Changed color to white for better visibility
              width: 24,
              height: 24,
            ),
            SizedBox(width: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white, // Changed to white for better contrast
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageMenuItem(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Trigger language change and rebuild
        await MainWidget.showLanguageDialog();
        setState(
            () {}); // Force the widget to rebuild to apply the new language
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white, // Solid white background
          borderRadius:
              BorderRadius.circular(15), // Rounded corners for modern look
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 3), // Subtle shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the content horizontally
          crossAxisAlignment:
              CrossAxisAlignment.center, // Vertically center the content
          children: [
            ClipOval(
              child: Image.asset(
                '${AppAssets.flags}${locator<AppLanguage>().currentLanguage}.png',
                width: 30, // Flag size
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            Text(
              locator<AppLanguage>()
                      .appLanguagesData[locator<AppLanguage>()
                          .appLanguagesData
                          .indexWhere((element) =>
                              element.code!.toLowerCase() ==
                              locator<AppLanguage>()
                                  .currentLanguage
                                  .toLowerCase())]
                      .name ??
                  '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500, // Text styling
              ),
            ),
            SizedBox(width: 12),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black45, // Subtle icon color
              size: 16, // Icon size
            ),
          ],
        ),
      ),
    );
  }

  Widget _currencyMenuItem(BuildContext context) {
    return StorageService.getUserMultiCurrency()
        ? GestureDetector(
            onTap: () {
              MainWidget.showCurrencyDialog();
              setState(() {}); // Force rebuild inside Drawer
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white, // Solid white background
                borderRadius: BorderRadius.circular(
                    15), // Rounded corners for modern look
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 3), // Subtle shadow
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the content horizontally
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Vertically center the content
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    CurrencyUtils.getSymbol(CurrencyUtils.userCurrency),
                    style: style16Regular().copyWith(
                        fontSize: 20,
                        color:
                            Colors.black87), // Text color for currency symbol
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black45, // Subtle icon color
                    size: 22,
                  ),
                ],
              ),
            ),
          )
        : SizedBox();
  }

  Widget _buildMenuItem(String name, String iconPath, Function onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              color: green77(),
              width: 24,
              height: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.black45,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  bool hasAccess({bool canRedirect = false}) {
    if (token.isEmpty) {
      showSnackBar(ErrorEnum.alert, appText.youHaveNotAccess);
      if (canRedirect) {
        nextRoute(LoginPage.pageName, isClearBackRoutes: true);
      }
      return false;
    } else {
      return true;
    }
  }
}
