import 'package:canteen/models/cart.dart';
import 'package:canteen/models/category.dart';
import 'package:canteen/models/user.dart';
import 'package:canteen/screens/account/account.dart';
import 'package:canteen/screens/main_screen.dart';
import 'package:canteen/screens/menu/category_screen.dart';
import 'package:canteen/screens/menu/search.dart';
import 'package:canteen/services/authentication.dart';
import 'package:canteen/services/messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/menu_items.dart';
import 'screens/cart/cart_screen.dart';
import 'utilities/constants.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KJSIEIT Canteen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: bg,
          primaryColor: primary,
          accentColor: primary,
          primarySwatch: Colors.orange,
          textSelectionTheme: TextSelectionThemeData(cursorColor: primary),
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: SplashScreen(),
      routes: {
        '/home': (context) => MainScreen(),
        '/auth': (context) => AuthScreen(),
        '/cart': (context) => MyCart(),
        '/search': (context) => SearchPage(),
        '/account': (context) => MyAccount()
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _navigateHome() async {
    await Future.delayed(Duration(seconds: 3));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = AuthService().isUserLoggedIn();
    CurrentUser user;
    if (isLoggedIn) {
      print('user is already logged in');
      user = await UserData.setData(prefs.getString('email'));
    }
    await Menu().initialize();
    await Category.initialize();
    Navigator.of(context).pushReplacement(
      goTo(
        isLoggedIn
            ? MultiProvider(providers: [
                ChangeNotifierProvider<CurrentUser>.value(value: user),
                ChangeNotifierProvider<Cart>.value(value: user.cart),
                ChangeNotifierProvider<Menu>.value(value: Menu.menu),
              ], child: MainScreen())
            : AuthScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() => _navigateHome());
    MessagingService.getToken().then((token) => print('token: $token'));
    MessagingService.config('from main.dart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              backgroundColor: primary,
              radius: 50,
              child: Icon(
                Icons.fastfood,
                size: 50,
                color: white,
              ),
            ),
            Positioned(
              bottom: 150,
              child: loader(),
            ),
          ],
        ),
      ),
    );
  }
}
