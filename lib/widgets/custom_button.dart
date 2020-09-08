import 'package:canteen/utilities/constants.dart';
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton(
      {@required this.title,
      @required this.action,
      this.textColor,
      this.buttonColor,
      this.buttonIcon})
      : assert(title != null && action != null);
  final String title;
  final Function action;
  final Color textColor, buttonColor;
  final Icon buttonIcon;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width - 40,
      child: RaisedButton(
        onPressed: action,
        elevation: 5,
        color: buttonColor ?? primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (buttonIcon != null) buttonIcon,
              if (buttonIcon != null) SizedBox(width: 20),
              Text(
                title,
                style:
                    TextStyle(color: textColor ?? Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
