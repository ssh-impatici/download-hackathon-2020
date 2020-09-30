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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(),
              _section('Author'),
              _author(),
              _section('Hive Descrpition'),
              _description(),
              // hive.address != null ? _section('Address') : Container()
              _section('Address'),
              _place(),
              _section('Open Roles'),
              _openRoles(),
              _section('People'),
              _takenRoles()
            ],
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      child: Text(
        hive.name,
        style: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _section(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _author() {
    return hive.creator != null
        ? Container(
            child: Text(
              hive.creator.fullName,
              style: TextStyle(fontSize: 16),
            ),
            margin: EdgeInsets.only(bottom: 20),
          )
        : Container();
  }

  Widget _description() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Text(
        hive.description,
        style: TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _place() {
    if (hive.longitude == null) {
      return null;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Text(hive.longitude.truncate().toString()),
    );
  }

  Widget _openRoles() {
    List<Widget> roles = List<Widget>();
    hive.openRoles.sort((a, b) => a.name.length.compareTo(b.name.length));
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
      margin: EdgeInsets.only(right: 10, bottom: 10, top: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.yellow, borderRadius: BorderRadius.circular(10)),
      child: Text(
        role.name,
        style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 12),
      ),
    ));
  }

  Widget _takenRoles() {
    return Container();
  }
}
