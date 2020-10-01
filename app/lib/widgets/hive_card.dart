import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/classes/user.dart';
import 'package:hackathon/utils/distance.dart';
import 'package:hackathon/widgets/hive.dart';

class HiveCard extends StatelessWidget {
  final Hive hive;
  final User user;
  final Position location;

  HiveCard(this.hive, this.user, {this.location});

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
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _typeIcon(context),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                hive.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                            Text(hive.creator != null
                                ? hive.creator.fullName
                                : ''),
                            hive.creator.id == user.id
                                ? Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Icon(
                                      Icons.vpn_key,
                                      size: 15,
                                      color: Colors.yellow,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      _openRoles(hive.openRoles)
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.yellow,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeIcon(BuildContext context) {
    if (hive.latitude == null || hive.longitude == null) {
      return Container(
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
      );
    } else {
      if (location == null ||
          location.latitude == null ||
          location.longitude == null) {
        return Container();
      }

      String dist = distance(
        lat1: location.latitude,
        lon1: location.longitude,
        lat2: hive.latitude,
        lon2: hive.longitude,
      );

      return Container(
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(4.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 6.0,
          vertical: 4.0,
        ),
        margin: EdgeInsets.only(right: 8.0),
        child: Text(
          '$dist km',
          style: TextStyle(
            fontSize: 10,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
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
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(width: 12.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  '+${list.length - 1} more',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
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
