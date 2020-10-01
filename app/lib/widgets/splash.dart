import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:scoped_model/scoped_model.dart';

class SplashBeelder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) => Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Image(
                  image: AssetImage('assets/images/icon.png'),
                  height: 20,
                ),
              ),
              Center(
                child: CircularProgressIndicator(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
