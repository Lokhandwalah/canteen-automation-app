import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../screens/account/account.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/menu/home.dart';

class Screen {
  final IconData icon, activeIcon;
  final String title, route;
  final Widget page;
  final int index;
  Screen(
      {this.icon,
      this.activeIcon,
      this.title,
      this.page,
      this.index,
      this.route});
  static final List<Screen> pages = [
    Screen(
      index: 0,
      title: 'Order',
      icon: Icons.fastfood,
      activeIcon: Icons.fastfood,
      page: HomeScreen(),
    ),
    Screen(
      index: 1,
      title: 'Cart',
      icon: FontAwesome.shopping_bag,
      activeIcon: FontAwesome.shopping_bag,
      page: MyCart(),
    ),
    Screen(
      index: 2,
      title: 'Account',
      icon: Icons.person,
      activeIcon: Icons.account_circle,
      page: MyAccount(),
    )
  ];
}
