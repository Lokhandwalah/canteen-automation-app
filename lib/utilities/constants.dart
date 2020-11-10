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
const grey = Color(0xff303030);

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

// image slider photo urls
List<String> imageList = [
  'https://www.thespruceeats.com/thmb/XDmwhz9HXEMxhus08YhlIvTuAZI=/3865x2174/smart/filters:no_upscale()/paneer-makhani-or-shahi-paneer-indian-food-670906899-5878ef725f9b584db3d890f4.jpg',
  ];

String capitalize(String name) =>
    name.substring(0, 1).toUpperCase() + name.substring(1);