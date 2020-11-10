import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Cart with ChangeNotifier {
  final String user;
  Map<String, dynamic> items = {};

  Cart({this.user, this.items});

  void addItem(MenuItem newItem) {
    if (items.containsKey(newItem.name))
      items.update(newItem.name,
          (oldItem) => {'id': newItem.id, 'quantity': oldItem['quantity'] + 1});
    else
      items.putIfAbsent(newItem.name, () => {'id': newItem.id, 'quantity': 1});
    notifyListeners();
  }

  void removeItem(MenuItem oldItem, {bool delete = false}) {
    if (delete || items[oldItem.name]['quantity'] == 1)
      items.remove(oldItem.name);
    else
      items.update(
          oldItem.name, (item) => {
            'id': item['id'],
            'quantity': item['quantity'] - 1});
    notifyListeners();
  }

  void removeAllItems() {
    items = {};
    notifyListeners();
  }

  List<String> get itemList => items.keys.toList();
}

class MenuItem {
  final DocumentSnapshot itemDoc;
  String name, category, imageUrl;
  int id;
  double price;
  bool isAvailable;

  MenuItem(this.itemDoc) {
    Map<String, dynamic> item = itemDoc.data();
    this.name = item['name'];
    this.id = item['id'];
    this.price = item['price'].toDouble();
    this.name = item['name'];
    this.category = item['category'];
    this.imageUrl = item['image_url'];
    this.isAvailable = item['isAvailable'];
  }

  String get displayName =>
      name.substring(0, 1).toUpperCase() + name.substring(1);
}
