import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:hackathon/utils/enums.dart';
import 'package:scoped_model/scoped_model.dart';

enum AuthMode { LOGIN, SINGUP }

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
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
  void initState() {
    ScopedModel.of<MainModel>(context).user = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _logo(),
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
      ),
    );
  }

  Widget _logo() {
    return Center(
      child: Image.asset(
        'assets/icons/icon.png',
        height: 150.0,
        width: 150.0,
      ),
    );
  }

  Widget _title() {
    return Center(
      child: Container(
        padding: EdgeInsets.only(top: 36, bottom: 30),
        child: Text(
          'Beelder.',
          style: TextStyle(
            fontSize: 32,
            color: Colors.grey.shade200,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      bool isLoading = model.loading;
      bool isLoadingGoogle = model.googling;

      return Container(
        padding: EdgeInsets.only(top: 20, bottom: 15),
        child: RaisedButton(
          color: Colors.grey.shade900,
          disabledColor: Colors.grey.shade900,
          child: Center(
            child: isLoading
                ? Text('Bzz Bzz...')
                : Text(mode == AuthMode.LOGIN ? 'Log in' : 'Sign in'),
          ),
          onPressed:
              !isLoading && !isLoadingGoogle ? () => _submit(model) : null,
        ),
      );
    });
  }

  void _submit(MainModel model) async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    AuthResult result = AuthResult.UNAUTHORIZED;

    if (mode == AuthMode.LOGIN) {
      result = await model.login(
        email: email.trim(),
        password: password.trim(),
      );
    }

    if (mode == AuthMode.SINGUP) {
      result = await model.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    }

    switch (result) {
      case AuthResult.SIGNEDIN:
        await model.getHives();
        await model.getMapHives();
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case AuthResult.SIGNEDUP:
        await model.getTopics();
        Navigator.of(context).pushReplacementNamed('/info');
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
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        child: InkWell(
          onTap: !model.loading
              ? () {
                  setState(() => mode == AuthMode.LOGIN
                      ? mode = AuthMode.SINGUP
                      : mode = AuthMode.LOGIN);
                }
              : null,
          child: Text(
            mode == AuthMode.LOGIN
                ? "Don't have an account? Sign up"
                : 'Already have an account? Log in',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      );
    });
  }

  Widget _google() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      bool isLoading = model.googling;
      bool isLoadingLogin = model.loading;

      return Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        child: RaisedButton(
          color: Colors.grey.shade900,
          disabledColor: Colors.grey.shade900,
          child: Center(
            child: isLoading
                ? Text('Bzz Bzz...')
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage('assets/images/google.png'),
                        height: 18.0,
                      ),
                      SizedBox(width: 12.0),
                      Text('Sign in with Google')
                    ],
                  ),
          ),
          onPressed: !isLoading && !isLoadingLogin
              ? () async {
                  AuthResult result = await model.signInWithGoogle();

                  if (result == null) {
                    return;
                  }

                  switch (result) {
                    case AuthResult.SIGNEDIN:
                      // Get position once
                      Position pos = await model.getPosition();

                      LatLng latLng;
                      if (pos != null) {
                        latLng = LatLng(pos.latitude, pos.longitude);
                      }

                      await model.getTopics();
                      await model.getHives(latLng: latLng);
                      await model.getMapHives(latLng: latLng);

                      Navigator.of(context).pushReplacementNamed('/home');
                      break;
                    case AuthResult.SIGNEDUP:
                      await model.getTopics();
                      Navigator.of(context).pushReplacementNamed('/info');
                      break;
                    case AuthResult.UNAUTHORIZED:
                      await showDialog(
                        context: context,
                        child: AlertDialog(title: Text(model.errorMessage)),
                      );
                      break;
                    default:
                  }
                }
              : null,
        ),
      );
    });
  }
}
