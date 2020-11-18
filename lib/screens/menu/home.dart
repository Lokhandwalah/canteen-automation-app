import 'package:animate_icons/animate_icons.dart';
import 'package:canteen/models/cart.dart';
import 'package:canteen/models/category.dart';
import 'package:canteen/models/menu_items.dart';
import 'package:canteen/screens/menu/search.dart';
import 'package:canteen/widgets/badge.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:canteen/models/user.dart';
import 'package:canteen/services/database.dart';
import 'package:canteen/widgets/image_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../models/screen.dart';
import '../../utilities/constants.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  DateTime currentBackPressTime;
  Future<bool> _onWillPop(BuildContext ctx) async {
    if (_currentIndex == 0) {
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime) > Duration(seconds: 1)) {
        currentBackPressTime = now;
        Toast.show("Press back again to exit", ctx);
        return Future.value(false);
      }
      SystemNavigator.pop();
      return Future.value(true);
    } else {
      setState(() => _currentIndex = 0);
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // StatusBar.color(_currentIndex == 1 ? white : primary);
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            backgroundColor: primary,
            currentIndex: _currentIndex,
            selectedItemColor: white,
            onTap: (index) => setState(() => _currentIndex = index),
            elevation: 10,
            type: BottomNavigationBarType.fixed,
            items: Screen.pages
                .map(
                  (p) => BottomNavigationBarItem(
                      icon: p.title == 'Cart'
                          ? Badge(
                              child: Icon(p.activeIcon),
                              no: Provider.of<Cart>(context).items.length,
                            )
                          : Icon(p.activeIcon),
                      activeIcon: Icon(p.icon),
                      label: p.title),
                )
                .toList()),
        body: IndexedStack(
          index: _currentIndex,
          children: Screen.pages.map((p) => p.page).toList(),
        ),
      ),
    );
  }
}

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
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
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
            ),
            _buildCategories(context),
            SliverToBoxAdapter(child: SizedBox(height: 5)),
            SliverAppBar(
              floating: true,
              backgroundColor: bg,
              collapsedHeight: 60,
              centerTitle: true,
              title: _buildSearchField(context),
            ),
            SliverList(
              delegate:
                  SliverChildListDelegate(_buildCategoryItems(cart, items)),
            ),
          ],
        ));
  }

  Widget _buildSearchField(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
          context: context,
          builder: (_) => SearchPage(
                parentContext: context,
              )),
      child: Container(
        height: kToolbarHeight - 7,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: bg,
            border: Border.all(color: primary, width: 1.5),
            boxShadow: [
              BoxShadow(offset: Offset(5, 2), color: Colors.grey, blurRadius: 5)
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
    );
  }

  Widget _buildCategories(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, crossAxisSpacing: 0, mainAxisSpacing: 5),
      delegate: SliverChildBuilderDelegate((_, index) {
        final category = Category.categories[index];
        return Container(
          height: 80,
          width: MediaQuery.of(context).size.width * 0.2,
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
          child: Center(
            child: Text(
              capitalize(category.name),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
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

  _buildCategoryItems(Cart cart, List<MenuItem> items) {
    return Category.categories.map((category) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 20, 0, 8.0),
            child: Text(
              capitalize(category.name),
              style: TextStyle(
                  color: primary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(
            color: primary,
          ),
          ...items
              .where((item) =>
                  item.category.toLowerCase() == category.name.toLowerCase())
              .map(
                (item) => MenuItemListTile(cart: cart, item: item),
              ),
        ],
      );
    }).toList();
  }

  _buildSearchItems(Cart cart, List<MenuItem> items, String query) {
    items = items
        .where(
            (item) => item.name.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
    return [
      if (items.length == 0)
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28.0),
            child: Text('No Items Found'),
          ),
        )
      else
        ...items.map(
          (item) => MenuItemListTile(cart: cart, item: item),
        ),
      Expanded(child: Container()),
    ];
  }
}

class MenuItemListTile extends StatelessWidget {
  const MenuItemListTile(
      {Key key,
      @required this.cart,
      @required this.item,
      this.insideCart = false})
      : super(key: key);

  final Cart cart;
  final MenuItem item;
  final bool insideCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        color: bg,
        elevation: 3,
        shadowColor: Colors.grey,
        child: ListTile(
          leading: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
              BoxShadow(
                  color: Colors.grey[900], offset: Offset(4, 3), blurRadius: 5)
            ]),
            child: _builditemImage(item.imageUrl),
          ),
          title: Text(item.displayName()),
          subtitle: Text('₹${item.price}'),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ActionButtons(cart: cart, item: item),
              SizedBox(height: 5),
              if (insideCart)
                Text(
                    '₹${cart.items[item.name.toLowerCase()]['quantity'] * item.price}'),
            ],
          ),
        ),
      ),
    );
  }

  CircleAvatar _builditemImage(String url) {
    return CircleAvatar(
      radius: 30,
      backgroundImage:
          url != null && url.isNotEmpty ? FirebaseImage(url) : null,
      child:
          url != null && url.isNotEmpty ? null : Icon(Icons.fastfood_outlined),
    );
  }
}

class ActionButtons extends StatefulWidget {
  const ActionButtons({
    Key key,
    @required this.cart,
    @required this.item,
  }) : super(key: key);

  final Cart cart;
  final MenuItem item;

  @override
  _ActionButtonsState createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 25,
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey[900]),
          borderRadius: BorderRadius.circular(5)),
      child: widget.cart.items.containsKey(widget.item.name)
          ? Row(
              children: [
                Expanded(
                  child: GestureDetector(
                      onTap: () => widget.cart.removeItem(widget.item),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(Icons.remove, size: 16, color: primary),
                      )),
                ),
                Container(
                  width: 20,
                  color: primary,
                  child: Center(
                    child: Text(widget.cart.items[widget.item.name]['quantity']
                        .toString()),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                      onTap: () => widget.cart.addItem(widget.item),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(Icons.add, size: 16, color: primary),
                      )),
                ),
              ],
            )
          : GestureDetector(
              onTap: () => widget.cart.addItem(widget.item),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 5),
                  const Text('Add'),
                  SizedBox(width: 5),
                  Icon(Icons.add, size: 16, color: primary),
                ],
              ),
            ),
    );
  }
}
