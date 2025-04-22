
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/providers/page_provider.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/services/storage_service.dart';
import 'package:webinar/app/widgets/authentication_widget/register_widget/register_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/enums/page_name_enum.dart';
import 'package:webinar/locator.dart';

import '../../../common/data/app_language.dart';
import '../../../common/utils/app_text.dart';
import '../../../config/assets.dart';
import '../../../config/colors.dart';
import '../../../config/styles.dart';
import '../../widgets/authentication_widget/country_code_widget/code_country.dart';

class LoginPage extends StatefulWidget {
  static const String pageName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController mailController = TextEditingController();
  FocusNode mailNode = FocusNode();
  TextEditingController passwordController = TextEditingController();
  FocusNode passwordNode = FocusNode();
  bool isSendingData = false; // Track whether data is being sent
  String? errorMessage; // Hold the error message if any
  bool enableSignup = false;

  String? otherRegisterMethod;
  bool isEmptyInputs = true;
  bool isPhoneNumber = true;
  bool isLoading = true;
  bool isPasswordVisible = false;

  CountryCode countryCode = CountryCode(
      code: "EGY",
      dialCode: "+20",
      flagUri: "${AppAssets.flags}eg.png",
      name: "Egypt");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Simulate fetching data or fetch actual data here
        await Future.delayed(Duration(seconds: 2));
        if (mounted) {
          setState(() {
            isLoading = false; // Update loading state when done
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    });

    if ((PublicData.apiConfigData?['register_method'] ?? '') == 'email') {
      isPhoneNumber = false; // Default to email
      otherRegisterMethod = 'email';
    } else {
      isPhoneNumber = true; // Default to phone
      otherRegisterMethod = 'phone'; // Set default method to phone
    }

    // Add listener to mailController
    mailController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty) {
          if (isEmptyInputs) {
            isEmptyInputs = false;
            setState(() {});
          }
        } else {
          if (!isEmptyInputs) {
            isEmptyInputs = true;
            setState(() {});
          }
        }
      }
    });
    // Add listener to passwordController
    passwordController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty) {
          if (isEmptyInputs) {
            isEmptyInputs = false;
            setState(() {});
          }
        } else {
          if (!isEmptyInputs) {
            isEmptyInputs = true;
            setState(() {});
          }
        }
      }
    });
  }
  static void _showErrorDialog(BuildContext context, Map<String, String> errorData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 50,
                ),
                SizedBox(height: 15),
                Text(
                  errorData['title'] ?? 'Error',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  errorData['message'] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text(
                    appText.ok,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        nextRoute(MainPage.pageName, isClearBackRoutes: true);
        return false;
      },
      child: Directionality(
        textDirection: locator<AppLanguage>().currentLanguage == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          body: Stack(
            children: [
              // Background Image with Overlay
              Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppAssets.introBgPng),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ),

              // Form Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Form Container
                      Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 25,
                              spreadRadius: 5,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo
                            SvgPicture.asset(AppAssets.splashLogoSvg,
                                width: 85, height: 85),
                            SizedBox(height: 12),

                            // Welcome Back
                            Text(
                              appText.welcomeBack,
                              style: GoogleFonts.cairo(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 22),

                            // Account Type Selector
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.all(7),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          otherRegisterMethod = 'email';
                                          isPhoneNumber = false;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        padding:
                                        EdgeInsets.symmetric(vertical: 14),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: otherRegisterMethod == 'email'
                                              ? primaryColor
                                              : Colors.transparent,
                                          borderRadius:
                                          BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          appText.email,
                                          style: TextStyle(
                                            color:
                                            otherRegisterMethod == 'email'
                                                ? Colors.white
                                                : Colors.black54,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          otherRegisterMethod = 'phone';
                                          isPhoneNumber = true;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        padding:
                                        EdgeInsets.symmetric(vertical: 14),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: otherRegisterMethod == 'phone'
                                              ? primaryColor
                                              : Colors.transparent,
                                          borderRadius:
                                          BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          appText.phone,
                                          style: TextStyle(
                                            color:
                                            otherRegisterMethod == 'phone'
                                                ? Colors.white
                                                : Colors.black54,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 22),

                            // Input Fields
                            if (isPhoneNumber)
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      CountryCode? newData =
                                      await RegisterWidget
                                          .showCountryDialog();
                                      if (newData != null) {
                                        countryCode = newData;
                                        setState(() {});
                                      }
                                    },
                                    child: Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.shade300,
                                              blurRadius: 5)
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                          countryCode.flagUri ?? '',
                                          width: 24,
                                          height: 24),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: input(mailController, mailNode,
                                        appText.phoneNumber,
                                        isNumber: true),
                                  ),
                                ],
                              )
                            else
                              input(mailController, mailNode, appText.email,
                                  iconPathLeft: AppAssets.mailSvg),

                            SizedBox(height: 20),
                            input(
                              passwordController,
                              passwordNode,
                              appText.password,
                              iconPathLeft: AppAssets.passwordSvg,
                              isPassword: true,
                              isPasswordVisible: isPasswordVisible,
                              togglePasswordVisibility: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),

                            SizedBox(height: 18),
                            if (StorageService.getEnableSignup())

                            // Forgot Password
                              Align(
                                child: GestureDetector(
                                  child: Text(
                                    appText.forgetPassword,
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),

                            SizedBox(height: 30),

                            // Login Button with Gradient
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();

                                  // ✅ Check if fields are empty first
                                  if (mailController.text.trim().isEmpty ||
                                      passwordController.text.trim().isEmpty) {
                                    _showErrorDialog(context, {
                                      'title': 'Missing Fields',
                                      'message': 'Please fill in both email and password fields.',
                                    });
                                    return;
                                  }

                                  setState(() {
                                    isSendingData = true;
                                  });

                                  bool res = await AuthenticationService.login(
                                    context,
                                    isPhoneNumber
                                        ? '${countryCode.dialCode}${mailController.text.trim()}'
                                        : mailController.text.trim(),
                                    passwordController.text.trim(),
                                  );

                                  setState(() {
                                    isSendingData = false;
                                  });

                                  if (res) {
                                    nextRoute(MainPage.pageName, isClearBackRoutes: true);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 6,
                                ),
                                child: Text(
                                  appText.login,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            space(35),
                            if (StorageService.getEnableSignup())
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade400,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      appText.or, // Localized "or"
                                      style: style16Regular(),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade400,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                            SizedBox(height: 30),

                            if (StorageService.getEnableSignup())
                            // Google Sign-In Button
                              SizedBox(
                                width: double.infinity,
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        // Show loading dialog
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                backgroundColor: Colors.transparent,
                                                child: Container(
                                                  width: 300,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 30, horizontal: 25),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(20),
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
                                                      Image.asset(AppAssets.logoPng,
                                                          width: 90, height: 90),
                                                      SizedBox(height: 20),
                                                      SpinKitThreeBounce(
                                                          color: primaryColor,
                                                          size: 15.0),
                                                      SizedBox(height: 20),
                                                      Text(
                                                        appText.mayTakeSeconds,
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                            color: Colors.black),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });

                                        try {
                                          print("Google Sign-In started...");

                                          final GoogleSignInAccount? gUser =
                                          await GoogleSignIn().signIn();

                                          if (gUser == null) {
                                            print(
                                                "Google sign-in canceled by user.");
                                            Navigator.pop(
                                                context); // Close loading dialog
                                            return;
                                          }

                                          print(
                                              "Google user signed in: ${gUser.email}");

                                          final GoogleSignInAuthentication gAuth =
                                          await gUser.authentication;

                                          if (gAuth.accessToken == null) {
                                            print("Google Authentication failed.");
                                            Navigator.pop(context);
                                            return;
                                          }

                                          print(
                                              "Access Token received: ${gAuth.accessToken}");

                                          bool res =
                                          await AuthenticationService.google(
                                            context,
                                            gUser.email,
                                            gAuth.accessToken ?? '',
                                            gUser.displayName ?? '',
                                          );

                                          if (!res) {
                                            print("Authentication failed.");
                                            Navigator.pop(context);
                                            return;
                                          }

                                          int? userId = await AppData.getUserId();

                                          if (userId == null) {
                                            print(
                                                "User ID not found in shared preferences.");
                                            Navigator.pop(context);
                                            return;
                                          }

                                          print('Retrieved User ID: $userId');

                                          Navigator.pop(
                                              context); // Ensure loading dialog is closed before navigation

                                          locator<PageProvider>()
                                              .setPage(PageNames.home);
                                          nextRoute(MainPage.pageName,
                                              isClearBackRoutes: true);
                                        } catch (e) {
                                          print("Error during Google Sign-In: $e");
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .blue.shade800, // Google-like color
                                          borderRadius: BorderRadius.circular(
                                              16), // Rounded corners
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset:
                                              Offset(0, 3), // Shadow position
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              AppAssets.googleSvg, // Google icon
                                              height: 24,
                                              width: 24,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              appText.googleSign,
                                              style: TextStyle(
                                                color: Colors
                                                    .white, // White text color
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
    );
  }

  @override
  void dispose() {
    // Remove listeners in dispose() to prevent memory leaks
    mailController.removeListener(() {});
    passwordController.removeListener(() {});

    // Dispose controllers and focus nodes
    mailController.dispose();
    mailNode.dispose();
    passwordController.dispose();
    passwordNode.dispose();

    super.dispose();
  }

  socialWidget(String icon, Function onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 98,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius(radius: 16),
        ),
        child: SvgPicture.asset(
          icon,
          width: 30,
        ),
      ),
    );
  }
}
