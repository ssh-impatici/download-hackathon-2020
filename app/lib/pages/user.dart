import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  //
  final bool expanded;
  UserPage(this.expanded);
  //
  @override
  Widget build(BuildContext context) {
    return expanded
        ? SafeArea(child: Scaffold(body: SingleChildScrollView(child: _body())))
        : SingleChildScrollView(
            child: Container(
            child: Column(
              children: [_body(), _button()],
            ),
          ));
  }

  Widget _body() {
    return Container(
      child: Column(
        children: [
          _title(),
          _name(),
          _bio(),
          _topics(),
        ],
      ),
    );
  }

  Widget _title() {
    return Container();
  }

  Widget _name() {
    return Container();
  }

  Widget _bio() {
    return Container();
  }

  Widget _topics() {
    return Container();
  }

  Widget _button() {
    return Container();
  }
}
