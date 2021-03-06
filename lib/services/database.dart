import 'package:canteen/models/cart.dart';
import 'package:canteen/models/menu_items.dart';
import 'package:flutter/foundation.dart';
import 'package:steel_crypt/steel_crypt.dart';
import '../models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Database {
  Future createUser(UserData user);
  Future updateUserInfo(Map userInfo, String email);
  Future findUserDoc(String email);
  Future getUserDoc(String email);
  Future updateCart(String userEmail, Map<String, dynamic> items);
  // Future updateFavItems(MenuItem item, CurrentUser user);
  Future placeOrder();
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
      'role': user.type == UserType.student ? 'student' : 'faculty',
      'orders': [],
      "cart": {}, "fav_items": []
    });
  }

  @override
  Future<DocumentSnapshot> findUserDoc(String email) async {
    final result = await users.where('email', isEqualTo: email).limit(1).get();
    return result.docs.length != 0 ? result.docs[0] : null;
  }

  @override
  Future<DocumentSnapshot> getUserDoc(String email) async {
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

  @override
  Future<void> updateFavItems(MenuItem item, String userEmail, bool isFav) async {
    await db
        .runTransaction((transaction) async => transaction.update(
              users.doc(userEmail),
              {
                'fav_items': isFav
                    ? FieldValue.arrayRemove([item.name])
                    : FieldValue.arrayUnion([item.name])
              },
            ))
        .catchError((e) => print("Error coocurred: " + e.toString()));
  }

  @override
  Future<void> updateCart(String userEmail, Map<String, dynamic> items) async {
    await db.runTransaction((transaction) async =>
        transaction.update(users.doc(userEmail), {'cart': items}));
  }

  @override
  Future<void> placeOrder(
      {@required String userEmail,
      @required String username,
      @required Map<String, dynamic> items,
      @required double amount,
      @required PaymentType paymentType,
      String paymentId}) async {
    await db.runTransaction((transaction) async {
      bool cashPayment = paymentType == PaymentType.cash;
      transaction.set(activeOrders.doc(), {
        'bill': items,
        'total_amount': amount,
        'ordered_by': userEmail,
        'username': username,
        'status': 'placed',
        'payment_type': cashPayment ? 'cash' : 'digital',
        'payment_status': cashPayment ? 'pending' : 'paid',
        if (!cashPayment) 'razorpay_payment_id': paymentId,
        'placed_at': DateTime.now(),
      });
    });
  }
}

class Hashing {
  static final hasher = HashCrypt('SHA-3/512');
  static String encrypt(String text) => hasher.hash(text);
}
