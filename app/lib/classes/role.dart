import 'package:flutter/material.dart';
import 'package:hackathon/classes/user.dart';

class RoleScoring {
  String name;
  int score;

  RoleScoring({
    @required this.name,
    @required this.score,
  });

  @override
  String toString() {
    return '$name: $score';
  }
}

class OpenRole {
  String name;
  int quantity;

  OpenRole({
    @required this.name,
    this.quantity = 1,
  });

  OpenRole.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        quantity = json['quantity'];

  @override
  String toString() {
    return 'x$quantity $name';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
    };
  }
}

class TakenRole {
  User user;
  String name;

  TakenRole({
    @required this.user,
    @required this.name,
  });

  @override
  String toString() {
    return '$user - $name';
  }
}
