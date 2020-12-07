import 'dart:async';

import 'package:canteen/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class MenuItem {
  final DocumentSnapshot itemDoc;
  String name, category, imageUrl, id;
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
    List words = this.name.split(' ');
    if (words.length == 1)
      return words.first.substring(0, 1).toUpperCase() +
          words.first.substring(1);
    else {
      String name = '';
      words.forEach((words) => name +=
          words.substring(0, 1).toUpperCase() + words.substring(1) + " ");
      return name;
    }
  }
}

class Menu with ChangeNotifier {
  Map<String, MenuItem> menuItems = {};
  StreamSubscription<QuerySnapshot> updates;
  static Menu menu = Menu();
  Future<void> initialize({List<MenuItem> itemList}) async {
    await DBService.menu.get().then(onData);
    updates = updateStream;
  }

  get updateStream => DBService.menu.snapshots().listen(onData);

  void onData(QuerySnapshot snapshot) {
    print('adding items...');
    menu.menuItems.clear();
    snapshot.docs.forEach((doc) {
      try {
        menu.menuItems.putIfAbsent(
          doc.data()['name'].toString().toLowerCase(),
          () => MenuItem(doc),
        );
      } catch (e) {
        print('Error: ' + e.toString());
        print(doc.data());
      }
    });
    menu.notifyListeners();
  }

  List<MenuItem> get itemList => menu.menuItems.values.toList();
  void cancel() => updates.cancel();
}
