import 'package:canteen/utilities/constants.dart';

import '../widgets/dialog_box.dart';
import '../services/authentication.dart';
import 'package:flutter/material.dart';

import 'auth_screen.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        centerTitle: true,
        actions: [
          IconButton(
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
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
    );
  }
}
