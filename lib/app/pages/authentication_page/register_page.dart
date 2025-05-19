import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/pages/authentication_page/verify_code_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/web_view_page.dart';
import 'package:webinar/app/pages/main_page/home_page/termsWeb.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/services/guest_service/guest_service.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_widget.dart';
import 'package:webinar/app/widgets/authentication_widget/country_code_widget/code_country.dart';
import 'package:webinar/app/widgets/authentication_widget/register_widget/register_widget.dart';
import 'package:webinar/app/widgets/main_widget/main_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/config/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../common/enums/page_name_enum.dart';
import '../../../config/assets.dart';
import '../../../config/colors.dart';
import '../../../common/components.dart';
import '../../../locator.dart';
import '../../providers/page_provider.dart';

class RegisterPage extends StatefulWidget {
  static const String pageName = '/register';
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController mailController = TextEditingController();
  FocusNode mailNode = FocusNode();
  TextEditingController phoneController = TextEditingController();
  FocusNode phoneNode = FocusNode();

  TextEditingController passwordController = TextEditingController();
  FocusNode passwordNode = FocusNode();
  TextEditingController retypePasswordController = TextEditingController();
  FocusNode retypePasswordNode = FocusNode();
  TextEditingController nameController = TextEditingController();
  FocusNode nameNode = FocusNode();

  bool isEmptyInputs = true;
  bool isPhoneNumber = true;
  bool isSendingData = false;
  bool isPasswordVisible = false;
  bool isRetypePasswordVisible = false;

  CountryCode countryCode = CountryCode(
      code: "EGY",
      dialCode: "+20",
      flagUri: "${AppAssets.flags}eg.png",
      name: "Egypt");

  String accountType = 'user';
  bool isLoadingAccountType = false;

  String? otherRegisterMethod;
  RegisterConfigModel? registerConfig;

  List<dynamic> selectRolesDuringRegistration = [];

  @override
  void initState() {
    super.initState();

    // Initialize selectRolesDuringRegistration with null safety
    if (PublicData.apiConfigData != null &&
        PublicData.apiConfigData['selectRolesDuringRegistration'] != null) {
      selectRolesDuringRegistration = (PublicData
              .apiConfigData['selectRolesDuringRegistration'] as List<dynamic>)
          .toList();
    }

    // Check the register method and initialize with null safety
    if (PublicData.apiConfigData != null) {
      if ((PublicData.apiConfigData['register_method'] ?? '') == 'email') {
        isPhoneNumber = false;
        otherRegisterMethod = 'email';
      } else {
        isPhoneNumber = true;
        otherRegisterMethod = 'phone';
      }
    }

    mailController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty ||
                phoneController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty &&
            retypePasswordController.text.trim().isNotEmpty &&
            nameController.text.trim().isNotEmpty) {
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

    phoneController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty ||
                phoneController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty &&
            retypePasswordController.text.trim().isNotEmpty &&
            nameController.text.trim().isNotEmpty) {
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

    passwordController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty ||
                phoneController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty &&
            retypePasswordController.text.trim().isNotEmpty &&
            nameController.text.trim().isNotEmpty) {
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

    retypePasswordController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty ||
                phoneController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty &&
            retypePasswordController.text.trim().isNotEmpty &&
            nameController.text.trim().isNotEmpty) {
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

    nameController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty ||
                phoneController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty &&
            retypePasswordController.text.trim().isNotEmpty &&
            nameController.text.trim().isNotEmpty) {
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
    getAccountTypeFileds();
  }

  getAccountTypeFileds() async {
    if (mounted) {
      setState(() {});
    }

    registerConfig = await GuestService.registerConfig(accountType);

    if (mounted) {
      setState(() {
        isLoadingAccountType = false;
      });
    }
  }

