import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/topic.dart';

class User {
  String id;
  String name;
  String surname;
  String email;
  String bio;
  List<Topic> topics;
  List<Hive> hives;

  User({
    this.id,
    this.name,
    this.surname,
    this.email,
    this.bio,
    this.topics,
    this.hives,
  });
}
