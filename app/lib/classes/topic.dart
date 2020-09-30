import 'package:flutter/material.dart';

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
  int reviews;
  int stars;

  UserTopic({
    @required this.id,
    @required this.reviews,
    @required this.stars,
  });

  @override
  String toString() {
    return this.id;
  }
}
