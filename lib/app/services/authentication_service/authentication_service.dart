import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/common/utils/error_handler.dart';
import 'package:webinar/common/utils/http_handler.dart';
import 'package:http/http.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:webinar/config/assets.dart';
import '../../../common/utils/app_text.dart';
import '../../../config/colors.dart';

class AuthenticationService {

  static Future<bool> login(
      BuildContext context, String username, String password) async {
    // Validate email

    bool isValidEmail = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(username);
    if (!isValidEmail) {
      _showErrorDialog(context, {
        'title': 'Invalid Email',
        'message': 'Please enter a valid email address.',
      });
      return false;
    }

    // Validate password
    if (password.length < 6) {
      _showErrorDialog(context, {
        'title': 'Weak Password',
        'message': 'Password must be at least 6 characters long.',
      });
      return false;
    }

    try {
      String url = '${Constants.baseUrl}login';
      String deviceId = await getDeviceId();

      // Show loading indicator
      _showLoadingDialog(context, "Logging in...");

      // Make the API call
      Response res = await httpPost(url, {
        'username': username,
        'password': password,
        'device_id': deviceId,
      });

      if (Navigator.canPop(context)) Navigator.pop(context);

      log('Response Status: ${res.statusCode}');
      log('Response Body: ${res.body}');

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success']) {
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        int userId = jsonResponse['data']['user_id'];
        await AppData.saveUserId(userId);
        return true;
      } else if (jsonResponse['status'] == 'incorrect') {
        _showErrorDialog(context, {
          'title': 'Login Failed',
          'message': 'Invalid email or password. Please try again.',
        });
      } else if (jsonResponse['status'] == 'device_mismatch') {
        _showErrorDialog(context, {
          'title': 'Device Mismatch',
          'message': 'This device is not allowed to log in.',
        });
      } else {
        _showErrorDialog(context, {
          'title': 'Login Failed',
          'message': jsonResponse['message'] ?? 'Unable to login.',
        });
      }

      return false;
    } on SocketException catch (_) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      _showErrorDialog(context, {
        'title': 'No Network',
        'message': 'Please check your internet connection and try again.',
      });
      return false;
    } on TimeoutException catch (_) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      _showErrorDialog(context, {
        'title': 'Timeout',
        'message': 'The request timed out. Please try again later.',
      });
      return false;
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      log('Unexpected error: $e');
      _showErrorDialog(context, {
        'title': 'Error',
        'message': 'Unexpected error: $e',
      });

      return false;
    }

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

  static void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.rtl,
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
                  // App Logo
                  Image.asset(AppAssets.logoPng, width: 90, height: 90),

                  SizedBox(height: 20),

                  // White Circular Progress Indicator
                  SpinKitThreeBounce(
                    color: primaryColor,
                    size: 15.0,
                  ),
                  SizedBox(height: 20),

                  // Loading Text
                  Text(
                    appText.mayTakeSeconds,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                      Colors.black, // ✅ Black text for better readability
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  static Future<bool> google(
      BuildContext context, String email, String token, String name) async {
    try {
      String url = '${Constants.baseUrl}google/callback';
      String deviceId = await getDeviceId();
      String deviceType = Platform.isAndroid
          ? 'Android'
          : Platform.isIOS
          ? 'iOS'
          : 'Web'; // Adjust according to your platform needs
      // Prepare the request body
      Map<String, String> body = {
        'email': email,
        'name': name,
        'id': token,
        'device_id': deviceId,
        'device_type': deviceType,
      };

      // Make the HTTP POST request
      Response res = await httpPost(url, body);

      // Close the loading dialog after receiving the response
      // log('Response Status: ${res.statusCode}');
      // log('Response Body: ${res.body}');
      var responseData = jsonDecode(res.body);

      // Check if login failed due to device mismatch
      if (responseData['success'] == false &&
          responseData['status'] == 'device_mismatch') {
        _showErrorDialog(context, responseData); // Show the error dialog
        return false; // Prevent login
      }

      // Check for a successful login (status code 200)
      if (res.statusCode == 200) {
        // Save the token and user_id (from response) for later use
        await AppData.saveAccessToken(responseData['data']['token']);
        int userId = responseData['data']
        ['user_id']; // Assuming response contains 'user_id'
        log('User ID: $userId');

        // Store user_id in persistent storage
        await AppData.saveUserId(userId);

        return true;
      } else {
        // Handle failed login
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // static Future<bool> facebook(BuildContext context, String email, String token,
  //     String name) async {
  //   try {
  //     String url = '${Constants.baseUrl}facebook/callback';
  //     String deviceId = await getDeviceId();

  //     Response res = await httpPost(
  //       url,
  //       {
  //         'id': token,
  //         'name': name,
  //         'email': email,
  //         'device_id': deviceId, // Include Device ID in the body
  //       },
  //     );

  //     var jsonResponse = jsonDecode(res.body); // Decode the response body

  //     // Check for a device mismatch error
  //     if (jsonResponse['success'] == false &&
  //         jsonResponse['status'] == 'device_mismatch') {
  //       _showErrorDialog(context, jsonResponse); // Show the error dialog
  //       return false; // Prevent login
  //     }

  //     // Check for a successful login
  //     if (jsonResponse['success']) {
  //       await AppData.saveAccessToken(jsonResponse['data']['token']);
  //       return true;
  //     } else {
  //       // Handle other errors
  //       _showErrorDialog(context, jsonResponse); // Show the error dialog
  //       return false;
  //     }
  //   } catch (e) {
  //     // You might want to log the error or show a different dialog
  //     _showErrorDialog(context, {'message': 'An unexpected error occurred.'});
  //     return false;
  //   }
  // }

  static Future<Map?> registerWithEmail(
      String registerMethod,
      String email,
      String password,
      String repeatPassword,
      String? accountType,
      List<Fields>? fields) async {
    try {
      String url = '${Constants.baseUrl}register/step/1';

      Map body = {
        "register_method": registerMethod,
        "country_code": null,
        'email': email,
        'password': password,
        'password_confirmation': repeatPassword,
      };

      if (fields != null) {
        Map bodyFields = {};
        for (var i = 0; i < fields.length; i++) {
          if (fields[i].type != 'upload') {
            bodyFields.addEntries({
              fields[i].id: (fields[i].type == 'toggle')
                  ? fields[i].userSelectedData == null
                  ? 0
                  : 1
                  : fields[i].userSelectedData
            }.entries);
          }
        }

        body.addEntries({'fields': bodyFields.toString()}.entries);
      }

      Response res = await httpPost(url, body);

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success'] ||
          jsonResponse['status'] == 'go_step_2' ||
          jsonResponse['status'] == 'go_step_3') {
        return {
          'user_id': jsonResponse['data']['user_id'],
          'step': jsonResponse['status']
        };
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Map?> registerWithPhone(
      String registerMethod,
      String countryCode,
      String mobile,
      String password,
      String repeatPassword,
      String? accountType,
      List<Fields>? fields) async {
    // try{
    String url = '${Constants.baseUrl}register/step/1';

    Map body = {
      "register_method": registerMethod,
      "country_code": countryCode,
      'mobile': mobile,
      'password': password,
      'password_confirmation': repeatPassword,
    };

    if (fields != null) {
      Map bodyFields = {};
      for (var i = 0; i < fields.length; i++) {
        if (fields[i].type != 'upload') {
          bodyFields.addEntries({
            fields[i].id: (fields[i].type == 'toggle')
                ? fields[i].userSelectedData == null
                ? 0
                : 1
                : fields[i].userSelectedData
          }.entries);
        }
      }

      body.addEntries({'fields': bodyFields.toString()}.entries);
    }

    Response res = await httpPost(url, body);

    ////printres.body);

    var jsonResponse = jsonDecode(res.body);
    if (jsonResponse['success'] ||
        jsonResponse['status'] == 'go_step_2' ||
        jsonResponse['status'] == 'go_step_3') {
      // || stored

      return {
        'user_id': jsonResponse['data']['user_id'],
        'step': jsonResponse['status']
      };
    } else {
      ErrorHandler().showError(ErrorEnum.error, jsonResponse);
      return null;
    }

    // }catch(e){
    //   return null;
    // }
  }

  static Future<bool> forgetPassword(String email) async {
    try {
      String url = '${Constants.baseUrl}forget-password';

      Response res = await httpPost(url, {"email": email});

      // log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        ErrorHandler()
            .showError(ErrorEnum.success, jsonResponse, readMessage: true);
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> verifyCode(int userId, String code) async {
    try {
      String url = '${Constants.baseUrl}register/step/2';

      Response res = await httpPost(url, {
        "user_id": userId.toString(),
        "code": code,
      });

      // log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> registerStep3(
      int userId, String name, String referralCode) async {
    try {
      String url = '${Constants.baseUrl}register/step/3';

      Response res = await httpPost(url, {
        "user_id": userId.toString(),
        "full_name": name,
        "referral_code": referralCode
      });

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        await AppData.saveName(name);
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Unique Android ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ??
          'Unknown Device ID'; // Unique iOS ID
    } else {
      return 'Unknown Device ID'; // Fallback for other platforms
    }
  }
}