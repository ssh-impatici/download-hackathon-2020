import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:scoped_model/scoped_model.dart';

class HiveDescription extends StatefulWidget {
  final Hive hive;
  HiveDescription(this.hive);

  @override
  _HiveDescriptionState createState() => _HiveDescriptionState();
}

class _HiveDescriptionState extends State<HiveDescription> {
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
              widget.hive.address != null ? _section('Address') : Container(),
              _place(),
              widget.hive.openRoles.isNotEmpty
                  ? _section('Open Roles')
                  : Container(),
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
        widget.hive.name,
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
    return widget.hive.creator != null
        ? Container(
            child: Text(
              widget.hive.creator.fullName,
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
        widget.hive.description,
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
    );
  }

  Widget _place() {
    if (widget.hive.address == null) {
      return Container();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Text(widget.hive.address),
    );
  }

  Widget _openRoles(BuildContext context) {
    List<Widget> roles = List<Widget>();
    widget.hive.openRoles
        .sort((a, b) => a.name.length.compareTo(b.name.length));
    widget.hive.openRoles.forEach((role) {
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
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(10),
        ),
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
                        context: context,
                        builder: (context) => _confirmJoin(role));
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
    print(widget.hive.takenRoles);
    List<Widget> roles = List<Widget>();
    widget.hive.takenRoles.forEach((role) {
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
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) => Container(
        margin: EdgeInsets.only(bottom: 15),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade800),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      role.user.fullName,
                      style: TextStyle(fontSize: 15),
                    )
                  ],
                ),
              ),
            ),
            model.user.id == widget.hive.creator.id
                ? _remove(model.leaveHive, role)
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _remove(Function remove, TakenRole role) {
    return Flexible(
      child: InkWell(
          child: Icon(Icons.remove),
          onTap: () {
            showModalBottomSheet(
                context: context, builder: (context) => _confirmRemove(role));
          }),
    );
  }

  Widget _confirmJoin(OpenRole role) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) => Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        color: Colors.grey.shade900,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Text(
                'Joining ${widget.hive.name}',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Do you want to join this hive as:',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text(
                      role.name + ' ?',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            child: _button('Cancel', Colors.grey, false),
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            child: _button(
                                'Confirm', Colors.yellow, model.loading),
                            onTap: () {
                              setState(() {
                                model
                                    .joinHive(
                                        hiveId: widget.hive.id,
                                        roleId: role.name,
                                        userId: model.user.id)
                                    .then((_) => Navigator.pop(context));
                                int num = widget.hive.openRoles
                                    .firstWhere((openrole) =>
                                        openrole.name == role.name)
                                    .quantity;
                                if (num > 1) {
                                  widget.hive.openRoles.remove(role);
                                  role.quantity = role.quantity - 1;
                                  widget.hive.openRoles.add(role);
                                } else {
                                  widget.hive.openRoles.remove(role);
                                }
                                widget.hive.takenRoles.add(TakenRole(
                                    name: role.name, user: model.user));
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmRemove(TakenRole role) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) => Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        color: Colors.grey.shade900,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Text(
                'Removing ${role.user.fullName}',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Do you want to remove this bee',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text(
                      role.user.fullName + ' ?',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            child: _button('Cancel', Colors.grey, false),
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            child: _button(
                                'Confirm', Colors.yellow, model.loading),
                            onTap: () {
                              setState(() {
                                model
                                    .leaveHive(
                                        hiveId: widget.hive.id,
                                        roleId: role.name,
                                        userId: role.user.id)
                                    .then((_) => Navigator.pop(context));
                                widget.hive.takenRoles.remove(role);
                                widget.hive.openRoles
                                    .add(OpenRole(name: role.name));
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _button(String title, Color color, bool loading) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(5), color: color),
      child: Text(
        loading ? 'Bzz Bzz ..' : title,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.grey.shade900,
            fontWeight: FontWeight.bold,
            fontSize: 15),
      ),
    );
  }
}
