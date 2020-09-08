import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

// Color Scheme
const primary = Color(0xffFB7F89);
const secondary = Color(0xff707070);
const white = Color(0xffffffff);
const black = Color(0xff000000);

// Page Transition type
const leftToRight = PageTransitionType.leftToRightWithFade;
const rightToLeft = PageTransitionType.rightToLeftWithFade;

// PageRoute
Route goTo(Widget screen, [fullscreenDialog = false]) {
  if (Platform.isIOS)
    return CupertinoPageRoute(
        fullscreenDialog: fullscreenDialog, builder: (_) => screen);
  return MaterialPageRoute(
      fullscreenDialog: fullscreenDialog, builder: (_) => screen);
}

// Loader
Widget loader() => Platform.isIOS
    ? CupertinoActivityIndicator(radius: 20)
    : CircularProgressIndicator(strokeWidth: 2);
