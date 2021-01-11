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

// funtion for Loader
void showLoader(BuildContext context, {bool canPop = false}) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () => Future.value(canPop),
        child: Center(child: loader()),
      ),
    );

// Loader
Widget loader() => Platform.isIOS
    ? CupertinoActivityIndicator(radius: 20)
    : CircularProgressIndicator(strokeWidth: 2);

//slider imageList
List<String> imageList() => [
      'https://www.thespruceeats.com/thmb/XDmwhz9HXEMxhus08YhlIvTuAZI=/3865x2174/smart/filters:no_upscale()/paneer-makhani-or-shahi-paneer-indian-food-670906899-5878ef725f9b584db3d890f4.jpg',
      'https://media.cntraveller.in/wp-content/uploads/2020/05/dosa-recipes-866x487.jpg',
      'https://www.loveandoliveoil.com/wp-content/uploads/2015/03/soy-sauce-noodlesH2.jpg',
      'https://cdn.cdnparenting.com/articles/2020/02/26144447/PULAV.jpg'
    ];

String capitalize(String name) {
  List words = name.split(' ');
  if (words.length == 1)
    return words.first.substring(0, 1).toUpperCase() + words.first.substring(1);
  else {
    String name = '';
    words.forEach((words) =>
        name += words.substring(0, 1).toUpperCase() + words.substring(1) + " ");
    return name;
  }
}
