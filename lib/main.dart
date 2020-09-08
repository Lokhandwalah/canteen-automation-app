import 'package:canteen/services/authentication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'utilities/constants.dart';
import 'screens/home.dart';
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
          primaryColor: primary,
          accentColor: primary,
          cursorColor: primary,
          primarySwatch: Colors.pink,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: SplashScreen(),
      routes: {
        '/home': (context) => MainScreen(),
        '/auth': (context) => AuthScreen()
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
    bool isLoggedIn = AuthService().isUserLoggedIn();
    Navigator.of(context).pushReplacement(PageTransition(
        child: isLoggedIn ? AuthScreen() : MainScreen(),
        type: rightToLeft,
        duration: Duration(milliseconds: 500)));
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() => _navigateHome());
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
              radius: 50,
              child: Icon(
                Icons.fastfood,
                size: 50,
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
