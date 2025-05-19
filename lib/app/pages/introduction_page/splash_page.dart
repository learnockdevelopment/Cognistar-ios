import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webinar/app/pages/introduction_page/intro_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/pages/offline_page/internet_connection_page.dart';
import 'package:webinar/app/services/guest_service/guest_service.dart';
import 'package:webinar/app/services/storage_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';

class SplashPage extends StatefulWidget {
  static const String pageName = '/splash';
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<double> loadingFadeAnimation;
  late Animation<double> pulseAnimation;
  late Animation<double> slideAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> logoSlideAnimation;
  late Animation<double> hideAnimation;

  @override
  void initState() {
    super.initState();
    fetchSign();
    fetchPurchase();
    fetchSystemSettings();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
    );

    slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );

    logoSlideAnimation = Tween<double>(begin: 0.0, end: -1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
    );

    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );

    hideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    loadingFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      animationController.forward();

      Timer(const Duration(seconds: 3), () async {
        final List<ConnectivityResult> connectivityResult =
            await (Connectivity().checkConnectivity());

        if (connectivityResult.contains(ConnectivityResult.none)) {
          nextRoute(InternetConnectionPage.pageName, isClearBackRoutes: true);
        } else {
          String token = await AppData.getAccessToken();

          if (mounted) {
            if (token.isEmpty) {
              bool isFirst = await AppData.getIsFirst();

              if (isFirst) {
                nextRoute(IntroPage.pageName, isClearBackRoutes: true);
              } else {
                nextRoute(MainPage.pageName, isClearBackRoutes: true);
              }
            } else {
              nextRoute(MainPage.pageName, isClearBackRoutes: true);
            }
          }
        }
      });
    });

    GuestService.config();
  }

  Future<void> fetchSign() async {
    try {
      var apiResponse = await GuestService.systemsettings();
      if (apiResponse is Map && apiResponse.containsKey('data')) {
        var data = apiResponse['data'];

        if (data.containsKey('security_settings')) {
          var securitySettings = data['security_settings'];

          if (securitySettings.containsKey('enable_signup')) {
            bool enableSignup = (securitySettings['enable_signup'] == '1');
            await StorageService.setEnableSignup(enableSignup);
          }
        }
      }
    } catch (e) {
      print("Error fetching enable_signup: $e");
    }
  }

  Future<void> fetchPurchase() async {
    try {
      var apiResponse = await GuestService.systemsettings();
      if (apiResponse is Map && apiResponse.containsKey('data')) {
        var data = apiResponse['data'];

        if (data.containsKey('general_settings')) {
          var generalSettings = data['general_settings'];

          if (generalSettings.containsKey('can_buy')) {
            bool canPurchase = (generalSettings['can_buy'] == '1');
            await StorageService.setCanPurchase(canPurchase);
          }
        }
      }
    } catch (e) {
      print("Error fetching can_buy: $e");
    }
  }

  Future<void> fetchSystemSettings() async {
    print("Fetching system settings...");

    final response = await GuestService.systemsettings();
    print("System settings response: $response");

    await GuestService.config();
    print("GuestService.config() called");

    if (response != null && response['success'] == true) {
      var data = response['data'];
      print("Received data: $data");

      if (data.containsKey('general_settings')) {
        var generalSettings = data['general_settings'];
        print("General settings: $generalSettings");

        if (generalSettings.containsKey('user_multi_currency')) {
          var rawValue = generalSettings['user_multi_currency'];
          bool userMultiCurrency = (rawValue == 1 || rawValue == '1');

          print("User Multi Currency Raw Value: $rawValue");
          print("Parsed User Multi Currency: $userMultiCurrency");

          await StorageService.setUserMultiCurrency(userMultiCurrency);
          print("User multi-currency setting saved: $userMultiCurrency");
        } else {
          print("Key 'user_multi_currency' not found in general settings");
        }
        if (generalSettings.containsKey('whatsapp_floating_button')) {
          String whatsappNumber = generalSettings['whatsapp_floating_button'];

          print("WhatsApp Floating Button Number: $whatsappNumber");

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('whatsapp_floating_button', whatsappNumber);

          print("WhatsApp number saved to SharedPreferences: $whatsappNumber");
        } else {
          print("Key 'whatsapp_floating_button' not found in general settings");
        }
      } else {
        print("Key 'general_settings' not found in response data");
      }
    } else {
      print("Failed to fetch system settings or response is null/unsuccessful");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Full screen image with slide animation
          Positioned.fill(
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, slideAnimation.value * MediaQuery.of(context).size.height),
                  child: Transform.scale(
                    scale: scaleAnimation.value,
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: Image.asset(
                        AppAssets.boyPng,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Modern gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Loading overlay with modern design
          Positioned.fill(
            child: Center(
              child: FadeTransition(
                opacity: loadingFadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: pulseAnimation.value,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.15),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
