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
  final Cart cart;
  final List<MenuItem> items;
  const CategoryItems(this.category, {this.cart, this.items});
  @override
  _CategoryItemsState createState() => _CategoryItemsState();
}

class _CategoryItemsState extends State<CategoryItems> {
  Cart cart;
  @override
  Widget build(BuildContext context) {
    cart = Provider.of<Cart>(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: bg,
            expandedHeight: MediaQuery.of(context).size.height * 0.3,
            iconTheme: IconThemeData(color: primary),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.category.name + 'container',
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    color: primary,
                    image: DecorationImage(
                        image: FirebaseImage(widget.category.imageUrl),
                        fit: BoxFit.cover,
                        colorFilter:
                            ColorFilter.mode(Colors.black38, BlendMode.darken)),
                  ),
                ),
              ),
              title: Text(
                capitalize(widget.category.name),
                textAlign: TextAlign.center, 
                style: TextStyle(color: primary, fontSize: 25),
              ),
            ),
            pinned: true,
          ),
          _buildItemsList(),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    final items = widget.items
        .where((item) =>
            item.category.toLowerCase() == widget.category.name.toLowerCase())
        .toList();
    return SliverList(
      delegate: SliverChildListDelegate(
        items.map((item) => MenuItemListTile(cart: cart, item: item)).toList(),
      ),
    );
  }
}
