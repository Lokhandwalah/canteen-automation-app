import 'package:canteen/models/user.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:toast/toast.dart';

class PaymentPortal extends StatefulWidget {
  PaymentPortal(this.totalAmount, {@required this.user});
  final double totalAmount;
  final CurrentUser user;

  @override
  _PaymentPortalState createState() => _PaymentPortalState();
}

class _PaymentPortalState extends State<PaymentPortal> {
  Razorpay _razorpay;
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _proceedToPayment(CurrentUser user) async {
    print("total amount = ${widget.totalAmount}");
    var options = {
      'key': 'rzp_test_Nn6dy9COHbUMUc',
      'amount': widget.totalAmount.toInt() * 100,
      'name': 'KJSIEIT Canteen',
      'description': 'Payment for Order',
      'prefill': {
        'contact': '${user.phone}',
        'email': '${user.email}',
        'name': '${user.name}'
      },
      'external': {
        'wallets': ['paytm']
      },
      "theme": {"color": "#ea8b26"}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Toast.show("SUCCESS: " + response.paymentId, context);
    Navigator.of(context).pop(true);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print(
      "ERROR: " + response.code.toString() + " - " + response.message,
    );
    Toast.show("ERROR: " + response.code.toString() + " - " + response.message,
        context);
    Navigator.of(context).pop(false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Toast.show("EXTERNAL_WALLET: " + response.walletName, context);
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    _proceedToPayment(widget.user);
    return Container();
  }
}
