import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/colors.dart';

import '../../../common/components.dart';
import '../../../config/assets.dart';
import '../../../config/styles.dart';
import '../authentication_page/login_page.dart';
import '../authentication_page/register_page.dart';

class IntroPage extends StatefulWidget {
  static const String pageName = '/intro';
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  PageController pageController = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    AppData.saveIsFirst(false);
  }

  Widget buildIntroPage(String imagePath, String title, String desc, {int page = 1}) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image: $error');
              return Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, color: Colors.black, size: 40),
                    space(10),
                    Text(
                      'Image not found',
                      style: style16Regular().copyWith(color: Colors.black),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Content
        Positioned.fill(
          child: Padding(
            padding: padding(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                space(getSize().height * .35),
                
                Text(
                  title,
                  style: style24Bold().copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
        
                space(16),
                
                Padding(
                  padding: padding(horizontal: 40),
                  child: Text(
                    desc,
                    style: style16Regular().copyWith(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),


              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: PageView(
                controller: pageController,
                onPageChanged: (i) {
                  setState(() {
                    currentPage = i;
                  });
                },
                physics: const CustomPageViewScrollPhysics(),
                children: [
                  // First Page
                  buildIntroPage(
                    AppAssets.intro1Png,
                    appText.introTitle1,
                    appText.introDesc1,
                    page: 1,
                  ),
                  
                  // Second Page
                  buildIntroPage(
                    AppAssets.intro3Png,
                    appText.introTitle2,
                    appText.introDesc2,
                    page: 2,
                  ),
                  
                  // Third Page
                  buildIntroPage(
                    AppAssets.intro2Png,
                    appText.introTitle3,
                    appText.introDesc3,
                    page: 3,
                  ),
                ],
              )
            ),

            Positioned(
              bottom: 20,
              right: 30,
              left: 30,
              child: Column(
                children: [
                  // indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: padding(horizontal: 1.5),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentPage == index ? Colors.black : Colors.black.withOpacity(.6)
                        ),
                      );
                    }),
                  ),

                  space(20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      button(
                        onTap: () {
                          nextRoute(MainPage.pageName, isClearBackRoutes: true);
                        },
                        width: 80,
                        height: 44,
                        text: appText.skip,
                        bgColor: Colors.transparent,
                        textColor: Colors.black,
                        raduis: 12,
                        fontSize: 16,
                      ),

                      button(
                        onTap: () {
                          if (currentPage == 2) {
                            nextRoute(MainPage.pageName, isClearBackRoutes: true);
                          } else {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.linearToEaseOut
                            );
                          }
                        },
                        width: 80,
                        height: 44,
                        text: appText.next,
                        bgColor: Colors.transparent,
                        textColor: Colors.black,
                        raduis: 12,
                        fontSize: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}