import 'package:canteen/models/cart.dart';
import 'package:canteen/models/menu_items.dart';
import 'package:canteen/models/user.dart';
import 'package:canteen/screens/cart/payment_portal.dart';
import 'package:canteen/services/database.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:canteen/widgets/custom_button.dart';
import 'package:canteen/widgets/itemListTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class MyCart extends StatefulWidget {
  @override
  _MyCartState createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  Map<String, dynamic> items;
  PaymentType _paymentType = PaymentType.digital;
  CurrentUser user;
  @override
  Widget build(BuildContext context) {
    user = Provider.of<CurrentUser>(context);
    final cart = Provider.of<Cart>(context);
    final menu = Provider.of<Menu>(context);
    items = cart.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
      ),
      body: SafeArea(
        child:
            cart.items.length == 0 ? _buildEmptyCart() : _buildCart(cart, menu),
      ),
    );
  }

  SingleChildScrollView _buildCart(Cart cart, Menu menu) {
    double total = 0;
    bool payOnline = _paymentType == PaymentType.digital;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          ...cart.itemList.map(
            (itemName) {
              MenuItem item = menu.menuItems[itemName];
              if (item == null) {
                cart.deleteItem(itemName);
                return Container();
              }
              if (!item.isAvailable) {
                cart.removeItem(item, delete: true);
                return Container();
              }
              total += (item.price * items[itemName]['quantity']).toDouble();
              items[itemName]['price'] = item.price.round();
              items[itemName].remove('id');
              print(items);
              return Slidable(
                key: ValueKey(itemName),
                actionPane: SlidableDrawerActionPane(),
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: 'Remove',
                    icon: Icons.delete,
                    color: Colors.red,
                    onTap: () => cart.removeItem(item, delete: true),
                    closeOnTap: true,
                  )
                ],
                dismissal: SlidableDismissal(
                  child: SlidableDrawerDismissal(),
                  onDismissed: (actionType) =>
                      cart.removeItem(item, delete: true),
                ),
                child: MenuItemListTile(
                  item: item,
                  cart: cart,
                  insideCart: true,
                ),
              );
            },
          ),
          SizedBox(height: 10),
          BillDetails(total),
          _buildPaymentDetails(total),
          Center(
            child: MyButton(
                title: payOnline ? 'Proceed to Pay' : 'Place Order',
                action: () => _handleOrder(payOnline, total, cart)),
          )
        ],
      ),
    );
  }

  void _handleOrder(bool isOnlinePayment, double amount, Cart cart) async {
    showLoader(context);
    if (isOnlinePayment) {
      print('proceedign to Online payment....');
      bool paymentSuccess = await Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => PaymentPortal(
            amount,
            user: Provider.of<CurrentUser>(context),
          ),
        ),
      );
      if (!paymentSuccess) {
        Navigator.of(context).pop();
        return;
      }
    }
    await DBService().placeOrder(
        userEmail: user.email,
        username: user.name,
        items: items,
        amount: amount,
        paymentType: _paymentType);
    await Future.delayed(Duration(seconds: 1));
    cart.removeAllItems();
    Navigator.of(context).pop();
    Toast.show('Order Placed Successfully', context);
  }

  Container _buildEmptyCart() {
    return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/basket.png',
              color: primary,
              height: 150,
              width: 150,
            ),
            SizedBox(height: 30),
            const Text(
              'Your cart is Empty',
              style: TextStyle(color: primary, fontSize: 20),
            ),
            SizedBox(height: 5),
            const Text(
              'Add something from the Menu',
              style: TextStyle(color: primary, fontSize: 20),
            ),
          ],
        ));
  }

  Widget _buildPaymentDetails(double total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        color: bg,
        elevation: 3,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.payment_outlined, color: Colors.grey),
                  ),
                  const Text(
                    'Payment:',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 1.5,
              ),
              RadioListTile<PaymentType>(
                groupValue: _paymentType,
                value: PaymentType.digital,
                onChanged: (value) => setState(() => _paymentType = value),
                title: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        color: _paymentType == PaymentType.digital
                            ? primary
                            : null),
                    SizedBox(width: 10),
                    Text('Pay Online via Wallets/UPI'),
                  ],
                ),
              ),
              RadioListTile<PaymentType>(
                groupValue: _paymentType,
                value: PaymentType.cash,
                onChanged: (value) => setState(() => _paymentType = value),
                title: Row(
                  children: [
                    Icon(Ionicons.md_cash,
                        color: _paymentType == PaymentType.cash
                            ? Colors.lightGreen[600]
                            : null),
                    SizedBox(width: 10),
                    Text('Pay Cash'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BillDetails extends StatelessWidget {
  const BillDetails(this.total);
  final double total;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        color: bg,
        elevation: 3,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child:
                        Icon(Icons.receipt_long_outlined, color: Colors.grey),
                  ),
                  const Text(
                    'Bill:',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 1.5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Sub Total',
                      style: TextStyle(color: primary),
                    ),
                    Spacer(),
                    Text('₹$total')
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Other Charges',
                      style: TextStyle(color: primary),
                    ),
                    Spacer(),
                    Text('₹${0.0}')
                  ],
                ),
              ),
              Divider(
                thickness: 1.5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(color: grey, fontSize: 15),
                    ),
                    Spacer(),
                    Text(
                      '₹$total',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
