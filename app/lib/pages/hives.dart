import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
        child: listHiveWidget(model),
      ),
    );
  }

  Future<void> _refreshHives() async {
    await ScopedModel.of<MainModel>(context).getHives();
  }

  Widget listHiveWidget(MainModel model) {
    List<Widget> hivesWidget = List<Widget>();

    // Page Title
    hivesWidget.add(
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

    if (model.hivesList == null || model.hivesList.isEmpty) {
      return ListView(
        children: hivesWidget,
      );
    }

    Position location = model.position;

    model.hivesList.forEach((hive) {
      hivesWidget.add(HiveCard(
        hive,
        model.user,
        location: location,
      ));
    });

    return ListView(
      children: hivesWidget,
    );
  }
}
