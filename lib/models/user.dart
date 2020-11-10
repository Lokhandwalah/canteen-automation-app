import 'package:canteen/models/cart.dart';
import 'package:canteen/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserType { student, faculty, guest }

class UserData {
  String name, password, email;
  String uid, phone;
  UserType type;
  UserData(
      {this.name, this.password, this.email, this.phone, this.type, this.uid});

  static Future<CurrentUser> setData(String email,
      [Map<String, dynamic> user]) async {
    if (user == null)
      user = (await DBService().getUserDocUsingEmail(email)).data();
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
    CurrentUser.user.clear();
  }
}

class CurrentUser extends UserData with ChangeNotifier {
  Cart cart;
  static CurrentUser user;
  static CurrentUser initialize(Map<String, dynamic> userDoc, SharedPreferences prefs) {
    print('setting data...');
    user = CurrentUser();
    user.name = userDoc['name'];
    user.email = userDoc['email'];
    user.phone = userDoc['phone'];
    user.cart = Cart(user: userDoc['email'], items: userDoc['cart'], prefs: prefs);
    return user;
  }

  void clear() {
    user = null;
  }
}
