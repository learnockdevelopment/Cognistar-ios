import 'dart:async';
import 'dart:convert';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;
import 'package:webinar/app/pages/main_page/home_page/subscription_page/subscription_page%20copy.dart';
import 'package:webinar/app/widgets/main_widget/support_widget/support_widget.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:webinar/config/colors.dart';

class IAPService {
  static const String pageName = '/purchase';
  String productionURL = 'https://buy.itunes.apple.com/verifyReceipt';
  String sandboxURL = 'https://sandbox.itunes.apple.com/verifyReceipt';
  String url = '${Constants.baseUrl}panel/subscribe/get_order_for_apple';

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _isAvailable = false;
  List<ProductDetails> products = [];
  var susId;
  var susState;
  var susName;
  BuildContext? context;

  IAPService() {
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        //print("Error in purchase stream: $error");
      },
    );
  }

  Future<void> getSusId(var susId) async {
    this.susId = susId;
    //print("Subscribing with susId: $susId");
  }

  Future<void> getSusState(
      var susState, var susName, BuildContext context) async {
    this.susState = susState;
    this.susName = susName;
    this.context = context;

    //print("Subscribing with susState: $susState");
  }

  /// Initialize the in-app purchase service
  Future<void> initialize(String productId) async {
    try {
      _isAvailable = await _iap.isAvailable();
      if (!_isAvailable) {
        throw Exception('In-app purchases are not available on this device.');
      }

      final Set<String> productIdsSet = {productId};
      final response = await _iap.queryProductDetails(productIdsSet);

      if (response.error != null) {
        throw Exception('Error querying product details: ${response.error}');
      }

      if (response.productDetails.isEmpty) {
        throw Exception(
            'No product details found. Ensure the product is available.');
      } else {
        products = response.productDetails;
        //print('Products initialized successfully: ${products.map((p) => p.title).toList()}');
      }
    } catch (e) {
      //print('Initialization error: $e');
      rethrow;
    }
  }

  /// Handle purchase updates
  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          //print('Purchase pending...');
          break;
        case PurchaseStatus.error:
          //print('Purchase error: ${purchase.error?.message}');
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          //print('Purchase successful: ${purchase.purchaseID}');
          await validateReceipt(
              purchase.verificationData.serverVerificationData);
          await sendPurchaseDetailsToBackend();
          Navigator.pushReplacement(
            context!,
            MaterialPageRoute(builder: (context) => SubscriptionPage()),
          );

          break;
        default:
          break;
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> validateReceipt(String receipt) async {
    try {
      //print('Validating receipt...');
      final response = await http.post(
        Uri.parse(productionURL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'receipt-data': receipt}),
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['status'] == 21007) {
        //print('Using sandbox validation...');
        final sandboxResponse = await http.post(
          Uri.parse(sandboxURL),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'receipt-data': receipt}),
        );
        //print('Sandbox response: ${sandboxResponse.body}');
      } else {
        //print('Production validation response: ${response.body}');
      }
    } catch (e) {
      //print('Error during receipt validation: $e');
    }
  }

  static void showCustomAlert(
      BuildContext context, String title, String message, String buttonText) {
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
                        onPressed: () async {
                          Navigator.pop(context); // Close the dialog
                          await SupportWidget
                              .newSupportMessageSheet(); // Open the support sheet
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

  Future<void> buyConsumable(String productId, BuildContext context) async {
    try {
      if (susState != null) {
        showCustomAlert(
            context,
            "Subscription Error",
            "You are already subscribed to $susName. For further info, contact support.",
            "Contact Us");
        return;
      }

      final ProductDetails product =
          products.firstWhere((p) => p.id == productId);
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);

      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      // Handle error
    }
  }

  /// Send purchase details to the backend
  Future<void> sendPurchaseDetailsToBackend() async {
    try {
      String token = await AppData.getAccessToken();
      Map<String, String> headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
        "x-api-key": Constants.apiKey,
        "x-locale": "en",
      };
      //print(susId);
      Map<String, dynamic> details = {'subscribeId': susId};

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(details),
      );

      if (response.statusCode == 200) {
        //print('Purchase details successfully sent to the backend.');
      } else {
        //print( 'Failed to send purchase details. Status: ${response.statusCode}');
      }
    } catch (e) {
      //print('Error sending purchase details to backend: $e');
    }
  }
}