import 'package:canteen/models/cart.dart';
import 'package:canteen/models/category.dart';
import 'package:canteen/models/menu_items.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:canteen/widgets/itemListTile.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryItems extends StatefulWidget {
  final Category category;
  CategoryItems(this.category);
  @override
  _CategoryItemsState createState() => _CategoryItemsState();
}

class _CategoryItemsState extends State<CategoryItems> {
  Cart cart;
  List<MenuItem> items;
  Category category;

  @override
  void initState() {
    super.initState();
    category = widget.category;
  }

  @override
  Widget build(BuildContext context) {
    cart = Provider.of<Cart>(context);
    items = Provider.of<Menu>(context).itemList;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: bg,
            expandedHeight: MediaQuery.of(context).size.height * 0.3,
            iconTheme: IconThemeData(color: primary),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: category.name + 'container',
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    color: primary,
                    image: DecorationImage(
                        image: FirebaseImage(category.imageUrl),
                        fit: BoxFit.cover,
                        colorFilter:
                            ColorFilter.mode(Colors.black38, BlendMode.darken)),
                  ),
                ),
              ),
              title: Text(
                capitalize(category.name),
                textAlign: TextAlign.center,
                style: TextStyle(color: primary, fontSize: 25),
              ),
            ),
            pinned: true,
          ),
          _buildItemsList(category),
        ],
      ),
    );
  }

  Widget _buildItemsList(Category category) {
    final filteredItems = items
        .where((item) =>
            item.category.toLowerCase() == category.name.toLowerCase())
        .toList();
    return SliverList(
      delegate: SliverChildListDelegate(
        filteredItems
            .map((item) => MenuItemListTile(cart: cart, item: item))
            .toList(),
      ),
    );
  }
}
