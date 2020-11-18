import 'package:animate_icons/animate_icons.dart';
import 'package:canteen/models/cart.dart';
import 'package:canteen/models/menu_items.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:canteen/widgets/itemListTile.dart';
import 'package:flutter/material.dart';

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      // appBar: AppBar(
      //   backgroundColor: bg,
      //   title: TextField(
      //     controller: _searchController,
      //     focusNode: _searchFocus,
      //   ),
      // ),
      body: Container(
        height: MediaQuery.of(widget.parentContext).size.height,
        color: Colors.grey,
      ),
    );
  }

  List<Widget> _buildSearchItems(Cart cart, List<MenuItem> items, String query) {
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
