import 'package:canteen/services/database.dart';

class Category {
  final String name, imageUrl;
  Category({this.name, this.imageUrl});
  static List<Category> categories = [];
  static  initialize() async {
    final docs = (await DBService.db.collection('categories').get()).docs;
    docs.forEach(
      (doc) => categories.add(
        Category(name: doc.data()['name'], imageUrl: doc.data()['imageUrl']),
      ),
    );
  }
}
