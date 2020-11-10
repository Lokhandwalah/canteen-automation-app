import 'package:canteen/models/cart.dart';
import 'package:canteen/models/menu_items.dart';
import 'package:canteen/models/user.dart';
import 'package:canteen/screens/menu/home.dart';
import 'package:canteen/services/database.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:canteen/widgets/custom_button.dart';
import 'package:canteen/widgets/shimmer_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCart extends StatefulWidget {
  @override
  _MyCartState createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  Map<String, dynamic> items;
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final menu = Provider.of<Menu>(context);
    double total = 0;
    items = cart.items;
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
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    ...cart.itemList.map(
                      (itemName) {
                        MenuItem item = menu.menuItems[itemName];
                        total += (item.price * items[itemName]['quantity'])
                            .toDouble();
                        items[itemName]['price'] = item.price.toInt();
                        items[itemName].remove('id');
                        return MenuItemListTile(
                          item: item,
                          cart: cart,
                          insideCart: true,
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    BillDetails(total: total),
                    Center(child: MyButton(title: 'Place Order', action: () {}))
                  ],
                ),
              ),
      ),
    );
  }
}

class BillDetails extends StatefulWidget {
  const BillDetails({
    Key key,
    @required this.total,
  }) : super(key: key);

  final double total;

  @override
  _BillDetailsState createState() => _BillDetailsState();
}

class _BillDetailsState extends State<BillDetails> {
  double totalAmount;
  @override
  Widget build(BuildContext context) {
    totalAmount = widget.total + widget.total * 0.05 * 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        color: bg,
        elevation: 3,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bill Details:',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(
                thickness: 1.5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Sub Total',
                      style: TextStyle(color: primary),
                    ),
                    Spacer(),
                    Text('₹${widget.total}')
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'SGST',
                      style: TextStyle(color: primary),
                    ),
                    Spacer(),
                    Text('₹${widget.total * 0.05}')
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'CGST',
                      style: TextStyle(color: primary),
                    ),
                    Spacer(),
                    Text('₹${widget.total * 0.05}')
                  ],
                ),
              ),
              Divider(
                thickness: 1.5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(color: grey, fontSize: 15),
                    ),
                    Spacer(),
                    Text(
                      '₹$totalAmount',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double calculateTotal(Map<String, dynamic> items) {
  double total = 0;
  items.forEach((name, value) {
    total += items[name]['quantity'] * items[name]['price'];
  });
  return total;
}
