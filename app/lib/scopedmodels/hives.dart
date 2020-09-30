import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/topic.dart';
import 'package:hackathon/classes/user.dart';
import 'package:hackathon/scopedmodels/connected.dart';

mixin HivesModel on ConnectedModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  _setLoading(bool newState) {
    loading = newState;
    notifyListeners();
  }

  Future<List<Hive>> getMapHives() async {
    _setLoading(true);
    List<Hive> toReturn;

    try {
      // TODO: Call Cloud Function to get map hives
    } catch (e) {
      toReturn = null;
    }

    _setLoading(false);
    return toReturn;
  }

  Future<List<Hive>> getHives() async {
    _setLoading(true);
    List<Hive> toReturn;

    try {
      // TODO: Call Cloud Function to get hives
    } catch (e) {
      toReturn = null;
    }

    _setLoading(false);
    return toReturn;
  }

  Future<User> _retrieveUserFromPath(String path) async {
    try {
      DocumentSnapshot result = await _firestore.doc(path).get();

      if (result != null) {
        Map<String, dynamic> data = result.data();

        List<Topic> topics = await _retrieveTopicsFromNames(data['topics']);

        return User(
          id: result.id,
          name: data['name'],
          surname: data['surname'],
          email: data['email'],
          bio: data['bio'],
          topics: topics,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Topic>> _retrieveTopicsFromNames(List<String> names) async {
    if (names == null) {
      return null;
    }

    List<Topic> toReturn = [];

    for (String name in names) {
      Topic toAdd = await _retrieveTopicFromPath('topics/$name');

      if (toAdd != null) {
        toReturn.add(toAdd);
      }
    }

    return toReturn;
  }

  Future<Topic> _retrieveTopicFromPath(String path) async {
    try {
      DocumentSnapshot result = await _firestore.doc(path).get();

      if (result != null) {
        Map<String, dynamic> data = result.data();

        return Topic(
          id: result.id,
          roles: List<String>.from(data['roles']),
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
