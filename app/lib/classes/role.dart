import 'package:hackathon/classes/user.dart';

class Role {
  String id;
  String name;

  Role({this.id, this.name});
}

class OpenRole {
  Role role;
  int quantity;

  OpenRole({this.role, this.quantity});
}

class TakenRole {
  User user;
  Role role;

  TakenRole({this.user, this.role});
}
