import 'package:flutter/material.dart';

class Topic {
  String id;
  String name;
  List<String> roles;

  Topic({
    @required this.id,
    @required this.name,
    @required this.roles,
  });
}
