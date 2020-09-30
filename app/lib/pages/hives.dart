import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:scoped_model/scoped_model.dart';

class HivesPage extends StatefulWidget {
  @override
  _HivesPageState createState() => _HivesPageState();
}

class _HivesPageState extends State<HivesPage> {
  //
  List<Hive> mockhives = [
    Hive(
        active: true,
        id: 'Hakcathon_ID',
        name: 'Hackathon',
        creator: null,
        description: 'Awesome hackathon project for download.io event!',
        openRoles: [],
        takenRoles: [],
        topics: [])
  ];

  @override
  Widget build(BuildContext context) {
    //
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) => Container(
        child: Column(children: listHiveWidgets(model.hivesList)),
      ),
    );
  }

  List<Widget> listHiveWidgets(List<Hive> list) {
    List<Widget> hiveswidgets = List<Widget>();
    list.forEach((hive) {
      hiveswidgets.add(hiveWidget(hive));
    });
    return hiveswidgets;
  }

  Widget hiveWidget(Hive hive) {
    return Container(
      child: Row(
        children: [
          Container(
            child: Column(
              children: [
                Text(hive.name),
                Text('Giorgio Bertolotti'),
                //Text(hive.creator.fullName),
                //Text(hive.topics.first.id)
              ],
            ),
          ),
          Flexible(child: _button())
        ],
      ),
    );
  }

  Widget _button() {
    return IconButton(
      onPressed: () {},
      icon: Icon(Icons.arrow_forward_ios),
    );
  }
}
