import 'package:canteen/models/order.dart';
import 'package:canteen/models/user.dart';
import 'package:canteen/services/database.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CurrentUser>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildActiveOrders(user),
          Expanded(child: _buildRecentOrders(user)),
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot> _buildRecentOrders(CurrentUser user) {
    return StreamBuilder<QuerySnapshot>(
      stream: DBService.orders
          .where('ordered_by', isEqualTo: user.email)
          .orderBy('placed_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return loader();
        List<Order> orders =
            snapshot.data.docs.map((doc) => Order.fromDoc(doc)).toList();
        return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              Order order = orders[i];
              bool delivered = order.status == OrderStatus.delivered;
              return Card(
                color: bg,
                elevation: 3,
                shadowColor: Colors.grey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.fastfood_outlined,
                        color: primary,
                        size: 25,
                      ),
                      title: FittedBox(child: Text('Order: ${order.id}')),
                      trailing: Text(
                        delivered ? 'Delivered' : 'Cancelled',
                        style: TextStyle(
                            color: delivered ? Colors.green : Colors.red),
                      ),
                    ),
                    buildDetail('Items', order.itemString),
                    buildDetail('Ordered on', order.timestamp),
                    buildDetail(
                        'Total Amount', '₹' + order.totalAmount.toString())
                  ],
                ),
              );
            });
      },
    );
  }

  StreamBuilder<QuerySnapshot> _buildActiveOrders(CurrentUser user) {
    return StreamBuilder<QuerySnapshot>(
      stream: DBService.activeOrders
          .where('ordered_by', isEqualTo: user.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return loader();
        List<Order> orders =
            snapshot.data.docs.map((doc) => Order.fromDoc(doc)).toList();
        return Container(
          height: 200,
          child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: orders.length,
              itemBuilder: (_, i) {
                Order order = orders[i];
                return Card(
                  color: bg,
                  elevation: 3,
                  shadowColor: Colors.grey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.fastfood_outlined,
                          color: primary,
                          size: 25,
                        ),
                        title: FittedBox(child: Text('Order: ${order.id}')),
                        trailing: Text(
                          capitalize(order.statusString),
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                      buildDetail('Items', order.itemString),
                      buildDetail('Ordered on', order.timestamp),
                      buildDetail(
                          'Total Amount', '₹' + order.totalAmount.toString())
                    ],
                  ),
                );
              }),
        );
      },
    );
  }

  Container buildDetail(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title + ':',
            style: TextStyle(color: primary),
          ),
          SizedBox(height: 4),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
