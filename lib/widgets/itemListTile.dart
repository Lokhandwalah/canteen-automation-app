import 'package:canteen/models/cart.dart';
import 'package:canteen/models/menu_items.dart';
import 'package:canteen/models/user.dart';
import 'package:canteen/services/database.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class MenuItemListTile extends StatefulWidget {
  const MenuItemListTile({
    Key key,
    @required this.cart,
    @required this.item,
    @required this.user,
    this.insideCart = false,
  }) : super(key: key);

  final CurrentUser user;
  final Cart cart;
  final MenuItem item;
  final bool insideCart;

  @override
  _MenuItemListTileState createState() => _MenuItemListTileState();
}

class _MenuItemListTileState extends State<MenuItemListTile> {
  bool expanded = false;
  bool isFav = false;
  CurrentUser user;
  TapDownDetails _tapDownDetails;

  @override
  Widget build(BuildContext context) {
    user = widget.user;
    isFav = user.favourites.contains(widget.item);
    final bool imageAvailable =
        widget.item.imageUrl != null && widget.item.imageUrl.isNotEmpty;
    final isAvailable = widget.item.isAvailable;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        color: bg,
        elevation: 3,
        shadowColor: Colors.grey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (imageAvailable)
              Stack(
                children: [
                  GestureDetector(
                      onTap: () => setState(() => expanded = false),
                      child: _buildExpandedImage(context, isAvailable)),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: _buildFavButton(),
                  ),
                ],
              ),
            GestureDetector(
              onTapDown: (position) =>
                  setState(() => _tapDownDetails = position),
              child: ListTile(
                onTap: !widget.insideCart && imageAvailable
                    ? () => setState(() => expanded = true)
                    : null,
                onLongPress: _handleLongPress,
                tileColor: isAvailable ? null : Colors.grey.withOpacity(0.5),
                leading: _buildItemImage(isAvailable, imageAvailable),
                title: Text(widget.item.displayName()),
                subtitle: Text('₹${widget.item.price}'),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ActionButtons(
                        availability: isAvailable,
                        cart: widget.cart,
                        item: widget.item),
                    SizedBox(height: 5),
                    if (widget.insideCart) _price,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer _buildItemImage(bool isAvailable, bool imageAvailable) {
    return AnimatedContainer(
      height: expanded ? 0 : 60,
      width: expanded ? 0 : 60,
      duration: Duration(milliseconds: 300),
      foregroundDecoration: isAvailable
          ? null
          : BoxDecoration(
              color: Colors.grey,
              backgroundBlendMode: BlendMode.saturation,
              shape: BoxShape.circle,
            ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.grey[900], offset: Offset(4, 3), blurRadius: 5)
        ],
      ),
      child: CircleAvatar(
        radius: 30,
        backgroundImage:
            imageAvailable ? NetworkImage(widget.item.imageUrl) : null,
        child: imageAvailable ? null : Icon(Icons.fastfood_outlined),
      ),
    );
  }

  AnimatedContainer _buildExpandedImage(
      BuildContext context, bool isAvailable) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      height: expanded ? 150 : 0,
      width: expanded ? MediaQuery.of(context).size.width : 0,
      foregroundDecoration: isAvailable
          ? null
          : BoxDecoration(
              color: Colors.grey,
              backgroundBlendMode: BlendMode.saturation,
            ),
      decoration: BoxDecoration(
        image: DecorationImage(
            image: NetworkImage(widget.item.imageUrl), fit: BoxFit.fitWidth),
      ),
    );
  }

  AnimatedContainer _buildFavButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      curve: Curves.easeOut,
      height: expanded ? 50 : 0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      child: CircleAvatar(
        radius: 25,
        child: IconButton(
          tooltip: 'Add To Favorites',
          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
              color: primary),
          onPressed: () =>
              DBService().updateFavItems(widget.item, user.email, isFav),
        ),
      ),
    );
  }

  Text get _price {
    final quantity = widget.cart.items[widget.item.name]['quantity'];
    final price = widget.item.price;
    return Text('₹${quantity * price}');
  }

  void _handleLongPress() {
    // Toast.show(
    //     '${isFav ? 'Removed' : 'Added'} ${widget.item.displayName()} ${isFav ? 'from' : 'to'} favourties',
    //     context);
    // final position = _tapDownDetails.globalPosition;
    // final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    // showMenu(
    //     context: context,
    //     position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
    //     items: [
    //       PopupMenuItem(
    //         value: 'fav',
    //         child: Text('Add to Favs'),
    //       )
    //     ]);
  }
}

class ActionButtons extends StatefulWidget {
  const ActionButtons(
      {Key key,
      @required this.cart,
      @required this.item,
      @required this.availability})
      : super(key: key);

  final Cart cart;
  final MenuItem item;
  final bool availability;

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
          borderRadius: BorderRadius.circular(5),
          color: widget.availability ? null : Colors.grey),
      child: widget.cart.items.containsKey(widget.item.name)
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                      onTap: () => widget.cart.removeItem(widget.item),
                      child: Icon(Icons.remove,
                          size: 20,
                          color: widget.availability ? primary : null)),
                ),
                Container(
                  width: 20,
                  color: widget.availability ? primary : Colors.grey.shade600,
                  child: Center(
                    child: Text(quantity.toString()),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                      onTap: () => widget.cart.addItem(widget.item),
                      child: Icon(Icons.add,
                          size: 20,
                          color: widget.availability ? primary : null)),
                ),
              ],
            )
          : _buildAddButton(context),
    );
  }

  GestureDetector _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.item.isAvailable
          ? widget.cart.addItem(widget.item)
          : Toast.show('The item is currently unavailable', context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 5),
          const Text('Add'),
          SizedBox(width: 5),
          Icon(Icons.add,
              size: 16, color: widget.availability ? primary : null),
        ],
      ),
    );
  }

  int get quantity => widget.cart.items[widget.item.name]['quantity'];
}
