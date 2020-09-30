import 'package:flutter/material.dart';
import 'package:hackathon/classes/role.dart';

class Topic {
  String id;
  String name;
  List<Role> roles;

  Topic({
    @required this.id,
    @required this.name,
    @required this.roles,
  });
}
