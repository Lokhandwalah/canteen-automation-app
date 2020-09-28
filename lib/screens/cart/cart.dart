import 'package:canteen/models/user.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCart extends StatefulWidget {
  @override
  _MyCartState createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CurrentUser>(context);
    print(user.cart);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: user.cart.length == 0
            ? Container(
                alignment: Alignment.center,
                child: const Text(
                  'Your Cart is Empty',
                  style: TextStyle(color: primary, fontSize: 20),
                ))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: user.cart.keys
                    .map((item) => ListTile(
                          title: Text(
                            item,
                            style: TextStyle(color: primary, fontSize: 20),
                          ),
                          subtitle:
                              Text('Quantity: ${user.cart[item]['quantity']}'),
                          trailing: Text(
                            '${user.cart[item]['quantity']} x ${user.cart[item]['price']}',
                            style: TextStyle(color: primary, fontSize: 20),
                          ),
                        ))
                    .toList()),
      ),
    );
  }
}
