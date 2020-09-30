import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/classes/topic.dart';
import 'package:hackathon/scopedmodels/connected.dart';

mixin TopicsModel on ConnectedModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  _setLoading(bool newState) {
    loading = newState;
    notifyListeners();
  }

  Future<List<Topic>> getTopics() async {
    _setLoading(true);
    List<Topic> toReturn;

    QuerySnapshot snapshot = await _firestore.collection('topics').get();

    for (QueryDocumentSnapshot topic in snapshot.docs) {
      Map<String, dynamic> data = topic.data();

      List<Role> roles = await _retrieveRolesFromPaths(data['roles']);

      toReturn.add(Topic(
        id: topic.id,
        name: data['name'],
        roles: roles,
      ));
    }

    _setLoading(false);
    return toReturn;
  }

  Future<List<Role>> _retrieveRolesFromPaths(List<String> paths) async {
    List<Role> toReturn = [];

    for (String path in paths) {
      toReturn.add(await _retrieveRoleFromPath(path));
    }

    return toReturn;
  }

  Future<Role> _retrieveRoleFromPath(String path) async {
    DocumentSnapshot result = await _firestore.doc(path).get();

    if (result != null) {
      Map<String, dynamic> data = result.data();

      return Role(
        id: result.id,
        name: data['name'],
      );
    } else {
      return null;
    }
  }
}
