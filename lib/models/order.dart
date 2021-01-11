import 'package:canteen/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Order {
  final DocumentSnapshot orderDoc;
  String id,
      statusString,
      orderedBy,
      username,
      paymentStatus,
      paymentType,
      rzpOrderId,
      rzpPaymentId;
  DateTime placedAt, deliveredAt, cancelledAt;
  Map<String, dynamic> bill;
  List items;
  OrderStatus status;
  double totalAmount;

  Order(
      {this.orderDoc,
      this.orderedBy,
      this.username,
      this.bill,
      this.placedAt,
      this.statusString,
      this.status = OrderStatus.placed,
      this.totalAmount});

  Order.fromDoc(this.orderDoc) {
    Map<String, dynamic> order = orderDoc.data();
    this.id = orderDoc.id;
    this.orderedBy = order['ordered_by'];
    this.username = order['username'];
    this.bill = order['bill'];
    this.items = bill.keys.toList();
    this.placedAt = order['placed_at'].toDate();
    this.statusString = order['status'];
    this.status = getStatus(order['status']);
    // status == OrderStatus.delivered
    //     ? this.deliveredAt = order['delivered_at'].toDate()
    //     : this.cancelledAt = order['cancelled_at'].toDate();
    this.totalAmount = order['total_amount'].toDouble();
  }

  String get itemString => items
      .map((item) =>
          bill[item]['quantity'].toString() + ' x ' + capitalize(item))
      .toList()
      .join(", ");

  String get timestamp =>
      DateFormat('dd MMM yyyy ').format(this.placedAt) +
      'at' +
      DateFormat(' hh:mm a').format(this.placedAt);

  OrderStatus getStatus(String status) {
    OrderStatus orderStatus;
    switch (status.trim()) {
      case 'placed':
        orderStatus = OrderStatus.placed;
        break;
      case 'processing':
        orderStatus = OrderStatus.processing;
        break;
      case 'complete':
        orderStatus = OrderStatus.completed;
        break;
      case 'delivered':
        orderStatus = OrderStatus.delivered;
        break;
      case 'cancelled':
        orderStatus = OrderStatus.cancelled;
        break;
    }
    return orderStatus;
  }
}

enum OrderStatus { placed, processing, completed, delivered, cancelled }
