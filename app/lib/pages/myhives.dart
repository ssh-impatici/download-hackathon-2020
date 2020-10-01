import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hackathon/classes/user.dart';
import 'package:hackathon/scopedmodels/main.dart';
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
        child: listHiveWidgets(model),
      ),
    );
  }

  Future<void> _refreshMyHives() async {
    await ScopedModel.of<MainModel>(context).retrieveUserInfo();
    setState(() {});
  }

  Widget listHiveWidgets(MainModel model) {
    List<Widget> hivesWidgets = List<Widget>();

    // Page Title
    hivesWidgets.add(
      Container(
        margin: EdgeInsets.only(top: 30, left: 20, bottom: 10),
        child: Text(
          'My Hives',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );

    if (model.user.hives == null || model.user.hives.isEmpty) {
      return ListView(
        children: hivesWidgets,
      );
    }

    Position location = model.position;

    model.user.hives.forEach((hive) {
      hivesWidgets.add(HiveCard(
        hive,
        model.user,
        location: location,
      ));
    });

    return ListView(
      children: hivesWidgets,
    );
  }
}
