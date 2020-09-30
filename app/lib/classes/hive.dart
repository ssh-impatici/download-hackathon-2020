import 'package:flutter/material.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/classes/topic.dart';
import 'package:hackathon/classes/user.dart';

class Hive {
  String id;
  String name;
  User creator;
  String description;
  bool active;
  double latitude;
  double longitude;
  List<Topic> topics;
  List<OpenRole> openRoles;
  List<TakenRole> takenRoles;

  Hive({
    @required this.id,
    @required this.creator,
    @required this.name,
    this.description,
    @required this.active,
    this.latitude,
    this.longitude,
    this.topics,
    this.openRoles,
    this.takenRoles,
  });

  @override
  String toString() {
    return this.name;
  }
}
