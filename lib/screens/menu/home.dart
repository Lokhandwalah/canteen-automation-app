import 'package:canteen/models/cart.dart';
import 'package:canteen/models/category.dart';
import 'package:canteen/models/menu_items.dart';
import 'package:canteen/screens/menu/search.dart';
import 'package:canteen/widgets/itemListTile.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:canteen/models/user.dart';
import 'package:canteen/widgets/image_slider.dart';
import 'package:provider/provider.dart';

import '../../utilities/constants.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CurrentUser>(context);
    final cart = Provider.of<Cart>(context);
    final menu = Provider.of<Menu>(context);
    List<MenuItem> items = menu.menuItems.values.toList();
    return Scaffold(
        appBar: _buildAppBar(user),
        bottomSheet: _buildBottomSheet(context),
        body: CustomScrollView(
          slivers: [
            _buildSlider(),
            _buildCategories(context, cart, menu),
            SliverToBoxAdapter(child: SizedBox(height: 5)),
            SliverAppBar(
              floating: true,
              backgroundColor: bg,
              collapsedHeight: 60,
              centerTitle: true,
              title: _buildSearchField(context, cart, menu),
            ),
            SliverList(
              delegate:
                  SliverChildListDelegate(_buildCategoryItems(cart, items)),
            ),
          ],
        ));
  }

  SliverToBoxAdapter _buildSlider() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ImageSlider(imageList()),
            FittedBox(
              child: const Text(
                'What would you like you order today ?',
                style: TextStyle(fontSize: 18, color: black),
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, Cart cart, Menu menu) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          fullscreenDialog: true,
          transitionDuration: Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => MultiProvider(providers: [
            ChangeNotifierProvider<Cart>.value(value: cart),
            ChangeNotifierProvider<Menu>.value(value: menu),
          ], child: SearchPage()),
          transitionsBuilder:
              (_, animation, secondaryAnimation, Widget child) =>
                  FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ),
      child: Hero(
        tag: 'searchbar',
        child: Container(
          height: kToolbarHeight - 7,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: bg,
              border: Border.all(color: primary, width: 1.5),
              boxShadow: [
                BoxShadow(
                    offset: Offset(5, 2), color: Colors.grey, blurRadius: 5)
              ]),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.search, color: primary),
              ),
              Text(
                'Search Menu',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontSize: 15, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, Cart cart, Menu menu) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, crossAxisSpacing: 0, mainAxisSpacing: 5),
      delegate: SliverChildBuilderDelegate((_, index) {
        final category = Category.categories[index];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            PageRouteBuilder(
              fullscreenDialog: true,
              transitionDuration: Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => MultiProvider(providers: [
                ChangeNotifierProvider<Cart>.value(value: cart),
                ChangeNotifierProvider<Menu>.value(value: menu),
              ], child: CategoryItems(category)),
              transitionsBuilder:
                  (_, animation, secondaryAnimation, Widget child) =>
                      FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
          ),
          child: Hero(
            tag: category.name + 'container',
            child: Container(
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: primary,
                image: DecorationImage(
                    image: FirebaseImage(category.imageUrl),
                    fit: BoxFit.cover,
                    colorFilter:
                        ColorFilter.mode(Colors.black38, BlendMode.darken)),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Material(
                color: Colors.transparent,
                child: Text(
                  capitalize(category.name),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
      }, childCount: Category.categories.length),
    );
  }

  AppBar _buildAppBar(CurrentUser user) {
    return AppBar(
      title: ListTile(
        title: Text('Welcome, ${user.name}', style: TextStyle(fontSize: 20)),
      ),
      actions: [IconButton(icon: Icon(Icons.notifications), onPressed: () {})],
    );
  }

  List<Widget> _buildCategoryItems(Cart cart, List<MenuItem> items) {
    return Category.categories.map((category) {
      final filteredItems = items
          .where((item) =>
              item.category.toLowerCase() == category.name.toLowerCase() &&
              item.isAvailable)
          .toList();
      return filteredItems.length == 0
          ? Container()
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 0, 8.0),
                  child: Text(
                    capitalize(category.name),
                    style: TextStyle(
                        color: primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(
                  color: primary,
                ),
                ...filteredItems.map(
                  (item) => Hero(
                      tag: item,
                      child: MenuItemListTile(cart: cart, item: item)),
                ),
              ],
            );
    }).toList();
  }

  Widget _buildBottomSheet(BuildContext context) {
    return null;
    return Container(
      color: Colors.transparent,
      child: Card(
        color: primary,
        child: Container(
          height: 50,
          width: 50,
        ),
      ),
    );
  }
}
