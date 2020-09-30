import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/role.dart';

class HiveDescription extends StatelessWidget {
  final Hive hive;
  HiveDescription(this.hive);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(),
            _section('Author'),
            _author(),
            _description(),
            _place(),
            _openRoles(),
            _takenRoles()
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Container(
      child: Text(hive.name),
    );
  }

  Widget _section(String title) {
    return Container();
  }

  Widget _author() {
    return hive.creator != null
        ? Container(child: Text(hive.creator.fullName))
        : Container();
  }

  Widget _description() {
    return Container(
      child: Text(hive.description),
    );
  }

  Widget _place() {
    return Container(
      child: Text(hive.longitude.truncate().toString()),
    );
  }

  Widget _openRoles() {
    List<Widget> roles = List<Widget>();
    hive.openRoles.forEach((role) {
      roles.add(_openRole(role));
    });
    return Container(
      child: Wrap(
        children: roles,
      ),
    );
  }

  Widget _openRole(OpenRole role) {
    return GestureDetector(
      child: Container(
        child: Text(role.name),
      ),
    );
  }

  Widget _takenRoles() {
    return Container();
  }
}