  @override
  void dispose() {
    mailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    retypePasswordController.dispose();
    nameController.dispose();
    mailNode.dispose();
    phoneNode.dispose();
    passwordNode.dispose();
    retypePasswordNode.dispose();
    nameNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          nextRoute(MainPage.pageName, isClearBackRoutes: true);
          return false;
        },
        child: directionality(
          child: Scaffold(
              backgroundColor: Colors.blue.shade700,
              body: Stack(children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        space(getSize().height * 0.08),
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        AppAssets.logoPng,
                                        width: 64,
                                        height: 64,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              space(24),
                              input(
                                nameController,
                                nameNode,
                                appText.yourName,
                                iconPathLeft: AppAssets.profileSvg,
                                leftIconSize: 18,
                                isBorder: true,
                              ),
                              space(20),
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
                                      width: 64,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      alignment: Alignment.center,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          countryCode.flagUri ?? '',
                                          width: 28,
                                          height: 28,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  space(0, width: 12),
                                  Expanded(
                                    child: input(
                                      phoneController,
                                      phoneNode,
                                      appText.phoneNumber,
                                      isBorder: true,
                                      isNumber: true,
                                    ),
                                  ),
                                ],
                              ),
                              space(20),
                              input(
                                mailController,
                                mailNode,
                                appText.yourEmail,
                                iconPathLeft: AppAssets.mailSvg,
                                leftIconSize: 18,
                                isBorder: true,
                              ),
                              space(20),
                              input(
                                passwordController,
                                passwordNode,
                                appText.password,
                                iconPathLeft: AppAssets.passwordSvg,
                                leftIconSize: 18,
                                isPassword: true,
                                isPasswordVisible: isPasswordVisible,
                                isBorder: true,
                                togglePasswordVisibility: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                              space(20),
                              input(
                                retypePasswordController,
                                retypePasswordNode,
                                appText.retypePassword,
                                iconPathLeft: AppAssets.passwordSvg,
                                leftIconSize: 18,
                                isPassword: true,
                                isPasswordVisible: isRetypePasswordVisible,
                                isBorder: true,
                                togglePasswordVisibility: () {
                                  setState(() {
                                    isRetypePasswordVisible =
                                        !isRetypePasswordVisible;
                                  });
                                },
                              ),
                              space(28),
                              Container(
                                width: double.infinity,
                                height: 58,
                                child: ElevatedButton.icon(
                                  onPressed: isEmptyInputs
                                      ? null
                                      : () async {
                                          if (registerConfig
                                                  ?.formFields?.fields !=
                                              null) {
                                            for (var i = 0;
                                                i <
                                                    (registerConfig?.formFields
                                                            ?.fields?.length ??
                                                        0);
                                                i++) {
                                              if (registerConfig
                                                          ?.formFields
                                                          ?.fields?[i]
                                                          .isRequired ==
                                                      1 &&
                                                  registerConfig
                                                          ?.formFields
                                                          ?.fields?[i]
                                                          .userSelectedData ==
                                                      null) {
                                                if (registerConfig?.formFields
                                                        ?.fields?[i].type !=
                                                    'toggle') {
                                                  showSnackBar(ErrorEnum.alert,
                                                      '${appText.pleaseReview} ${registerConfig?.formFields?.fields?[i].getTitle()}');
                                                  return;
                                                }
                                              }
                                            }
                                          }

                                          // Phone number validation
                                          if (phoneController.text
                                                  .trim()
                                                  .length <
                                              10) {
                                            showSnackBar(ErrorEnum.alert,
                                                'Please enter a valid phone number (minimum 10 digits)');
                                            return;
                                          }

                                          // Email validation
                                          bool isValidEmail = RegExp(
                                                  r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                                              .hasMatch(
                                                  mailController.text.trim());
                                          if (!isValidEmail) {
                                            showSnackBar(ErrorEnum.alert,
                                                'Please enter a valid email address');
                                            return;
                                          }

                                          // Password validation
                                          if (passwordController.text
                                                  .trim()
                                                  .length <
                                              8) {
                                            showSnackBar(ErrorEnum.alert,
                                                'Password must be at least 8 characters long');
                                            return;
                                          }

                                          // Check for at least one uppercase letter
                                          if (!passwordController.text
                                              .trim()
                                              .contains(RegExp(r'[A-Z]'))) {
                                            showSnackBar(ErrorEnum.alert,
                                                'Password must contain at least one uppercase letter');
                                            return;
                                          }

                                          // Check for at least one number
                                          if (!passwordController.text
                                              .trim()
                                              .contains(RegExp(r'[0-9]'))) {
                                            showSnackBar(ErrorEnum.alert,
                                                'Password must contain at least one number');
                                            return;
                                          }

                                          // Password confirmation validation
                                          if (passwordController.text.trim() !=
                                              retypePasswordController.text
                                                  .trim()) {
                                            showSnackBar(ErrorEnum.alert,
                                                'Passwords do not match');
                                            return;
                                          }

                                          if (nameController.text
                                                  .trim()
                                                  .length <
                                              3) {
                                            showSnackBar(ErrorEnum.alert,
                                                'Please enter a valid name (minimum 3 characters)');
                                            return;
                                          }

                                          setState(() {
                                            isSendingData = true;
                                          });

                                          Map? res = await AuthenticationService
                                              .register(
                                            context,
                                            registerConfig?.registerMethod ??
                                                '',
                                            nameController.text.trim(),
                                            mailController.text.trim(),
                                            countryCode.dialCode.toString(),
                                            phoneController.text.trim(),
                                            passwordController.text.trim(),
                                            retypePasswordController.text
                                                .trim(),
                                            accountType,
                                          );

                                          if (res != null && res['success']) {
                                            // Always go to verification page first
                                            nextRoute(
                                              VerifyCodePage.pageName,
                                              arguments: {
                                                'user_id': res['data']
                                                    ['user_id'],
                                                'registerMethod': registerConfig
                                                        ?.registerMethod ??
                                                    '',
                                                'name':
                                                    nameController.text.trim(),
                                                'email':
                                                    mailController.text.trim(),
                                                'phone':
                                                    phoneController.text.trim(),
                                                'countryCode': countryCode
                                                    .dialCode
                                                    .toString(),
                                                'password': passwordController
                                                    .text
                                                    .trim(),
                                                'retypePassword':
                                                    retypePasswordController
                                                        .text
                                                        .trim(),
                                              },
                                              isClearBackRoutes:
                                                  true, // Prevent going back to registration
                                            );
                                          } else {
                                            // Show error message if registration fails
                                            showSnackBar(ErrorEnum.error,
                                                'Registration failed. Please try again.');
                                          }

                                          setState(() {
                                            isSendingData = false;
                                          });
                                        },
                                  icon: Icon(
                                    Icons.person_add_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  label: isSendingData
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          appText.createAnAccount,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isEmptyInputs ? greyCF : green77(),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        space(32),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              nextRoute(
                                TermsPage.pageName,
                                arguments: '${Constants.dommain}/pages/terms',
                              );
                            },
                            child: Text(
                              appText.termsPoliciesDesc,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        space(32),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  appText.haveAnAccount,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                space(0, width: 6),
                                GestureDetector(
                                  onTap: () {
                                    nextRoute(LoginPage.pageName,
                                        isClearBackRoutes: true);
                                  },
                                  child: Text(
                                    appText.login,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            space(28),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    appText.or,
                                    style: style16Regular().copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        space(28),
                        Container(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final GoogleSignInAccount? gUser =
                                  await GoogleSignIn().signIn();
                              final GoogleSignInAuthentication gAuth =
                                  await gUser!.authentication;

                              if (gAuth.accessToken != null) {
                                setState(() {
                                  isSendingData = true;
                                });

                                try {
                                  bool res = await AuthenticationService.google(
                                    context,
                                    gUser.email,
                                    gAuth.accessToken ?? '',
                                    gUser.displayName ?? '',
                                  );

                                  if (res) {
                                    await FirebaseMessaging.instance
                                        .deleteToken();
                                    nextRoute(MainPage.pageName,
                                        isClearBackRoutes: true);
                                  }
                                } catch (_) {}

                                setState(() {
                                  isSendingData = false;
                                });
                              }
                            },
                            icon: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset(
                                AppAssets.googleSvg,
                                height: 22,
                                width: 22,
                              ),
                            ),
                            label: Text(
                              appText.googleSign,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ])),
        ));
  }

  Widget socialWidget(String icon, Function onTap) {
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
