import 'package:flutter/material.dart';
import 'package:hackathon/classes/role.dart';

class Topic {
  String id;
  List<String> roles;

  Topic({
    @required this.id,
    @required this.roles,
  });

  @override
  String toString() {
    return this.id;
  }
}

class UserTopic {
  String id;
  List<RoleScoring> scorings;

  UserTopic({
    @required this.id,
    @required this.scorings,
  });

  @override
  String toString() {
    return this.id;
  }
}
