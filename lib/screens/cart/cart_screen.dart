import 'package:canteen/models/cart.dart';
import 'package:canteen/models/user.dart';
import 'package:canteen/screens/menu/home.dart';
import 'package:canteen/services/database.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:canteen/widgets/shimmer_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class MyCart extends StatefulWidget {
  @override
  _MyCartState createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Cart'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: cart.items.length == 0
              ? Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Your Cart is Empty',
                    style: TextStyle(color: primary, fontSize: 20),
                  ))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cart.itemList.map((itemName) {
                    return StreamBuilder<DocumentSnapshot>(
                        stream: DBService.menu.doc(itemName).snapshots(),
                        builder: (context, snapshot) {
                          // var item = user.cart.items[itemName];
                          if (!snapshot.hasData) return ShimmerListTile();
                          MenuItem item = MenuItem(snapshot.data);
                          int quantity = cart.items[itemName]['quantity'];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(item.imageUrl),
                            ),
                            title: Text(
                              item.displayName,
                              style: TextStyle(color: primary, fontSize: 20),
                            ),
                            subtitle: Text('Quantity: $quantity'),
                            trailing: ActionButtons(cart: cart, item: item)
                          );
                        });
                  }).toList(),
                ),
        ));
  }
}

