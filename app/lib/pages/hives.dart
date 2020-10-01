import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/user.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:hackathon/widgets/hive_card.dart';
import 'package:scoped_model/scoped_model.dart';

class HivesPage extends StatefulWidget {
  @override
  _HivesPageState createState() => _HivesPageState();
}

class _HivesPageState extends State<HivesPage> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) => RefreshIndicator(
        onRefresh: _refreshHives,
        child: ListView(
          children: listHiveWidgets(model.user, model.hivesList),
        ),
      ),
    );
  }

  Future<void> _refreshHives() async {
    await ScopedModel.of<MainModel>(context).getHives();
    setState(() {});
  }

  List<Widget> listHiveWidgets(User user, List<Hive> list) {
    List<Widget> hiveswidgets = List<Widget>();

    // Page Title
    hiveswidgets.add(
      Container(
        margin: EdgeInsets.only(top: 30, left: 20, bottom: 10),
        child: Text(
          'Available Hives',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );

    // TODO: Search bar

    list.forEach((hive) {
      hiveswidgets.add(HiveCard(hive, user));
    });
    return hiveswidgets;
  }
}
