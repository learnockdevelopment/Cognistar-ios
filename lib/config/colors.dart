import 'package:flutter/material.dart';

// Background colors
Color? backgroundColor = Colors.grey[200];

// Primary colors
const Color primaryColor = Color.fromARGB(255, 8, 148, 255); // Example: Blue
const Color primaryColor2 = Color(0xffcfe9f8); // Light
const Color secondaryColor = Color(0xff3ec0c4); // Example: Green

// Text colors
const Color textPrimaryColor = Color(0xFFD2E0FB); // FOR DARK BACKGROUND
const Color textSecondaryColor = Color(0xFF001F3F); // FOR LIGHT BACKGROUND

/// Main Color
Color green77() => Color.fromARGB(255, 8, 148, 255);
Color green91() => const Color(0xff9EFFC1);
Color blue64() => const Color(0xff1F3B64);
LinearGradient greenGradint() => LinearGradient(
    colors: [green77(), green91()],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter);

// use in drawer background color
Color green63 = const Color(0xffc100ae);

// grey Shade
Color grey33 = const Color(0xff2F3133);
Color grey3A = const Color(0xff1D2D3A);
Color grey5E = const Color(0xff5E5E5E);
Color greyD0 = const Color(0xffABB7D0);
Color greyB2 = const Color(0xffA9AEB2);
Color greyA5 = const Color(0xffA5A5A5);
Color greyCF = const Color(0xffCFCFCF);
Color greyE7 = const Color(0xffE7E7E7);
Color greyF8 = const Color(0xffF8F8F8);
Color greyFA = const Color(0xffFAFAFA);
LinearGradient greyGradint = LinearGradient(colors: [
  Colors.black.withOpacity(.8),
  Colors.black.withOpacity(0),
], begin: Alignment.bottomCenter, end: Alignment.topCenter);

// Semantics
Color red49 = const Color(0xffFF4949);
Color yellow29 = const Color(0xffFFC529);
Color orange50 = const Color(0xffFE7950);

// Semantics
Color green50 = const Color(0xff8FBF50);
Color green4B = const Color(0xff218F48);
Color green9D = const Color(0xff50BF9D);

Color cyan50 = const Color(0xff50BF9D);
Color blueFE = const Color(0xff5090FE);
Color blueA4 = const Color(0xff2849A4);
Color yellow4C = const Color(0xffFFCD4C);

// Shadow
BoxShadow boxShadow(Color color, {int blur = 20, int y = 8, int x = 0}) {
  return BoxShadow(
      color: color,
      blurRadius: blur.toDouble(),
      offset: Offset(x.toDouble(), y.toDouble()));
}
