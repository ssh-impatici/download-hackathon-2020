import 'package:flutter/material.dart';
import 'package:hackathon/classes/user.dart';

class Role {
  String id;
  String name;
  int score;

  Role({
    @required this.id,
    @required this.name,
    this.score,
  });
}

class OpenRole {
  Role role;
  int quantity;

  OpenRole({
    @required this.role,
    this.quantity = 1,
  });
}

class TakenRole {
  User user;
  Role role;

  TakenRole({
    @required this.user,
    @required this.role,
  });
}
