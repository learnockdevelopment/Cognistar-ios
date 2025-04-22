import 'package:flutter/material.dart';

import '../guest_service/guest_service.dart';

class ApiDataProvider with ChangeNotifier {
  bool canPurchase = false;

  // Add the fetchPurchase method to load the data
  Future<void> fetchPurchase() async {
    try {
      var apiResponse = await GuestService.systemsettings();
      if (apiResponse is Map && apiResponse.containsKey('data')) {
        var data = apiResponse['data'];
        if (data.containsKey('general_settings')) {
          var securitySettings = data['general_settings'];
          if (securitySettings.containsKey('can_buy')) {
            // Check the actual type of 'can_buy' before comparing
            if (securitySettings['can_buy'] != null) {
              canPurchase = (securitySettings['can_buy'] == '1');
              notifyListeners(); // Notify listeners to update UI
            }
          }
        }
      }
    } catch (e) {
      // Handle errors if needed
      print("Error: $e");
    }
  }
}
