import 'package:canteen/models/cart.dart';
import 'package:flutter/foundation.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Database {
  Future createUser(UserData user);
  Future updateUserInfo(Map userInfo, String email);
  Future getUserDoc(String email);
}

class DBService extends Database {
  static final db = FirebaseFirestore.instance;
  static final users = db.collection('users');
  static final menu = db.collection('menu');
  static final orders = db.collection('orders');
  static final activeOrders = db.collection('active_orders');
  @override
  Future<void> createUser(UserData user) async {
    await users.doc(user.email).set({
      'name': user.name,
      'email': user.email,
      'uid': user.uid,
      'password': Hashing.encrypt(user.password), //needs to be hashed
      'phone': user.phone,
      'type': user.type == UserType.student ? 'Student' : 'Faculty',
      'orders': [],
      "cart": {}, "fav_items": []
    });
  }

  @override
  Future<DocumentSnapshot> getUserDoc(String email) async {
    final result = await users.where('email', isEqualTo: email).limit(1).get();
    return result.docs.length != 0 ? result.docs[0] : null;
  }

  Future<DocumentSnapshot> getUserDocUsingEmail(String email) async {
    final result = await users.doc(email).get();
    return result;
  }

  @override
  Future<void> updateUserInfo(Map userInfo, String email) async {
    final userRef = db.collection('users').doc('email');
    await db.runTransaction((transaction) async {
      transaction.update(userRef, userInfo);
    });
  }

  Future<void> updateCart(String userEmail, Map<String, dynamic> items) async {
    await db.runTransaction((transaction) async =>
        transaction.update(users.doc(userEmail), {'cart': items}));
  }

  Future<void> placeOrder(
      {@required String userEmail,
      @required String username,
      @required Map<String, dynamic> items,
      @required double amount,
      @required PaymentType paymentType}) async {
    await db.runTransaction((transaction) async {
      transaction.set(activeOrders.doc(), {
        'bill': items,
        'total_amount': amount,
        'ordered_by': userEmail,
        'username': username,
        'status': 'placed',
        'payment_type': paymentType == PaymentType.cash ? 'cash' : 'digital',
        'payment_status': paymentType == PaymentType.cash ? 'pending' : 'paid',
        'placed_at': DateTime.now(),
      });
    });
  }
}

class Hashing {
  static final hasher = HashCrypt('SHA-3/512');
  static String encrypt(String text) => hasher.hash(text);
}
