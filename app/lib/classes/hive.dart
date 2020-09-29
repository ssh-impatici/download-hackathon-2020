import 'package:hackathon/classes/role.dart';
import 'package:hackathon/classes/topic.dart';

class Hive {
  String name;
  String description;
  bool active;
  // FIXME: Location typing, there is no example provided on firestore
  Object location;
  List<Topic> topics;
  List<OpenRole> openRoles;
  List<TakenRole> takenRoles;

  Hive({
    this.name,
    this.description,
    this.active,
    this.location,
    this.topics,
    this.openRoles,
    this.takenRoles,
  });
}
