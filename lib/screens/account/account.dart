import 'package:canteen/models/user.dart';
import 'package:canteen/utilities/constants.dart';
import '../../widgets/dialog_box.dart';
import '../../services/authentication.dart';
import 'package:flutter/material.dart';

import '../auth_screen.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  @override
  Widget build(BuildContext context) {
    final user = CurrentUser.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        centerTitle: true,
        actions: [_buildSignout(context)],
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
            Card(
              color: bg,
              child: ListTile(
                title: Text(
                  'My orders',
                ),
                leading: Icon(
                  Icons.fastfood,
                  color: primary,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: primary,
                ),
              ),
            ),
            Card(
              color: bg,
              child: ListTile(
                title: Text(
                  'My Favourites',
                ),
                leading: Icon(
                  Icons.favorite,
                  color: primary,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: primary,
                ),
              ),
            ),
            Card(
              color: bg,
              child: ListTile(
                title: Text(
                  'Share',
                ),
                leading: Icon(
                  Icons.share,
                  color: primary,
                ),
              ),
            ),
            Card(
              color: bg,
              child: ListTile(
                title: Text(
                  'FAQ',
                ),
                leading: Icon(
                  Icons.info,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignout(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.exit_to_app),
      onPressed: () async {
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
      },
    );
  }
}
