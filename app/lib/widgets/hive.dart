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
              hive.address != null ? _section('Address') : Container(),
              _place(),
              hive.openRoles.isNotEmpty ? _section('Open Roles') : Container(),
              _openRoles(context),
              _section('People'),
              _takenRoles(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return Container(
      margin: EdgeInsets.only(bottom: 25, top: 10),
      child: Text(
        hive.name,
        style: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _section(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 15, top: 10),
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
              style: TextStyle(fontSize: 15),
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
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
    );
  }

  Widget _place() {
    if (hive.address == null) {
      return Container();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Text(hive.address),
    );
  }

  Widget _openRoles(BuildContext context) {
    List<Widget> roles = List<Widget>();
    hive.openRoles.sort((a, b) => a.name.length.compareTo(b.name.length));
    hive.openRoles.forEach((role) {
      roles.add(_openRole(role, context));
    });
    return Container(
      margin: EdgeInsets.only(bottom: 20, top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: roles,
      ),
    );
  }

  Widget _openRole(OpenRole role, BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(right: 10, bottom: 10),
        padding: EdgeInsets.only(bottom: 10, left: 10, right: 20, top: 10),
        decoration: BoxDecoration(
            color: Colors.yellow, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                InkWell(
                  child: Icon(
                    Icons.add,
                    color: Colors.grey.shade800,
                  ),
                  onTap: () {
                    showModalBottomSheet(
                        context: context, builder: (context) => _confirm());
                  },
                ),
                SizedBox(width: 10),
                Container(
                  child: Text(
                    role.name,
                    style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              ],
            ),
            Flexible(
              child: Container(
                child: Text(
                  role.quantity.toString(),
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _takenRoles(BuildContext context) {
    print(hive.takenRoles);
    List<Widget> roles = List<Widget>();
    hive.takenRoles.forEach((role) {
      roles.add(_takenRole(role, context));
    });
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        children: roles,
      ),
    );
  }

  Widget _takenRole(TakenRole role, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.grey.shade800),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role.name,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            role.user.fullName,
            style: TextStyle(fontSize: 15),
          )
        ],
      ),
    );
  }

  Widget _confirm() {
    return Container(
      height: 100,
      color: Colors.red,
    );
  }
}
