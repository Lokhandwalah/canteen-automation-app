import 'package:canteen/models/cart.dart';
import 'package:canteen/models/menu_items.dart';
import 'package:canteen/models/user.dart';
import 'package:canteen/screens/account/my_favs.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:provider/provider.dart';
import '../../widgets/dialog_box.dart';
import '../../services/authentication.dart';
import 'package:flutter/material.dart';

import '../auth_screen.dart';
import 'my_orders.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  CurrentUser user;
  Menu menu;
  Cart cart;
  @override
  Widget build(BuildContext context) {
    user = Provider.of<CurrentUser>(context);
    menu = Provider.of<Menu>(context);
    cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            ListTile(
              title: Text(
                user.name,
                style: TextStyle(fontSize: 25, color: primary),
              ),
              subtitle: Text(
                user.email,
                style: TextStyle(fontSize: 18, color: black),
              ),
              trailing: CircleAvatar(
                backgroundColor: primary,
                radius: 50,
                child: Icon(
                  Icons.person_outline,
                  color: black,
                  size: 40,
                ),
              ),
            ),
            OptionTile(
              title: 'My Orders',
              leading: Icons.fastfood,
              trailing: Icons.arrow_forward_ios,
              action: () => _navigateTo(MyOrders()),
            ),
            OptionTile(
              title: 'My Favourites',
              leading: Icons.favorite,
              trailing: Icons.arrow_forward_ios,
              action: () => _navigateTo(MyFavorites()),
            ),
            OptionTile(
              title: 'Share',
              leading: Icons.share,
            ),
            OptionTile(
              title: 'FAQ',
              leading: Icons.info,
            ),
            OptionTile(
              title: 'Logout',
              leading: Icons.exit_to_app,
              action: () => _handleSignout(context),
            )
          ],
        ),
      ),
    );
  }

  void _navigateTo(Widget screen) => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => MultiProvider(providers: [
                  ChangeNotifierProvider<CurrentUser>.value(value: user),
                  ChangeNotifierProvider<Cart>.value(value: cart),
                  ChangeNotifierProvider<Menu>.value(value: menu),
                ], child: screen)),
      );

  void _handleSignout(BuildContext context) async {
    bool signout = false;
    signout = await showDialog<bool>(
      context: context,
      builder: (_) => DialogBox(
          title: 'Confirm',
          description: 'Are you sure you want to Sign out ?',
          buttonText1: 'No',
          button1Func: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
          buttonText2: 'Yes',
          button2Func: () =>
              Navigator.of(context, rootNavigator: true).pop(true)),
    );
    if (signout) {
      AuthService().signOut();
      Navigator.of(context).pushReplacement(goTo(AuthScreen()));
    }
  }
}

class OptionTile extends StatelessWidget {
  final String title;
  final IconData leading, trailing;
  final Function action;
  const OptionTile({
    Key key,
    @required this.title,
    @required this.leading,
    this.trailing,
    this.action,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      color: bg,
      child: ListTile(
        title: Text(
          title,
        ),
        leading: Icon(
          leading,
          color: primary,
        ),
        trailing: trailing != null
            ? Icon(
                Icons.arrow_forward_ios,
                color: primary,
              )
            : null,
        onTap: () {
          // print('tapped $title');
          action();
        },
      ),
    );
  }
}
