import 'package:flutter/material.dart';
import 'package:canteen/models/user.dart';
import 'package:canteen/services/database.dart';
import 'package:canteen/widgets/image_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../models/screen.dart';
import '../../utilities/constants.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  DateTime currentBackPressTime;
  Future<bool> _onWillPop(BuildContext ctx) async {
    if (_currentIndex == 0) {
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime) > Duration(seconds: 1)) {
        currentBackPressTime = now;
        Toast.show("Press back again to exit", ctx);
        return Future.value(false);
      }
      SystemNavigator.pop();
      return Future.value(true);
    } else {
      setState(() => _currentIndex = 0);
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // StatusBar.color(_currentIndex == 1 ? white : primary);
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            backgroundColor: primary,
            currentIndex: _currentIndex,
            selectedItemColor: white,
            onTap: (index) => setState(() => _currentIndex = index),
            elevation: 10,
            type: BottomNavigationBarType.fixed,
            items: Screen.pages
                .map(
                  (p) => BottomNavigationBarItem(
                      icon: Icon(p.icon),
                      activeIcon: Icon(p.activeIcon),
                      label: p.title),
                )
                .toList()),
        body: IndexedStack(
          index: _currentIndex,
          children: Screen.pages.map((p) => p.page).toList(),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    List<String> imageList = [
      'https://www.thespruceeats.com/thmb/XDmwhz9HXEMxhus08YhlIvTuAZI=/3865x2174/smart/filters:no_upscale()/paneer-makhani-or-shahi-paneer-indian-food-670906899-5878ef725f9b584db3d890f4.jpg',
      'https://media.cntraveller.in/wp-content/uploads/2020/05/dosa-recipes-866x487.jpg',
      'https://www.loveandoliveoil.com/wp-content/uploads/2015/03/soy-sauce-noodlesH2.jpg',
      'https://cdn.cdnparenting.com/articles/2020/02/26144447/PULAV.jpg'
    ];
    final user = Provider.of<CurrentUser>(context);
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text('Welcome, ${user.name}', style: TextStyle(fontSize: 20)),
        ),
        actions: [
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {}),
          IconButton(icon: Icon(Icons.notifications), onPressed: () {})
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(child: ImageSlider(imageList)),
              Center(
                child: const Text(
                  'What would you like you order today ?',
                  style: TextStyle(fontSize: 20, color: black),
                ),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Chinese', 'South Indian', 'Snacks', 'Beverages']
                    .map((category) {
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      height: 80,
                      width: MediaQuery.of(context).size.width * 0.2,
                      decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(15)),
                      child: Center(
                          child: Text(
                        category,
                        style: TextStyle(color: secondary),
                      )),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Expanded(
                child: StreamBuilder(
                    stream: DBService.db.collection('menu').snapshots(),
                    builder: (_, snapshot) {
                      if (!snapshot.hasData)
                        return Center(child: CircularProgressIndicator());
                      List<DocumentSnapshot> items = snapshot.data.documents;
                      return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (_, i) {
                            var item = items[i].data();
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    NetworkImage(item['image_url']),
                              ),
                              title: Text(item['name']),
                              subtitle: Text('${item['price']} ₹'),
                              trailing: Icon(Icons.add),
                              onTap: () {
                                user.addItem(item['name'], item['price'].toDouble());
                              },
                            );
                          });
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
