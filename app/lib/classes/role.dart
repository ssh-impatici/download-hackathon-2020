import 'package:flutter/material.dart';
import 'package:hackathon/classes/user.dart';

class RoleScoring {
  String name;
  int score;

  RoleScoring({
    @required this.name,
    @required this.score,
  });
}

class OpenRole {
  String name;
  int quantity;

  OpenRole({
    @required this.name,
    this.quantity = 1,
  });
}

class TakenRole {
  User user;
  String name;

  TakenRole({
    @required this.user,
    @required this.name,
  });
}
