import '../models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Database {
  Future createUser(UserData user);
  Future updateUserInfo(Map userInfo, String email);
  Future getUserDoc(String email);
}

class DBService extends Database {
  static final db = FirebaseFirestore.instance;
  final userCollection = db.collection('users');
  @override
  Future<void> createUser(UserData user) async {
    await userCollection.doc(user.email).set({
      'name': user.name,
      'email': user.email,
      'uid': user.uid,
      'password': user.password, //needs to be hashed
      'phone': user.phone,
      'type': user.type == UserType.student ? 'Student' : 'Faculty',
      'orders': [],
      "cart": {}, "fav_items": []
    });
  }

  @override
  Future<DocumentSnapshot> getUserDoc(String email) async {
    final result =
        await userCollection.where('email', isEqualTo: email).limit(1).get();
    return result.docs.length != 0 ? result.docs[0] : null;
  }

  @override
  Future<void> updateUserInfo(Map userInfo, String email) async {
    final userRef = db.collection('users').doc('email');
    await db.runTransaction((transaction) async {
      transaction.update(userRef, userInfo);
    });
  }
}
