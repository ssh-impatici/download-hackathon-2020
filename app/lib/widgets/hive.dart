import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/classes/topic.dart';
import 'package:hackathon/classes/user.dart';
import 'package:hackathon/pages/user.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:hackathon/widgets/review_dialog.dart';
import 'package:scoped_model/scoped_model.dart';

enum FromScreen { MAP, LIST, MY_HIVES }

class HiveDescription extends StatefulWidget {
  final String hiveId;
  final FromScreen from;
  HiveDescription(this.hiveId, this.from);

  @override
  _HiveDescriptionState createState() => _HiveDescriptionState();
}

class _HiveDescriptionState extends State<HiveDescription> {
  Hive _hive;

  @override
  void initState() {
    _retrieveHive(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 50),
            child: _hive != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _title(),
                      _topics(),
                      SizedBox(height: 20),
                      _section('Author'),
                      _author(),
                      _section('Hive Descrpition'),
                      _description(),
                      _hive.address != null ? _section('Address') : Container(),
                      _place(),
                      _hive.openRoles.isNotEmpty
                          ? _section('Open Roles')
                          : Container(),
                      _openRoles(context),
                      _hive.takenRoles != null && _hive.takenRoles.isNotEmpty
                          ? _section('People')
                          : Container(),
                      _takenRoles(),
                      _giveUp()
                    ],
                  )
                : CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Hive _retrieveHive(bool reload) {
    Hive hive;

    switch (widget.from) {
      case FromScreen.MAP:
        {
          hive = ScopedModel.of<MainModel>(context)
              .hivesMap
              .firstWhere((hive) => hive.id == widget.hiveId);
          break;
        }
      case FromScreen.LIST:
        {
          hive = ScopedModel.of<MainModel>(context)
              .hivesList
              .firstWhere((hive) => hive.id == widget.hiveId);
          break;
        }
      case FromScreen.MY_HIVES:
        {
          hive = ScopedModel.of<MainModel>(context)
              .user
              .hives
              .firstWhere((hive) => hive.id == widget.hiveId);
          break;
        }
    }

    if (reload) {
      setState(() {
        _hive = hive;
      });
    }

    return hive;
  }

  Widget _title() {
    return Container(
      margin: EdgeInsets.only(bottom: 25, top: 10),
      child: Text(
        _hive.name,
        style: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _topics() {
    List<Widget> _list = List<Widget>();

    _hive.topics.forEach((topic) {
      _list.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              color: Colors.yellow, borderRadius: BorderRadius.circular(10)),
          child: Text(
            topic.id,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    });

    return Container(
      child: Wrap(
        children: _list,
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
    return _hive.creator != null
        ? Container(
            child: Text(
              _hive.creator.fullName,
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
        _hive.description,
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
    );
  }

  Widget _place() {
    if (_hive.address == null) {
      return Container();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Text(_hive.address),
    );
  }

  Widget _openRoles(BuildContext context) {
    List<Widget> roles = List<Widget>();
    _hive.openRoles.sort((a, b) => a.name.length.compareTo(b.name.length));
    _hive.openRoles.forEach((role) {
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
    bool alreadyJoined = _userAlreadyJoined(
        role, _retrieveHive(false), ScopedModel.of<MainModel>(context).user);

    return Container(
      decoration: BoxDecoration(
        color: alreadyJoined ? Colors.grey.shade800 : Colors.yellow,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => _confirmJoin(role),
            );
          },
          child: Container(
            padding: EdgeInsets.only(bottom: 10, left: 10, right: 20, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      height: 25,
                      width: 25,
                      child: alreadyJoined
                          ? Container()
                          : Icon(
                              Icons.add,
                              color: Colors.grey.shade800,
                            ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      child: Text(
                        role.name,
                        style: TextStyle(
                            color: alreadyJoined
                                ? Colors.white
                                : Colors.grey.shade800,
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
                          color: alreadyJoined
                              ? Colors.white
                              : Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _takenRoles() {
    List<Widget> roles = List<Widget>();

    _hive.takenRoles.forEach((role) {
      roles.add(_takenRole(role));
    });

    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        children: roles,
      ),
    );
  }

  Widget _takenRole(TakenRole role) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        bool isOwner = model.user.id == _hive.creator.id;

        return Container(
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
                child: InkWell(
                  onTap: () => {
                    role.user.id != model.user.id
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SafeArea(
                                child: Scaffold(
                                  body: UserPage(role.user),
                                ),
                              ),
                            ),
                          )
                        : {}
                  },
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role.name,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
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
              ),
              isOwner ? _review(role) : Container(),
              model.user.id == _hive.creator.id || model.user.id == role.user.id
                  ? _remove(model.leaveHive, role)
                  : Container()
            ],
          ),
        );
      },
    );
  }

  Widget _review(TakenRole role) {
    return Container(
      margin: EdgeInsets.only(right: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            padding: EdgeInsets.all(4.0),
            child: Icon(
              Icons.rate_review,
              size: 20.0,
            ),
          ),
          onTap: () async {
            await ScopedModel.of<MainModel>(context).getTopics();

            showDialog(
              context: context,
              builder: (ctx) => ReviewDialog(
                role.user,
                role.name,
                (stars) => _onConfirm(role.user, role.name, stars),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _onConfirm(User user, String role, int stars) async {
    MainModel model = ScopedModel.of<MainModel>(context);

    Topic topic = model.topics != null
        ? model.topics.firstWhere((topic) => topic.roles.contains(role))
        : null;

    if (topic == null) {
      return false;
    }

    await model.setUserRating(
      userId: user.id,
      role: role,
      topic: topic.id,
      stars: stars,
    );

    return true;
  }

  Widget _remove(Function remove, TakenRole role) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          padding: EdgeInsets.all(4.0),
          child: Icon(
            Icons.remove_circle,
            size: 20.0,
          ),
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => _confirmRemove(role),
          );
        },
      ),
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
                'Joining ${_hive.name}',
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
                              model
                                  .joinHive(
                                      hiveId: _hive.id,
                                      roleId: role.name,
                                      userId: model.user.id)
                                  .then((_) => _retrieveHive(true))
                                  .then((_) => model.retrieveUserInfo())
                                  .then((_) => Navigator.pop(context));
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
                              model
                                  .leaveHive(
                                      hiveId: _hive.id,
                                      roleId: role.name,
                                      userId: role.user.id)
                                  .then((_) => _retrieveHive(true))
                                  .then((_) => model.retrieveUserInfo())
                                  .then((_) => Navigator.pop(context));
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

  Widget _giveUp() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      bool userHasRoles = _hive.takenRoles
          .any((takenRole) => takenRole.user.id == model.user.id);

      if (!userHasRoles) {
        return Container();
      } else {
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
                      'Leave all roles',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _confirmGiveUp(),
              );
            },
          ),
        );
      }
    });
  }

  Widget _confirmGiveUp() {
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
                'Leaving ${_hive.name}',
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
                      'Do you want to leave the hive?',
                      style: TextStyle(fontSize: 15),
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
                              'Confirm',
                              Colors.yellow,
                              model.loading,
                            ),
                            onTap: () {
                              model
                                  .giveUpHive(hiveId: widget.hiveId)
                                  .then((_) => _retrieveHive(true))
                                  .then((_) => model.retrieveUserInfo())
                                  .then((_) => Navigator.pop(context));
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

  bool _userAlreadyJoined(OpenRole role, Hive hive, User user) {
    bool result = false;

    hive.takenRoles.forEach((trole) {
      if (trole.user.id == user.id && trole.name == role.name) result = true;
    });
    return result;
  }
}
