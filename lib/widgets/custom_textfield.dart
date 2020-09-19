import 'package:canteen/utilities/constants.dart';
import 'package:flutter/material.dart';

class RoundedTextField extends StatelessWidget {
  final Widget child;
  final double radius;
  const RoundedTextField({this.child, this.radius}) : assert(child != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Stack(
        overflow: Overflow.visible,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 55,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius ?? 15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black38,
                      blurRadius: 3,
                      offset: Offset(3, 3)),
                ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: child,
          )
        ],
      ),
    );
  }
}

InputDecoration roundedTFDecoration(
    {String hintText,
    String labelText,
    Color iconColor,
    IconData prefixIcon,
    IconData suffixIcon,
    Function suffixAction}) {
  return InputDecoration(
      hintStyle: TextStyle(color: secondary),
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(width: 0, style: BorderStyle.none),
      ),
      contentPadding: const EdgeInsets.all(16),
      fillColor: white,
      filled: true,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: iconColor ?? primary)
          : null,
      suffixIcon: suffixIcon != null
          ? GestureDetector(
              onTap: suffixAction,
              child: Icon(suffixIcon, color: iconColor ?? primary))
          : null);
}
