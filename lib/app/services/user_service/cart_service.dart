import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webinar/app/models/cart_model.dart';
import 'package:webinar/app/models/checkout_model.dart';
import 'package:webinar/app/pages/main_page/home_page/subscription_page/subscription_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/error_handler.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/locator.dart';

import '../../../common/enums/error_enum.dart';
import '../../../common/utils/constants.dart';
import '../../../common/utils/http_handler.dart';
import '../../pages/main_page/home_page/cart_page/cart_page.dart';

class CartService {
  static Future<CartModel?> getCart() async {
    try {
      String url = '${Constants.baseUrl}panel/cart/list';

      Response res =
          await httpGetWithToken(url, isRedirectingStatusCode: false);

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success']) {
        locator<UserProvider>().setCartData(
            CartModel.fromJson(jsonResponse['data']?['cart'] ?? {}));
        return CartModel.fromJson(jsonResponse['data']?['cart'] ?? {});
      } else {
        ErrorHandler()
            .showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<String?> webCheckout() async {
    try {
      String url = '${Constants.baseUrl}panel/cart/web_checkout';

      Response res =
          await httpPostWithToken(url, {}, isRedirectingStatusCode: false);

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success']) {
        return jsonResponse['data']['link'];
      } else {
        ErrorHandler()
            .showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future validateCoupon(String coupon) async {
    try {
      String url = '${Constants.baseUrl}panel/cart/coupon/validate';

      Response res = await httpPostWithToken(url, {"coupon": coupon},
          isRedirectingStatusCode: false);

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success']) {
        return {
          'amount': Amounts.fromJson(jsonResponse['data']['amounts']),
          'discount_id': jsonResponse['data']['discount']['id']
        };
      } else {
        ErrorHandler()
            .showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<bool> store(int courseId, int ticketId) async {
    try {
      String url = '${Constants.baseUrl}panel/cart/store';

      Response res = await httpPostWithToken(url,
          {"webinar_id": courseId.toString(), "ticket_id": ticketId.toString()},
          isRedirectingStatusCode: false);

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success']) {
        getCart();
        showSnackBar(ErrorEnum.success, appText.successAddToCartDesc);
        return true;
      } else {
        ErrorHandler()
            .showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<dynamic> payRequest(int gatewayId, int orderId) async {
    try {
      String url = '${Constants.baseUrl}panel/payments/request';

      Response res = await httpPostWithToken(url,
          {"gateway_id": gatewayId.toString(), "order_id": orderId.toString()},
          isRedirectingStatusCode: false);

      var jsonResponse;
      try {
        jsonResponse = jsonDecode(res.body.toString());
      } catch (e) {}

      // ////printres.statusCode);
      ////printres.body);

      if (jsonResponse?['success'] ?? true) {
        return res.body;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<bool> credit(int orderId) async {
    try {
      String url = '${Constants.baseUrl}panel/payments/credit';

      Response res = await httpPostWithToken(
          url,
          {
            "order_id": orderId.toString(),
          },
          isRedirectingStatusCode: false);

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success']) {
        return true;
      } else {
        ErrorHandler()
            .showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> subscribeApplay(
      BuildContext context, int courseId) async {
    final String url = '${Constants.baseUrl}panel/subscribe/apply';

    try {
      final Response res = await httpPostWithToken(
        url,
        {"webinar_id": courseId.toString()},
        isRedirectingStatusCode: false,
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(res.body);
      print('Response: $jsonResponse'); // Debugging log

      if (jsonResponse['success'] == true) return true;

      // Alert message mapping
      final Map<String, dynamic> alertMessages = {
        'not_subscribable': {
          'title': "Not Allowed",
          'message': "This Course is not yet available for subscription.",
          'buttonText': "Browse Courses",
          'nextPage': MainPage(),
        },
        'no_active_subscribe': {
          'title': "No Active Plan",
          'message': "You don't have an active subscription plan!",
          'buttonText': "View Plans",
          'nextPage': SubscriptionPage(),
        }
      };

      if (alertMessages.containsKey(jsonResponse['status'])) {
        final alert = alertMessages[jsonResponse['status']]!;
        showCustomAlert(
          context,
          alert['title'],
          alert['message'],
          alert['buttonText'],
          alert['nextPage'],
        );
      } else {
        // Default error handling
        ErrorHandler()
            .showError(ErrorEnum.error, jsonResponse, readMessage: true);
      }
    } catch (e) {
      print('Error: $e'); // Log error
    }

    return false;
  }

// 🎨 Modern AlertDialog
  static void showCustomAlert(BuildContext context, String title,
      String message, String buttonText, Widget nextPage) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) => Dialog(
        backgroundColor:
            Colors.black.withOpacity(0.6), // Semi-transparent background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Primary Action Button (Green77)
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => nextPage),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: green77(),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(buttonText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Close Button (Top-Right Corner)
            Positioned(
              right: 8,
              top: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  color: Colors.black54,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool> add(BuildContext context, String itemId, String itemName,
      String? specifications) async {
    try {
      String url = '${Constants.baseUrl}panel/cart';

      Response res = await httpPostWithToken(
        url,
        {
          "item_id": itemId,
          "item_name": itemName,
          "specifications": specifications,
          "quantity": "1"
        },
        isRedirectingStatusCode: false,
      );

      var jsonResponse = jsonDecode(res.body);
      ////printjsonResponse);

      if (jsonResponse['success']) {
        getCart();
        showSnackBar(ErrorEnum.success, appText.successAddToCartDesc);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CartPage()),
        );
        return true;
      } else {
        if (jsonResponse['status'] == 'already_in_cart') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CartPage()),
          );
          showSnackBar(ErrorEnum.success, appText.alreadyInCart);
          return false;
        }
        if (jsonResponse['status'] == 'already_bought') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CartPage()),
          );
          showSnackBar(ErrorEnum.success, appText.alreadyBought);
          return false;
        } else {
          ErrorHandler()
              .showError(ErrorEnum.error, jsonResponse, readMessage: true);
          //print("Response: $jsonResponse");
          return false;
        }
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteCourse(int id) async {
    try {
      String url = '${Constants.baseUrl}panel/cart/$id';

      Response res =
          await httpDeleteWithToken(url, {}, isRedirectingStatusCode: false);

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success']) {
        return true;
      } else {
        ErrorHandler()
            .showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<CheckoutModel?> checkout() async {
    try {
      String url = '${Constants.baseUrl}panel/cart/checkout';

      Response res =
          await httpPostWithToken(url, {}, isRedirectingStatusCode: false);

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success']) {
        return CheckoutModel.fromJson(jsonResponse['data']);
      } else {
        ErrorHandler()
            .showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
