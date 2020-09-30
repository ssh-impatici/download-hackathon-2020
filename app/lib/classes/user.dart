import 'package:flutter/material.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/topic.dart';

class User {
  String id;
  String name;
  String surname;
  String email;
  String bio;
  List<UserTopic> topics;
  List<Hive> hives;

  User({
    @required this.id,
    @required this.name,
    @required this.surname,
    @required this.email,
    this.bio,
    this.topics,
    this.hives,
  });

  String get fullName => '$name $surname';

  @override
  String toString() {
    return fullName;
  }
}
