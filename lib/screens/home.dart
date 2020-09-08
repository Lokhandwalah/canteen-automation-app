import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

import '../models/screen.dart';
import '../utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:statusbar/statusbar.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  DateTime currentBackPressTime;
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
                      icon: Icon(p.icon),
                      activeIcon: Icon(p.activeIcon),
                      title: Text(p.title)),
                )
                .toList()),
        body: IndexedStack(
          index: _currentIndex,
          children: Screen.pages.map((p) => p.page).toList(),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
    );
  }
}
