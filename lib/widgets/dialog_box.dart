import 'package:flutter/material.dart';

class DialogBox extends StatelessWidget {
  final String title, description, buttonText1, buttonText2;
  final Function button1Func, button2Func;
  final IconData icon;
  final Color iconColor, titleColor;
  const DialogBox(
      {Key key,
      @required this.title,
      @required this.description,
      @required this.buttonText1,
      @required this.button1Func,
      this.buttonText2,
      this.button2Func,
      this.icon,
      this.iconColor,
      this.titleColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: EdgeInsets.only(top: icon == null ? 30.0 : 60),
                  margin: EdgeInsets.only(top: icon == null ? 0.0 : 60),
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // To make the card compact
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w700,
                            color: titleColor ?? Colors.grey[900]),
                      ),
                      if (description != null)
                        Column(
                          children: <Widget>[
                            SizedBox(height: 16.0),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.grey[900]),
                                )),
                          ],
                        ),
                      buttonText1 == null
                          ? SizedBox(height: 30)
                          : Column(
                              children: <Widget>[
                                SizedBox(height: 24.0),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: FlatButton(
                                          onPressed: button1Func,
                                          child: Text(
                                            buttonText1,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 20.0,
                                                color: buttonText2 == null
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Colors.red),
                                          ),
                                        ),
                                      ),
                                      if (buttonText2 != null)
                                        Expanded(
                                          child: FlatButton(
                                            onPressed: button2Func,
                                            child: Text(
                                              buttonText2,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 20.0,
                                                  color: Colors.green),
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                )
                              ],
                            )
                    ],
                  )),
            ),
            if (icon != null)
              Positioned(
                left: 15,
                right: 15,
                child: CircleAvatar(
                  backgroundColor: iconColor != null
                      ? iconColor
                      : Theme.of(context).primaryColor,
                  child: Icon(
                    icon,
                    size: 60.0,
                    color: Colors.white,
                  ),
                  radius: 60,
                ),
              )
          ],
        ),
      ),
    );
  }
}
