import 'package:flutter/material.dart';
import 'package:hackathon/classes/role.dart';
import 'package:intl/intl.dart';

class RoleScoringTile extends StatelessWidget {
  final RoleScoring roleScoring;

  RoleScoringTile(this.roleScoring);

  @override
  Widget build(BuildContext context) {
    String compactNumber =
        NumberFormat.compact(locale: 'it-IT').format(roleScoring.reviews);

    return Container(
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              roleScoring.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '($compactNumber)',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(width: 10),
              Text(
                roleScoring.stars.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4.0),
              Icon(
                Icons.star,
                color: Colors.yellow,
                size: 16.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
