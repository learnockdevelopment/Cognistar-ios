import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/home_page/notification_page.dart';
import 'package:webinar/app/pages/main_page/home_page/search_page/suggested_search_page.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/common/components.dart';

import '../../../../common/common.dart';
import '../../../../common/enums/error_enum.dart';
import '../../../../common/utils/app_text.dart';
import '../../../../config/assets.dart';
import '../../../../config/colors.dart';
import '../../../../config/styles.dart';
import '../../../pages/authentication_page/login_page.dart';
import '../../../pages/main_page/home_page/cart_page/cart_page.dart';
import '../main_widget.dart';

class HomeWidget {


  static Widget titleAndMore(String title,
      {bool isViewAll = true, Function? onTapViewAll}) {
    return Padding(
      padding: padding(vertical: 16),
      child: Row(
        children: [
          Text(
            title,
            style: style20Bold(),
          ),
          const Spacer(),
          if (isViewAll) ...{
            GestureDetector(
              onTap: () {
                if (onTapViewAll != null) {
                  onTapViewAll();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Text(
                appText.viewAll,
                style: style14Regular().copyWith(color: greyA5),
              ),
            )
          }
        ],
      ),
    );
  }

  static Future showFinalizeRegister(int userId) async {
    TextEditingController nameController = TextEditingController();
    FocusNode nameNode = FocusNode();


    bool isLoading = false;

    return await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: navigatorKey.currentContext!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  directionality(
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(navigatorKey.currentContext!)
                              .viewInsets
                              .bottom),
                      width: getSize().width,
                      padding: padding(vertical: 21),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appText.finalizeYourAccount,
                            style: style16Bold(),
                          ),
                          space(16),
                          input(nameController, nameNode, appText.yourName,
                              iconPathLeft: AppAssets.profileSvg,
                              leftIconSize: 14,
                              isBorder: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
