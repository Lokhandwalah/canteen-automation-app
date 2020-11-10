import 'package:canteen/utilities/constants.dart';
import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final int no;
  final Widget child;
  final double radius;
  final bool showOnlyBadge;
  Badge(
      {this.child, this.no = 0, this.radius = 18, this.showOnlyBadge = false});
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (showOnlyBadge || no != 0)
          Positioned(
            top: -4,
            right: -12,
            child: Container(
              height: radius,
              width: radius,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: no == 0 ? null : Center(child: Text(no.toString())),
            ),
          )
      ],
    );
  }
}
