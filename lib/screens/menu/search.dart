import 'package:animate_icons/animate_icons.dart';
import 'package:canteen/models/cart.dart';
import 'package:canteen/models/category.dart';
import 'package:canteen/models/menu_items.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:canteen/widgets/itemListTile.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'category_screen.dart';

class SearchPage extends StatefulWidget {
  final BuildContext parentContext;
  const SearchPage({Key key, this.parentContext}) : super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController;
  FocusNode _searchFocus;
  AnimateIconController _iconController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
    _iconController = AnimateIconController();
    Future.delayed(Duration(milliseconds: 500))
        .then((_) => _searchFocus.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final menu = Provider.of<Menu>(context);
    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(slivers: [
        _buildSearchBar(),
        _buildSearchCategory(cart, menu),
        _buildSearchItems(cart, menu.itemList)
      ]),
    );
  }

  SliverAppBar _buildSearchBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: bg,
      automaticallyImplyLeading: false,
      title: Hero(
        tag: 'searchbar',
        child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: primary, width: 1.5),
                borderRadius: BorderRadius.circular(25),
              ),
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: TextField(
                focusNode: _searchFocus,
                controller: _searchController,
                onChanged: (_) => setState(() {
                  _searchController.text.isNotEmpty
                      ? _iconController.animateToEnd()
                      : _iconController.animateToStart();
                }),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search Menu, Dishes...',
                    prefixIcon: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.arrow_back_ios_outlined)),
                    suffixIcon: AnimateIcons(
                      controller: _iconController,
                      startIcon: null,
                      endIcon: Icons.clear,
                      onStartIconPress: () => true,
                      onEndIconPress: () {
                        setState(() => _searchController.clear());
                        return true;
                      },
                      duration: Duration(milliseconds: 300),
                      size: 23,
                    )),
              ),
            )),
      ),
    );
  }

  SliverList _buildSearchItems(Cart cart, List<MenuItem> items) {
    final query = _searchController.text;
    items = items
        .where(
            (item) => item.name.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          if (items.length == 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28.0),
              child: Center(
                  child: Text(
                'No Items Found :(',
                style: TextStyle(fontSize: 18),
              )),
            )
          else
            ...items.map(
              (item) => MenuItemListTile(cart: cart, item: item),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchCategory(Cart cart, Menu menu) {
    final query = _searchController.text;
    final categories = Category.categories
        .where((category) =>
            category.name.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          if (categories.length != 0)
            ...categories.map(
              (category) => GestureDetector(
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
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    height: 100,
                    child: Card(
                      color: bg,
                      elevation: 3,
                      shadowColor: Colors.grey,
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: FirebaseImage(category.imageUrl),
                              fit: BoxFit.fitWidth,
                              colorFilter: ColorFilter.mode(
                                  Colors.black26, BlendMode.darken)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, left: 10),
                          child: Text(capitalize(category.name),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
