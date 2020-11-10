import 'package:canteen/models/cart.dart';
import 'package:canteen/models/category.dart';
import 'package:canteen/models/menu_items.dart';
import 'package:canteen/widgets/badge.dart';
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
    List<String> imageList = [
      'https://www.thespruceeats.com/thmb/XDmwhz9HXEMxhus08YhlIvTuAZI=/3865x2174/smart/filters:no_upscale()/paneer-makhani-or-shahi-paneer-indian-food-670906899-5878ef725f9b584db3d890f4.jpg',
      'https://media.cntraveller.in/wp-content/uploads/2020/05/dosa-recipes-866x487.jpg',
      'https://www.loveandoliveoil.com/wp-content/uploads/2015/03/soy-sauce-noodlesH2.jpg',
      'https://cdn.cdnparenting.com/articles/2020/02/26144447/PULAV.jpg'
    ];
    final user = Provider.of<CurrentUser>(context);
    final cart = Provider.of<Cart>(context);
    final menu = Provider.of<Menu>(context);
    List<MenuItem> items = menu.menuItems.values.toList();
    return Scaffold(
        appBar: AppBar(
          title: ListTile(
            title:
                Text('Welcome, ${user.name}', style: TextStyle(fontSize: 20)),
          ),
          actions: [
            IconButton(icon: Icon(Icons.notifications), onPressed: () {})
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ImageSlider(imageList),
                  Center(
                    child: const Text(
                      'What would you like you order today ?',
                      style: TextStyle(fontSize: 20, color: black),
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: Category.categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: secondary),
                          child: Column(
                            children: [
                              Container(
                                height: 80,
                                width: MediaQuery.of(context).size.width * 0.2,
                                decoration: BoxDecoration(
                                  color: primary,
                                  image: DecorationImage(
                                      image: NetworkImage(category.imageUrl),
                                      fit: BoxFit.cover),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8)),
                                ),
                              ),
                              Center(
                                  child: Text(
                                capitalize(category.name),
                                style: TextStyle(color: black),
                              )),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // SliverAppBar(
            //   pinned: true,
            //   backgroundColor: bg,
            //   title: TextFormField(
            //     decoration: InputDecoration(
            //         hintText: 'Search Menu',
            //         prefixIcon: Icon(Icons.search),
            //         focusedBorder: OutlineInputBorder(
            //             borderSide: BorderSide(
            //           style: BorderStyle.solid,
            //           width: 1,
            //           color: primary
            //         ))),
            //   ),
            // ),
            SliverList(
              delegate: SliverChildListDelegate(items.map((item) {
                return MenuItemListTile(cart: cart, item: item);
              }).toList()),
            ),
          ],
        ));
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
    return Padding(
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
            child: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(item.imageUrl),
            ),
          ),
          title: Text(item.displayName),
          subtitle: Text('₹${item.price}'),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ActionButtons(cart: cart, item: item),
              SizedBox(height: 5),
              if (insideCart)
                Text('₹${cart.items[item.name]['quantity'] * item.price}'),
            ],
          ),
        ),
      ),
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
