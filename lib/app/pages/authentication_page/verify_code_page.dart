import 'dart:developer' as dev;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webinar/app/pages/authentication_page/register_page.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/widgets/authentication_widget/register_widget/register_widget.dart';
import 'package:webinar/common/common.dart';

import '../../../common/data/api_public_data.dart';
import '../../../common/data/app_data.dart';
import '../../../common/enums/page_name_enum.dart';
import '../../../common/utils/app_text.dart';
import '../../../config/assets.dart';
import '../../../config/colors.dart';
import '../../../config/styles.dart';
import '../../../common/components.dart';
import '../../../locator.dart';
import '../../providers/page_provider.dart';
import '../main_page/main_page.dart';
import '../../../common/enums/error_enum.dart';

class VerifyCodePage extends StatefulWidget {
  static const String pageName = '/verify-code';
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {

  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();
  TextEditingController controller5 = TextEditingController();

  FocusNode codeNode1 = FocusNode();
  FocusNode codeNode2 = FocusNode();
  FocusNode codeNode3 = FocusNode();
  FocusNode codeNode4 = FocusNode();
  FocusNode codeNode5 = FocusNode();

  bool isEmptyInputs = true;
  bool isSendingData = false;
  bool isCodeAgain = false;

  late Map data;
  String name = '';
  String email = '';
  String phone = '';
  String countryCode = '';
  String password = '';
  String retypePassword = '';

  @override
  void initState() {
    super.initState();
    
    // Validate that we have the required data
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        data = ModalRoute.of(context)!.settings.arguments as Map;
        if (data['user_id'] == null) {
          // If no user ID, go back to registration
          nextRoute(RegisterPage.pageName, isClearBackRoutes: true);
          return;
        }
        // Store registration data for resend functionality
        name = data['name']?.toString() ?? '';
        email = data['email']?.toString() ?? '';
        phone = data['phone']?.toString() ?? '';
        countryCode = data['countryCode']?.toString() ?? '';
        password = data['password']?.toString() ?? '';
        retypePassword = data['retypePassword']?.toString() ?? '';
      } catch (e) {
        // If any error in getting data, go back to registration
        nextRoute(RegisterPage.pageName, isClearBackRoutes: true);
      }
    });
    
    controller1.addListener(() {
      if(getCode().length == 5){
        if(isEmptyInputs){
          setState(() {
            isEmptyInputs = false;
          });
        }
      }else{
        if(!isEmptyInputs){
          setState(() {
            isEmptyInputs = true;
          });
        }
      }
    });
    
    controller2.addListener(() {
      if(getCode().length == 5){
        if(isEmptyInputs){
          setState(() {
            isEmptyInputs = false;
          });
        }
      }else{
        if(!isEmptyInputs){
          setState(() {
            isEmptyInputs = true;
          });
        }
      }
    });

    controller3.addListener(() {
      if(getCode().length == 5){
        if(isEmptyInputs){
          setState(() {
            isEmptyInputs = false;
          });
        }
      }else{
        if(!isEmptyInputs){
          setState(() {
            isEmptyInputs = true;
          });
        }
      }
    });

    controller4.addListener(() {
      if(getCode().length == 5){
        if(isEmptyInputs){
          setState(() {
            isEmptyInputs = false;
          });
        }
      }else{
        if(!isEmptyInputs){
          setState(() {
            isEmptyInputs = true;
          });
        }
      }
    });

    controller5.addListener(() {
      if(getCode().length == 5){
        if(isEmptyInputs){
          setState(() {
            isEmptyInputs = false;
          });
        }
      }else{
        if(!isEmptyInputs){
          setState(() {
            isEmptyInputs = true;
          });
        }
      }
    });
  }

  String getCode(){
    return controller1.text.trim() + controller2.text.trim() + controller3.text.trim() + controller4.text.trim() + controller5.text.trim();
  }

  onPastedCode(String code){
    List<String> items = code.split('');
    controller1.text = items[0];
    controller2.text = items[1];
    controller3.text = items[2];
    controller4.text = items[3];
    controller5.text = items[4];
    FocusScope.of(navigatorKey.currentContext!).unfocus();
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent going back to registration
        nextRoute(RegisterPage.pageName, isClearBackRoutes: true);
        return false;
      },
      child: directionality(
        child: Scaffold(
          body: Stack(
            children: [

              Positioned.fill(
                child: Image.asset(
                  AppAssets.intro3Png,
                  width: getSize().width,
                  height: getSize().height,
                  fit: BoxFit.cover,
                )
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
                            appText.accountVerification,
                            style: style24Bold(),
                          ),
              
                          space(0,width: 4),
              
                           Transform.translate(
                          offset: Offset(0, -8),  // Move the emoji up by 5 pixels
                          child: SvgPicture.asset(
                            AppAssets.emoji2Svg,  // Your asset path
                            width: 30,             // Adjust width as needed
                            height: 30,            // Adjust height as needed
                          ),
                        ),
                        ],
                      ),
              
                      // desc
                      Text(
                        appText.accountVerificationDesc,
                        style: style14Regular().copyWith(color: greyA5),
                      ),
              
                      const Spacer(),
              
              
                      Directionality(
                        textDirection: TextDirection.ltr,
              
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            
                            RegisterWidget.codeInput(controller1, codeNode1, codeNode2, null, onPastedCode),
                      
                            space(0,width: 10),
                            
                            RegisterWidget.codeInput(controller2, codeNode2, codeNode3, codeNode1, onPastedCode),
                            
                            space(0,width: 10),
                            
                            RegisterWidget.codeInput(controller3, codeNode3, codeNode4, codeNode2, onPastedCode),
                            
                            space(0,width: 10),
                            
                            RegisterWidget.codeInput(controller4, codeNode4, codeNode5, codeNode3, onPastedCode),
                            
                            space(0,width: 10),
                            
                            RegisterWidget.codeInput(controller5, codeNode5, null, codeNode4, onPastedCode),
                          ],
                        ),
                      ),

                      const Spacer(),


                      Center(
                        child: button(
                          onTap: () async {
                            if(!isEmptyInputs){
                              String code = controller1.text + controller2.text + controller3.text + controller4.text + controller5.text;
                            
                              if(code.length == 5){
                                setState(() {
                                  isSendingData = true;
                                });
                              
                                bool res = await AuthenticationService.verifyCode(data['user_id'], code);
                    
                                if(res){
                                  // Clear any existing tokens
                                  await FirebaseMessaging.instance.deleteToken();
                                  
                                  // Login with the user credentials after successful verification
                                  bool loginSuccess = await AuthenticationService.login(
                                    context,
                                    data['email'] ?? '',
                                    data['password'] ?? ''
                                  );

                                  if (loginSuccess) {
                                    // Set the home page as the current page
                                    locator<PageProvider>().setPage(PageNames.home);
                                    
                                    // Navigate to main page and clear all previous routes
                                    nextRoute(MainPage.pageName, isClearBackRoutes: true);
                                  } else {
                                    // If login fails after verification, show error and clear fields
                                    showSnackBar(ErrorEnum.error, 'Verification successful but login failed. Please try logging in manually.');
                                    clearVerificationFields();
                                  }
                                } else {
                                  // Show error dialog if verification fails
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
                                                'Verification Failed',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Invalid verification code. Please try again.',
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
                                                  clearVerificationFields();
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
                                
                                setState(() {
                                  isSendingData = false;
                                });
                              }
                            }
                          }, 
                          width: getSize().width, 
                          height: 52, 
                          text: appText.verifyMyAccount, 
                          bgColor: isEmptyInputs ? greyCF : green77(), 
                          textColor: Colors.white, 
                          borderColor: Colors.transparent,
                          isLoading: isSendingData
                        ),
                      ),

                      space(16),

                      Center(
                        child: Text(
                          appText.haventReceiveTheCode,
                          style: style14Regular().copyWith(color: greyB2),
                        ),
                      ),
                      
                      Center(
                        child: isCodeAgain
                      ? loading()
                      : GestureDetector(
                          onTap: () async {
                            _log('Attempting to resend verification code');
                            _log('User ID: ${data['user_id']}');
                            _log('Email/Phone: ${email ?? phone}');

                            setState(() {
                              isCodeAgain = true;
                            });

                            try {
                              Map? res = await AuthenticationService.register(
                                context,
                                data['registerMethod'] ?? '',
                                name ?? '',
                                email ?? '',
                                countryCode ?? '',
                                phone ?? '',
                                password ?? '',
                                retypePassword ?? '',
                                'user'
                              );

                              if(res != null && res['success']){
                                _log('Resend successful');
                                // Update user ID in case it changed
                                data['user_id'] = res['data']['user_id'];
                                controller1.clear();
                                controller2.clear();
                                controller3.clear();
                                controller4.clear();
                                controller5.clear();
                                showSnackBar(ErrorEnum.success, 'Verification code resent successfully');
                              } else {
                                _log('Resend failed');
                                showSnackBar(ErrorEnum.error, 'Failed to resend verification code');
                              }
                            } catch (e) {
                              _log('Resend error: $e');
                              showSnackBar(ErrorEnum.error, 'Error resending verification code');
                            }
                            
                            setState(() {
                              isCodeAgain = false;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            appText.resendCode,
                            style: style16Regular(),
                          ),
                        ),
                      ),
                    
                      const Spacer(),
                      const Spacer(),

                    ],
                  ),
                )
              )
            ],
          ),
        )
      ),
    );
  }

  void _log(String message) {
    dev.log(message, name: 'VerifyCodePage');
  }

  // Add this method to clear verification fields
  void clearVerificationFields() {
    controller1.clear();
    controller2.clear();
    controller3.clear();
    controller4.clear();
    controller5.clear();
    setState(() {
      isEmptyInputs = true;
    });
  }
}