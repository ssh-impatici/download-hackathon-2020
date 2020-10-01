import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/topic.dart';
import 'package:hackathon/classes/user.dart';
import 'package:scoped_model/scoped_model.dart';

mixin ConnectedModel on Model {
  bool loading = false;
  bool googling = false;
  bool authenticated = false;
  User user;
  String errorMessage;
  List<Topic> topics = [];
  List<Hive> hivesMap = [];
  List<Hive> hivesList = [];
  Position position;

  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  void addNotificationTopics(List<String> topics) async {
    topics.forEach((topic) {
      firebaseMessaging.subscribeToTopic(topic);
    });
  }

  setLoading(bool value) {
    loading = value;
    notifyListeners();
  }
}
