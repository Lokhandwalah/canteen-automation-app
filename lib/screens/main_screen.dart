import 'package:canteen/models/cart.dart';
import 'package:canteen/models/screen.dart';
import 'package:canteen/services/messaging.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:canteen/widgets/badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  DateTime currentBackPressTime;

  @override
  void initState() {
    super.initState();
    MessagingService.fbm.configure(
      onMessage: (message) async {
        print('onMessage: ' + message.toString());
      },
      onResume: (message) async {
        print('onResume: ' + message.toString());
      },
      onLaunch: (message) async {
        print('onLaunch: ' + message.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // StatusBar.color(_currentIndex == 1 ? white : primary);
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            backgroundColor: primary,
            currentIndex: _currentIndex,
            selectedItemColor: white,
            onTap: (index) => setState(() => _currentIndex = index),
            elevation: 10,
            type: BottomNavigationBarType.fixed,
            items: Screen.pages
                .map(
                  (p) => BottomNavigationBarItem(
                      icon: p.title == 'Cart'
                          ? Badge(
                              child: Icon(p.activeIcon),
                              no: Provider.of<Cart>(context).items.length,
                            )
                          : Icon(p.activeIcon),
                      activeIcon: Icon(p.icon),
                      label: p.title),
                )
                .toList()),
        body: IndexedStack(
          index: _currentIndex,
          children: Screen.pages.map((p) => p.page).toList(),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext ctx) async {
    if (_currentIndex == 0) {
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime) > Duration(seconds: 1)) {
        currentBackPressTime = now;
        Toast.show("Press back again to exit", ctx);
        return Future.value(false);
      }
      SystemNavigator.pop();
      return Future.value(true);
    } else {
      setState(() => _currentIndex = 0);
      return Future.value(false);
    }
  }
}
