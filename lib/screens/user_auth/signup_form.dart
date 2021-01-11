import 'package:canteen/models/cart.dart';
import 'package:canteen/models/menu_items.dart';
import 'package:canteen/models/user.dart';
import 'package:canteen/services/authentication.dart';
import 'package:canteen/services/database.dart';
import 'package:canteen/utilities/constants.dart';
import 'package:canteen/utilities/validation.dart';
import 'package:canteen/widgets/custom_textfield.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/dialog_box.dart';
import '../main_screen.dart';

class SignupForm extends StatefulWidget {
  final GlobalKey<FlipCardState> flipkey;
  const SignupForm({Key key, @required this.flipkey}) : super(key: key);
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  bool  _loading = false, _showPassword = false;
  TextEditingController _nameController,
      _emailController,
      _passwordController,
      _confirmController,
      _phoneController;
  UserType userType = UserType.student;
  String _name, _email, _password, _phone;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneController.dispose();
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      decoration: roundedTFDecoration(
                          hintText: 'Name', prefixIcon: Icons.person_outline),
                      validator: (value) {
                        if (Validation.emptyCheck(value.trim()))
                          return 'Please Enter Name';
                        else if (Validation.lengthCheck(value.trim(), 3))
                          return 'Name is too short';
                        return null;
                      },
                      onChanged: (value) => _name = value.trim(),
                    ),
                  ),
                  RoundedTextField(
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: roundedTFDecoration(
                          hintText: 'Email', prefixIcon: Icons.mail_outline),
                      validator: (value) {
                        if (Validation.emptyCheck(value.trim()))
                          return 'Please Enter Email';
                        else if (Validation.emailvalidation(value.trim()))
                          return 'Invalid Email';
                        return null;
                      },
                      onChanged: (value) => _email = value.trim(),
                    ),
                  ),
                  RoundedTextField(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: roundedTFDecoration(
                          hintText: 'Phone', prefixIcon: Icons.phone),
                      validator: (value) {
                        if (Validation.emptyCheck(value.trim()))
                          return 'Please Enter Phone No';
                        else if (Validation.lengthCheck(value.trim(), 10))
                          return 'Must be 10 digits';
                        return null;
                      },
                      onChanged: (value) => _phone = value.trim(),
                    ),
                  ),
                  RoundedTextField(
                    child: TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: _showPassword,
                      decoration: roundedTFDecoration(
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          suffixAction: () =>
                              setState(() => _showPassword = !_showPassword),
                          suffixIcon: _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                      validator: (value) {
                        if (Validation.emptyCheck(value.trim()))
                          return 'Please Enter Password';
                        else if (Validation.lengthCheck(value.trim(), 6))
                          return 'Minimum 6 characters';
                        return null;
                      },
                      onChanged: (value) => _password = value.trim(),
                    ),
                  ),
                  RoundedTextField(
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: _confirmController,
                      obscureText: true,
                      decoration: roundedTFDecoration(
                          hintText: 'Confirm Password',
                          prefixIcon:
                              _confirmController.text.trim() == _password
                                  ? Icons.verified_user
                                  : Icons.lock_outline),
                      validator: (value) {
                        if (Validation.emptyCheck(value.trim()))
                          return 'Please confirm your Password';
                        else if (value.trim() != _password)
                          return 'Passwords don\'t match';
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<UserType>(
                                  value: UserType.student,
                                  groupValue: userType,
                                  onChanged: (type) =>
                                      setState(() => userType = type)),
                              Text('Student')
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<UserType>(
                                  value: UserType.faculty,
                                  groupValue: userType,
                                  onChanged: (type) =>
                                      setState(() => userType = type)),
                              Text('Faculty')
                            ],
                          ),
                        ],
                      )),
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
                            MyButton(
                                title: 'Sign Up',
                                action: () {
                                  if (_formKey.currentState.validate())
                                    _handleSignup();
                                }),
                            MyButton(
                                title: 'Signup with Google',
                                buttonColor: white,
                                textColor: primary,
                                buttonIcon: Icon(FontAwesome.google_plus,
                                    color: Colors.deepOrangeAccent.shade400),
                                action: _handleGoogleSignup),
                            SizedBox(height: 15),
                            GestureDetector(
                              onTap: () =>
                                  widget.flipkey.currentState.toggleCard(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                        text: 'Already have an Account ? ',
                                        style: TextStyle(
                                            fontSize: 15, color: black),
                                        children: [
                                          TextSpan(
                                              text: 'Sign In',
                                              style: TextStyle(
                                                  fontSize: 17, color: primary))
                                        ]),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 20)
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

  _handleGoogleSignup() {}

  _handleSignup() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final user = UserData(
        name: _name,
        email: _email,
        password: _password,
        phone: '+91' + _phone,
        type: userType);
    Map result = await AuthService().signUp(user);
    if (result['success']) {
      user.uid = result['uid'];
      await DBService().createUser(user);
      await Future.delayed(Duration(seconds: 1));
      setState(() => _loading = false);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => DialogBox(
                title: 'Success',
                description: 'You have signed up Successfully',
                icon: Icons.verified_user,
                iconColor: Colors.teal,
                buttonText1: null,
                button1Func: null,
              ));
    }
    if (result['success']) {
      CurrentUser currentUser = result['current'];
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pushReplacement(
        goTo(
          MultiProvider(providers: [
            ChangeNotifierProvider<CurrentUser>.value(value: currentUser),
            ChangeNotifierProvider<Cart>.value(value: currentUser.cart),
                ChangeNotifierProvider<Menu>.value(value: Menu.menu),
          ], child: MainScreen()),
        ),
      );
    }
  }
}
