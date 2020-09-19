import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

// Color Scheme
const primary = Color(0xffea8b26);
const secondary = Color(0xfff7dd6f);
const bg = Color(0xffe6dbc8);
const white = Color(0xffffffff);
const black = Color(0xff000000);

// #ea8b26
// #f7dd6f
// #e6dbc8

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
