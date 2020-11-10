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

class Menu with ChangeNotifier {
  Map<String, MenuItem> menuItems = {};
  Future<void> initialize({List<MenuItem> itemList}) async {
    await DBService.menu.get().then(onData);
    DBService.menu.snapshots().listen(onData);
  }

  onData(QuerySnapshot snapshot) {
    print('adding items...');
    snapshot.docs.forEach(
      (doc) => menuItems.update(
        doc.data()['name'],
        (_) => MenuItem(doc),
        ifAbsent: () => MenuItem(doc),
      ),
    );
    notifyListeners();
  }

  List<MenuItem> get itemList => menuItems.values.toList();
}
