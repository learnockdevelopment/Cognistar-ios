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

class SplashPage extends StatefulWidget {
  static const String pageName = '/splash';
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    fetchSign();
    fetchPurchase();
    fetchSystemSettings();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));


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
      body: Container(
        width: getSize().width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: AnimatedBuilder(
                    animation: animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1 +
                            (1 *
                                animationController
                                    .value), // Smaller pulse range for smoother effect
                        child: Opacity(
                          opacity: animationController
                              .value, // Gradual appearance (step-by-step)
                          child: Image.asset(
                            AppAssets.logoPng,
                            width: 100,
                            height: 100,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            space(35),
            const SizedBox(
              width: 35,
              child: LoadingIndicator(
                indicatorType: Indicator.ballBeat,
                colors: [secondaryColor],
                strokeWidth: 100,
                backgroundColor: Colors.transparent,
                pathBackgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
