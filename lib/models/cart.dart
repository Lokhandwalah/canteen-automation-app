import 'package:canteen/services/database.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'menu_items.dart';

class Cart with ChangeNotifier {
  final String user;
  final SharedPreferences prefs;
  Map<String, dynamic> items = {};
  Cart({this.user, this.items, this.prefs});

  void addItem(MenuItem newItem) {
    final itemName = newItem.name.toLowerCase();
    if (items.containsKey(itemName)) {
      items.update(itemName,
          (oldItem) => {'id': newItem.id, 'quantity': oldItem['quantity'] + 1});
    } else
      items.putIfAbsent(itemName, () => {'id': newItem.id, 'quantity': 1});
    prefs.setStringList('items', items.keys.toList());
    prefs.setInt(itemName, items[newItem.name]['quantity']);
    DBService().updateCart(user, items);
    notifyListeners();
  }

  void removeItem(MenuItem oldItem, {bool delete = false}) {
    if (delete || items[oldItem.name]['quantity'] == 1) {
      items.remove(oldItem.name);
      prefs.remove(oldItem.name);
    } else {
      items.update(oldItem.name,
          (item) => {'id': item['id'], 'quantity': item['quantity'] - 1});
      prefs.setInt(oldItem.name, items[oldItem.name]['quantity']);
    }
    prefs.setStringList('items', items.keys.toList());
    DBService().updateCart(user, items);
    notifyListeners();
  }

  void removeAllItems() {
    items = {};
    DBService().updateCart(user, items);
    notifyListeners();
  }

  List<String> get itemList => items.keys.toList();
}

enum PaymentType { digital, cash }
