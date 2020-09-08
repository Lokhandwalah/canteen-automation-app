import '../models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Database {
  Future createUser(UserData user, bool verified);
  Future updateUserInfo(Map userInfo, String email);
  Future getUserDoc(String email);
}

class DBService extends Database {
  static final db = FirebaseFirestore.instance;
  final userCollection = db.collection('users');
  @override
  Future<void> createUser(UserData user, bool verified) async {
    await userCollection.doc(user.email).set({
      'name': user.name,
      'email': user.email,
      'password': user.password, //needs to be hashed
      'phone': null,
      'orders': [],
      "cart": {}, "fav_items": []
    });
  }

  @override
  Future<DocumentSnapshot> getUserDoc(String email) async {
    final doc = await userCollection.doc(email).get();
    return doc;
  }

  @override
  Future<void> updateUserInfo(Map userInfo, String email) async {
    final userRef = db.collection('users').doc('email');
    await db.runTransaction((transaction) async {
      transaction.update(userRef, userInfo);
    });
  }
}
