import 'package:flutter/material.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/classes/topic.dart';

class Hive {
  String id;
  String name;
  String description;
  bool active;
  // FIXME: Location typing, there is no example provided on firestore
  Object location;
  List<Topic> topics;
  List<OpenRole> openRoles;
  List<TakenRole> takenRoles;

  Hive({
    @required this.id,
    @required this.name,
    this.description,
    @required this.active,
    this.location,
    this.topics,
    this.openRoles,
    this.takenRoles,
  });
}
