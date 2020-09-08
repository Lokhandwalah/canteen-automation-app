import 'package:canteen/screens/home.dart';
import 'package:canteen/services/authentication.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:canteen/utilities/validation.dart';
import 'package:canteen/widgets/custom_textfield.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'custom_button.dart';
import 'dialog_box.dart';

class SignupForm extends StatefulWidget {
  final GlobalKey<FlipCardState> flipkey;
  const SignupForm({Key key, @required this.flipkey}) : super(key: key);
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false, _loading = false;
  TextEditingController _nameController, _emailController, _passwordController;
  // String _email, _password;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _loading = false;
    return SafeArea(
      child: AbsorbPointer(
        absorbing: _loading,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: Column(
                children: [
                  Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 30, color: primary),
                  ),
                  RoundedTextField(
                    child: TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      decoration: roundedTFDecoration(hintText: 'Name'),
                      validator: (value) {
                        if (Validation.emptyCheck(value.trim()))
                          return 'Please Enter Name';
                        else if (Validation.lengthCheck(value.trim(), 3))
                          return 'Name is too short';
                        return null;
                      },
                    ),
                  ),
                  RoundedTextField(
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: roundedTFDecoration(hintText: 'Email'),
                      validator: (value) {
                        if (Validation.emptyCheck(value.trim()))
                          return 'Please Enter Email';
                        else if (Validation.emailvalidation(value.trim()))
                          return 'Invalid Email';
                        return null;
                      },
                      // onChanged: (value) => _email = value.trim(),
                    ),
                  ),
                  RoundedTextField(
                    child: TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: roundedTFDecoration(hintText: 'Password'),
                      validator: (value) {
                        if (Validation.emptyCheck(value.trim()))
                          return 'Please Enter Password';
                        else if (Validation.lengthCheck(value.trim(), 6))
                          return 'Minimum 6 characters';
                        return null;
                      },
                      // onChanged: (value) => _password = value.trim(),
                    ),
                  ),
                  _loading
                      ? Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: loader(),
                            ),
                            Text(
                              'Signing you up...',
                              style: TextStyle(color: primary),
                            )
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 10),
                            MyButton(
                                title: 'Sign Up',
                                action: () {
                                  if (_formKey.currentState.validate())
                                    _handleSignup();
                                  else
                                    setState(() => _autoValidate = true);
                                }),
                            MyButton(
                                title: 'Signup with Google',
                                buttonColor: white,
                                textColor: primary,
                                buttonIcon: Icon(FontAwesome.google_plus,
                                    color: Colors.deepOrangeAccent.shade400),
                                action: () => _handleSignup(isGoogle: true)),
                            SizedBox(height: 15),
                            GestureDetector(
                              onTap: () =>
                                  widget.flipkey.currentState.toggleCard(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                        text: 'Don\'t have an Account ? ',
                                        style: TextStyle(
                                            fontSize: 15, color: black),
                                        children: [
                                          TextSpan(
                                              text: 'Sign Up',
                                              style: TextStyle(
                                                  fontSize: 17, color: primary))
                                        ]),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _handleSignup({bool isGoogle = false}) async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    Map result = isGoogle
        ? await AuthService().googleSignIn()
        : await AuthService()
            .sigIn(_emailController.text, _passwordController.text);
    await Future.delayed(Duration(seconds: 1));
    setState(() => _loading = false);
    bool success = result['success'];
    String title = success ? 'Login Successful' : 'Error';
    String content = success ? null : result['msg'];
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
              onWillPop: () => Future.value(!success),
              child: DialogBox(
                  title: title,
                  titleColor: !success ? Colors.red : null,
                  icon: success ? Icons.verified_user : null,
                  iconColor: Colors.teal,
                  description: content,
                  buttonText1: !success ? 'OK' : null,
                  button1Func: !success
                      ? () => Navigator.of(context, rootNavigator: true).pop()
                      : null),
            ));
    if (success) {
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pushReplacement(goTo(MainScreen()));
    }
  }
}
