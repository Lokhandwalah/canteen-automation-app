import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OrderPlaced extends StatefulWidget {
  @override
  _OrderPlacedState createState() => _OrderPlacedState();
}

class _OrderPlacedState extends State<OrderPlaced> {
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(Duration(seconds: 2)).then((value) => Navigator.of(context).pop());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/images/order_placed.json'),
              SizedBox(height: 20),
              Text(
                'Order Placed Successfully',
                style: TextStyle(color: Color(0xff009649), fontSize: 22),
              )
            ],
          ),
        ),
      ),
    );
  }
}
