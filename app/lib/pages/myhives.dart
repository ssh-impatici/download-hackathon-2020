import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:hackathon/widgets/hive.dart';
import 'package:scoped_model/scoped_model.dart';

class MyHivesPage extends StatefulWidget {
  @override
  _MyHivesPageState createState() => _MyHivesPageState();
}

class _MyHivesPageState extends State<MyHivesPage> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshMyHives,
      child: SingleChildScrollView(
        child: ScopedModelDescendant<MainModel>(
          builder: (context, child, model) => Container(
            child: Column(children: listHiveWidgets(model.user.hives)),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshMyHives() async {
    await ScopedModel.of<MainModel>(context).retrieveUserInfo();
  }

  List<Widget> listHiveWidgets(List<Hive> list) {
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

    list.forEach((hive) {
      hiveswidgets.add(hiveWidget(hive));
    });
    return hiveswidgets;
  }

  Widget hiveWidget(Hive hive) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      width: MediaQuery.of(context).size.width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HiveDescription(hive.id, FromScreen.MY_HIVES),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          hive.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        padding: EdgeInsets.only(bottom: 15),
                      ),
                      Container(
                        child: Text(
                            hive.creator != null ? hive.creator.fullName : ''),
                        padding: EdgeInsets.only(bottom: 20),
                      ),
                      _openRoles(hive.openRoles)
                    ],
                  ),
                ),
                Flexible(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.yellow,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _openRoles(List<OpenRole> list) {
    return list.length > 1
        ? Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  list.first.name,
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
              SizedBox(width: 20),
              Text(
                '+${list.length - 1} \t more..',
                style: TextStyle(color: Colors.yellow, fontSize: 12),
              )
            ],
          )
        : list.isNotEmpty
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  list.first.name,
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ))
            : Container();
  }
}
