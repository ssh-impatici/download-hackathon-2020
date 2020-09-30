import 'package:flutter/material.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:hackathon/utils/enums.dart';
import 'package:scoped_model/scoped_model.dart';

enum AuthMode { LOGIN, SINGUP }

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  //
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController verifyController = TextEditingController();

  bool visible = false;
  AuthMode mode = AuthMode.LOGIN;

  String email;
  String password;
  String verify;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(),
                _email(),
                _password(),
                _verify(),
                _button(),
                _togglemode(),
                _google()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return Container(
      padding: EdgeInsets.only(top: 50, bottom: 30),
      child: Text(
        'Hackathon',
        style: TextStyle(
            fontSize: 22,
            color: Colors.grey.shade200,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _email() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: emailController,
          decoration: InputDecoration(hintText: 'Email'),
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
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
          maxLines: 1,
          controller: passwordController,
          decoration: InputDecoration(
              hintText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(Icons.remove_red_eye),
                color: Colors.grey.shade200,
                onPressed: () => _changePasswordVisibility(),
              )),
          obscureText: visible ? false : true,
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

  Widget _verify() {
    return mode == AuthMode.SINGUP
        ? Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: TextFormField(
              maxLines: 1,
              controller: verifyController,
              decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.black),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.remove_red_eye),
                    color: Colors.grey.shade200,
                    onPressed: () => _changePasswordVisibility(),
                  )),
              obscureText: visible ? false : true,
              // ignore: missing_return
              validator: (String value) {
                if (mode == AuthMode.SINGUP) {
                  if (value.isEmpty) return 'password required! :(';
                  if (value != passwordController.text)
                    return 'password must match! :(';
                }
              },
            ),
          )
        : Container();
  }

  Widget _button() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        padding: EdgeInsets.only(top: 20, bottom: 15),
        child: RaisedButton(
          color: Colors.grey.shade900,
          child: Center(
            child: model.loading
                ? Container(
                    padding: EdgeInsets.all(10),
                    child: Center(child: CircularProgressIndicator()))
                : Text(
                    mode == AuthMode.LOGIN ? 'Log in' : 'Sign in',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
          onPressed: () => _submit(model),
        ),
      );
    });
  }

  void _submit(MainModel model) async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    AuthResult result = AuthResult.UNAUTHORIZED;

    if (mode == AuthMode.LOGIN)
      result = await model.login(email: email, password: password);

    if (mode == AuthMode.SINGUP)
      result = await model.createUserWithEmailAndPassword(
          email: email, password: password);

    switch (result) {
      case AuthResult.SIGNEDIN:
        await model.getHives();
        await model
            .getMapHives()
            .then((_) => Navigator.of(context).pushReplacementNamed('/home'));
        break;
      case AuthResult.SIGNEDUP:
        await model.getTopics().then(
            (value) => Navigator.of(context).pushReplacementNamed('/info'));
        break;
      case AuthResult.UNAUTHORIZED:
        await showDialog(
            context: context,
            child: AlertDialog(title: Text(model.errorMessage)));
        break;
      default:
    }
  }

  void _changePasswordVisibility() {
    setState(() {
      visible = !visible;
    });
  }

  Widget _togglemode() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          setState(() => mode == AuthMode.LOGIN
              ? mode = AuthMode.SINGUP
              : mode = AuthMode.LOGIN);
        },
        child: Text(
          mode == AuthMode.LOGIN
              ? "Don't have an account? Sign up"
              : 'Already have an account? Log in',
          style: TextStyle(decoration: TextDecoration.underline),
        ),
      ),
    );
  }

  Widget _google() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Container(
          decoration: BoxDecoration(color: Colors.grey.shade900),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage('assets/images/google.png'),
                      height: 20,
                    ),
                    SizedBox(width: 20),
                    Text('Sign in with Google')
                  ],
                ),
              ),
              onTap: () async {
                AuthResult result = await model.signInWithGoogle();
                switch (result) {
                  case AuthResult.SIGNEDIN:
                    await model.getHives();
                    await model.getMapHives().then((_) =>
                        Navigator.of(context).pushReplacementNamed('/home'));

                    break;
                  case AuthResult.SIGNEDUP:
                    await model.getTopics().then((_) =>
                        Navigator.of(context).pushReplacementNamed('/info'));

                    break;
                  case AuthResult.UNAUTHORIZED:
                    await showDialog(
                        context: context,
                        child: AlertDialog(title: Text(model.errorMessage)));
                    break;
                  default:
                }
              },
            ),
          ),
        ),
      );
    });
  }
}
