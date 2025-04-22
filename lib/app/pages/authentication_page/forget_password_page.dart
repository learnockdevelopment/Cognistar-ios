import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_widget.dart';
import 'package:webinar/app/widgets/authentication_widget/country_code_widget/code_country.dart';
import 'package:webinar/app/widgets/authentication_widget/register_widget/register_widget.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'dart:convert';
import '../../../common/utils/app_text.dart';
import '../../../config/assets.dart';
import '../../../config/colors.dart';
import '../../../config/styles.dart';
import 'login_page.dart';

class ForgetPasswordPage extends StatefulWidget {
  static const String pageName = '/forget-password';
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  TextEditingController mailController = TextEditingController();
  FocusNode mailNode = FocusNode();

  bool isEmptyInputs = true;
  bool isSendingData = false;

  String? otherRegisterMethod;
  bool isPhoneNumber = true; // Default to phone

  CountryCode countryCode = CountryCode(
      code: "EGY",
      dialCode: "+20",
      flagUri: "${AppAssets.flags}eg.png",
      name: "Egypt");

  @override
  void initState() {
    super.initState();

    // Fetch the API response (this is assumed to be already set correctly in PublicData)
    var apiResponse = PublicData.apiConfigData;

    // Print the full API response for debugging
    // print("API Response: ${jsonEncode(apiResponse)}");

    // Determine the registration method from the API response
    if ((apiResponse?['register_method'] ?? '') == 'mobile') {
      isPhoneNumber = true; // If register_method is mobile, show phone input
      otherRegisterMethod = 'mobile';
    } else if ((apiResponse?['register_method'] ?? '') == 'email') {
      isPhoneNumber = false; // If register_method is email, show email input
      otherRegisterMethod = 'email';
    }

    mailController.addListener(() {
      if (mailController.text.trim().isNotEmpty) {
        if (isEmptyInputs) {
          setState(() {
            isEmptyInputs = false;
          });
        }
      } else {
        if (!isEmptyInputs) {
          setState(() {
            isEmptyInputs = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        nextRoute(LoginPage.pageName, isClearBackRoutes: true);
        return false;
      },
      child: directionality(
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  AppAssets.introBgPng,
                  width: getSize().width,
                  height: getSize().height,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: padding(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      space(getSize().height * .11),

                      // title
                      Row(
                        children: [
                          Text(
                            appText.forgetPassword,
                            style: style24Bold(),
                          ),
                          space(0, width: 4),
                          Transform.translate(
                            offset:
                                Offset(0, -8), // Move the emoji up by 5 pixels
                            child: SvgPicture.asset(
                              AppAssets.emoji2Svg, // Your asset path
                              width: 30, // Adjust width as needed
                              height: 30, // Adjust height as needed
                            ),
                          ),
                        ],
                      ),

                      // desc
                      Text(
                        appText.forgetPasswordDesc,
                        style: style14Regular().copyWith(color: greyA5),
                      ),

                      const Spacer(flex: 2),
                      space(25),

                      // Check the 'showOtherRegisterMethod' field in API response
                      if (PublicData
                              .apiConfigData?['showOtherRegisterMethod'] ==
                          '1') ...{
                        space(15),
                        Container(
                          width: getSize().width,
                          height: 52,
                          child: Row(
                            children: [
                              // email
                              if (otherRegisterMethod == 'email') ...{
                                AuthWidget.accountTypeWidget(
                                  appText.email,
                                  otherRegisterMethod ??
                                      'email', // Default to email if null
                                  'email',
                                  () {
                                    setState(() {
                                      otherRegisterMethod =
                                          'email'; // Switch to email
                                      isPhoneNumber =
                                          false; // Ensure it's set to email
                                    });
                                  },
                                ),
                              },
                              // phone
                              if (otherRegisterMethod == 'mobile') ...{
                                AuthWidget.accountTypeWidget(
                                  appText.phone,
                                  otherRegisterMethod ??
                                      'phone', // Default to phone if null
                                  'phone',
                                  () {
                                    setState(() {
                                      otherRegisterMethod =
                                          'mobile'; // Switch to phone
                                      isPhoneNumber =
                                          true; // Ensure it's set to phone
                                      mailController
                                          .clear(); // Clear the email field (optional)
                                    });
                                  },
                                ),
                              },
                            ],
                          ),
                        ),
                        space(15),
                      },

                      // input fields based on registration method
                      Column(
                        children: [
                          if (isPhoneNumber) ...{
                            // phone input
                            Row(
                              children: [
                                // country code
                                GestureDetector(
                                  onTap: () async {
                                    CountryCode? newData = await RegisterWidget
                                        .showCountryDialog();
                                    if (newData != null) {
                                      countryCode = newData;
                                      setState(() {});
                                    }
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: borderRadius(),
                                    ),
                                    alignment: Alignment.center,
                                    child: ClipRRect(
                                      borderRadius: borderRadius(radius: 50),
                                      child: Image.asset(
                                        countryCode.flagUri ?? '',
                                        width: 21,
                                        height: 19,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                space(0, width: 15),
                                Expanded(
                                    child: input(mailController, mailNode,
                                        appText.phoneNumber)),
                              ],
                            ),
                          } else ...{
                            // email input
                            input(mailController, mailNode, appText.email,
                                iconPathLeft: AppAssets.mailSvg,
                                leftIconSize: 14),
                          },
                          space(16),
                        ],
                      ),

                      space(16),

                      Center(
                        child: button(
                          onTap: () async {
                            if (!isEmptyInputs) {
                              setState(() {
                                isSendingData = true;
                              });

                              bool res =
                                  await AuthenticationService.forgetPassword(
                                '${isPhoneNumber ? countryCode.dialCode!.replaceAll('+', '') : ''}${mailController.text.trim()}',
                              );

                              if (res) {}

                              setState(() {
                                isSendingData = false;
                              });
                            }
                          },
                          width: getSize().width,
                          height: 52,
                          text: appText.verifyMyAccount,
                          bgColor: isEmptyInputs ? greyCF : green77(),
                          textColor: Colors.white,
                          borderColor: Colors.transparent,
                          isLoading: isSendingData,
                        ),
                      ),

                      const Spacer(
                        flex: 3,
                      ),

                      // haveAnAccount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appText.haveAnAccount,
                            style: style16Regular(),
                          ),
                          space(0, width: 2),
                          GestureDetector(
                            onTap: () {
                              backRoute();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Text(
                              appText.login, // Localized "Login"
                              style: style16Regular().copyWith(
                                color: Colors
                                    .blue.shade800, // Highlight login link
                                fontWeight:
                                    FontWeight.bold, // Make the link bold
                              ),
                            ),
                          )
                        ],
                      ),

                      const Spacer(flex: 1),
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
}