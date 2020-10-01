import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/classes/user.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:hackathon/widgets/hive.dart';
import 'package:hackathon/widgets/hive_card.dart';
import 'package:scoped_model/scoped_model.dart';

class MyHivesPage extends StatefulWidget {
  @override
  _MyHivesPageState createState() => _MyHivesPageState();
}

class _MyHivesPageState extends State<MyHivesPage> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) => RefreshIndicator(
        onRefresh: _refreshMyHives,
        child: ListView(
          children: listHiveWidgets(model.user),
        ),
      ),
    );
  }

  Future<void> _refreshMyHives() async {
    await ScopedModel.of<MainModel>(context).retrieveUserInfo();
    setState(() {});
  }

  List<Widget> listHiveWidgets(User user) {
    print(user.hives);
    List<Widget> hiveswidgets = List<Widget>();

    // Page Title
    hiveswidgets.add(
      Container(
        margin: EdgeInsets.only(top: 30, left: 20, bottom: 10),
        child: Text(
          'My Hives',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );

    user.hives.forEach((hive) {
      hiveswidgets.add(HiveCard(hive, user));
    });
    return hiveswidgets;
  }
}
