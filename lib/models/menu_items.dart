import 'dart:async';

import 'package:canteen/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class MenuItem {
  final DocumentSnapshot itemDoc;
  String name, category, imageUrl;
  int id;
  double price;
  bool isAvailable;
  MenuItem(this.itemDoc) {
    Map<String, dynamic> item = itemDoc.data();
    this.name = item['name'].toString().toLowerCase();
    this.id = item['id'];
    this.price = double.parse(item['price'].toString());
    this.category = item['category'];
    this.imageUrl = item['image_url'];
    this.isAvailable = item['isAvailable'];
  }

  String displayName() {
    return this.name.substring(0, 1).toUpperCase() + name.substring(1);
  }
}

class Menu with ChangeNotifier {
  Map<String, MenuItem> menuItems = {};
  static Menu menu = Menu();
  Future<void> initialize({List<MenuItem> itemList}) async {
    await DBService.menu.get().then(onData);
    DBService.menu.snapshots().listen(onData);
  }

  onData(QuerySnapshot snapshot) {
    print('adding items...');
    snapshot.docs.forEach(
      (doc) => menu.menuItems.update(
        doc.data()['name'].toString().toLowerCase(),
        (_) => MenuItem(doc),
        ifAbsent: () => MenuItem(doc),
      ),
    );
    notifyListeners();
  }

  List<MenuItem> get itemList => menu.menuItems.values.toList();
}
