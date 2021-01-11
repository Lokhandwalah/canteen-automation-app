import 'package:canteen/models/menu_items.dart';
import 'package:canteen/models/user.dart';
import 'package:canteen/services/database.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:canteen/widgets/itemListTile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyFavorites extends StatefulWidget {
  MyFavorites({Key key}) : super(key: key);

  @override
  _MyFavoritesState createState() => _MyFavoritesState();
}

class _MyFavoritesState extends State<MyFavorites> {
  CurrentUser user;
  @override
  Widget build(BuildContext context) {
    user = Provider.of<CurrentUser>(context);
    final menuItems = Provider.of<Menu>(context).menuItems;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: user.favourites.map(
            (item) {
              bool isFav = user.favourites.contains(item);
              item.imageUrl = menuItems[item.name].imageUrl;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  color: bg,
                  elevation: 6,
                  shadowColor: Colors.grey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildExpandedImage(context, item),
                      ListTile(
                        title: Text(
                          item.displayName(),
                          style: TextStyle(fontSize: 18, letterSpacing: 1),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: primary),
                          // onPressed: () =>
                          //     DBService().updateFavItems(item, user),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add items to Fav',
        child: Icon(
          Icons.add,
          size: 30,
          color: bg,
        ),
        onPressed: () {},
      ),
    );
  }

  AnimatedContainer _buildExpandedImage(BuildContext context, MenuItem item) {
    bool isAvailable = item.imageUrl?.isNotEmpty ?? false;
    return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: isAvailable ? 100 : 100,
        width: MediaQuery.of(context).size.width,
        child: !isAvailable
            ? Container(
                color: bg,
                alignment: Alignment.center,
                child: Icon(
                  Icons.fastfood_outlined,
                  size: 80,
                  color: primary,
                ))
            : Image.network(
                item.imageUrl,
                fit: BoxFit.fitWidth,
              ));
  }
}
