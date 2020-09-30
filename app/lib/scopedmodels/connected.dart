import 'package:hackathon/classes/user.dart';
import 'package:scoped_model/scoped_model.dart';

mixin ConnectedModel on Model {
  bool loading = false;
  User user;
  String errorMessage;
}
