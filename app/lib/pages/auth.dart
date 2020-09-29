import 'package:flutter/material.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:scoped_model/scoped_model.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  //
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool visible = false;

  String email;
  String password;
  String verify;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_email(), _password(), _button()],
          ),
        ),
      ),
    );
  }

  Widget _email() {
    return Container(
      child: TextFormField(
          style: TextStyle(color: Colors.black),
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'email',
            labelStyle: TextStyle(color: Colors.black),
          ),
          cursorColor: Colors.black,
          // ignore: missing_return
          validator: (String value) {
            if (value.isEmpty) return 'email required! :(';
            if (value.isNotEmpty &&
                !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                    .hasMatch(value)) {
              return 'Please enter a valid email! :(';
            }
          },
          onSaved: (String value) {

            email = value;
            emailController..text = value;
          }),
    );
  }

  Widget _password() {
    return Container(
      child: TextFormField(
          style: TextStyle(color: Colors.black),
          maxLines: 1,
          controller: passwordController,
          decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.black),
              suffixIcon: IconButton(
                icon: Icon(Icons.remove_red_eye),
                color: Colors.black,
                onPressed: () => _changePasswordVisibility(),
              )),
          obscureText: visible ? false : true,
          cursorColor: Colors.black,
          // ignore: missing_return
          validator: (String value) {
            if (value.isEmpty) {
              return 'password required! :(';
            }
          },
          onSaved: (String value) {
            password = value;
            passwordController..text = value;
          }),
    );
  }

  Widget _button() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return RaisedButton(
          color: Colors.white,
          child: Center(
            child: model.loading
                ? Container(
                    padding: EdgeInsets.all(10),
                    child: Center(child: CircularProgressIndicator()))
                : Text(
                    'Log In',
                    style: TextStyle(color: Colors.black),
                  ),
          ),
          onPressed: () => {model.createUserWithEmailAndPassword(email, password)});
    });
  }

  void _changePasswordVisibility() {
    setState(() {
      visible = !visible;
    });
  }
}
