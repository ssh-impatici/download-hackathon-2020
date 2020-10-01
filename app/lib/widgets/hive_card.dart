import 'package:flutter/material.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/classes/user.dart';
import 'package:hackathon/widgets/hive.dart';

class HiveCard extends StatelessWidget {
  final Hive hive;
  final User user;

  HiveCard(this.hive, this.user);

  @override
  Widget build(BuildContext context) {
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
                builder: (context) => HiveDescription(hive.id, FromScreen.LIST),
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
                        margin: EdgeInsets.only(bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            hive.address == null
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.yellow,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                      vertical: 4.0,
                                    ),
                                    margin: EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      Icons.location_off,
                                      size: 14.0,
                                      color: Colors.black,
                                    ),
                                  )
                                : Container(),
                            Container(
                              child: Text(
                                hive.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            hive.creator.id == user.id
                                ? Icon(
                                    Icons.vpn_key,
                                    size: 14.0,
                                    color: Colors.yellow,
                                  )
                                : Container(),
                            Text(hive.creator != null
                                ? hive.creator.fullName
                                : ''),
                          ],
                        ),
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
