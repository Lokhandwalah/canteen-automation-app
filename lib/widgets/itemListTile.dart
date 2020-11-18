
import 'package:canteen/models/cart.dart';
import 'package:canteen/models/menu_items.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';

class MenuItemListTile extends StatefulWidget {
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
  _MenuItemListTileState createState() => _MenuItemListTileState();
}

class _MenuItemListTileState extends State<MenuItemListTile> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final bool imageAvailable =
        widget.item.imageUrl != null && widget.item.imageUrl.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        color: bg,
        elevation: 3,
        shadowColor: Colors.grey,
        child: Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => expanded = false),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: expanded ? 150 : 0,
                width: expanded ? MediaQuery.of(context).size.width : 0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FirebaseImage(widget.item.imageUrl),
                      fit: BoxFit.fitWidth),
                ),
                curve: Curves.easeOutCubic,
              ),
            ),
            ListTile(
              onTap: !widget.insideCart && imageAvailable
                  ? () => setState(() => expanded = true)
                  : null,
              leading: AnimatedContainer(
                height: expanded ? 0 : 60,
                width: expanded ? 0 : 60,
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  BoxShadow(
                      color: Colors.grey[900],
                      offset: Offset(4, 3),
                      blurRadius: 5)
                ]),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: imageAvailable
                      ? FirebaseImage(widget.item.imageUrl)
                      : null,
                  child: imageAvailable ? null : Icon(Icons.fastfood_outlined),
                ),
              ),
              title: Text(widget.item.displayName()),
              subtitle: Text('₹${widget.item.price}'),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ActionButtons(cart: widget.cart, item: widget.item),
                  SizedBox(height: 5),
                  if (widget.insideCart)
                    Text(
                        '₹${widget.cart.items[widget.item.name.toLowerCase()]['quantity'] * widget.item.price}'),
                ],
              ),
            ),
          ],
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
