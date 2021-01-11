import 'dart:async';

import 'package:canteen/models/cart.dart';
import 'package:canteen/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu_items.dart';

enum UserType { student, faculty, guest }

class UserData {
  String name, password, email, uid, phone;
  UserType type;
  UserData(
      {this.name, this.password, this.email, this.phone, this.type, this.uid});

  static Future<CurrentUser> setData(String email,
      [Map<String, dynamic> user]) async {
    if (user == null) user = (await DBService().getUserDoc(email)).data();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('setting prefs...');
    prefs.setString('name', user['name']);
    prefs.setString('email', user['email']);
    prefs.setString('phone', user['phone']);
    prefs.setString('type', user['type']);
    return CurrentUser.initialize(user, prefs);
  }

  static Future<void> resetData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('name');
    prefs.remove('email');
    prefs.remove('phone');
    prefs.remove('type');
  }
}

class CurrentUser extends UserData with ChangeNotifier {
  Cart cart;
  Set<MenuItem> favourites = {};
  Map<String, dynamic> userDoc;
  static StreamSubscription userDocStream;
  static CurrentUser initialize(
      Map<String, dynamic> userDoc, SharedPreferences prefs) {
    print('setting data...');
    CurrentUser user = CurrentUser();
    user.userDoc = userDoc;
    user.name = userDoc['name'];
    user.email = userDoc['email'];
    user.phone = userDoc['phone'];
    user.cart =
        Cart(user: userDoc['email'], items: userDoc['cart'], prefs: prefs);
    List favs = userDoc['fav_items'];
    favs.forEach(
        (itemName) => user.favourites.add(Menu.menu.menuItems[itemName]));
    userDocStream =
        DBService.users.doc(user.email).snapshots().listen(user.updateUser);
    return user;
  }

  void updateUser(DocumentSnapshot userDoc) {
    favourites.clear();
    List favs = userDoc.data()['fav_items'];
    favs.forEach((itemName) =>
        favourites.add(Menu.menu.menuItems[itemName.trim()]));
    notifyListeners();
  }

  void clear() {
    userDocStream.cancel();
  }
}
