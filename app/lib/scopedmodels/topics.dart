import 'package:cloud_firestore/cloud_firestore.dart';
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

    try {
      QuerySnapshot snapshot = await _firestore.collection('topics').get();

      for (QueryDocumentSnapshot topic in snapshot.docs) {
        Map<String, dynamic> data = topic.data();

        toReturn.add(Topic(
          id: topic.id,
          name: data['name'],
          roles: data['roles'],
        ));
      }
    } catch (e) {
      toReturn = null;
    }

    _setLoading(false);
    return toReturn;
  }

  Future<Topic> getTopic({String id}) async {
    if (id == null) {
      return null;
    }

    _setLoading(true);
    Topic toReturn;

    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('topics').doc(id).get();

      Map<String, dynamic> data = snapshot.data();

      toReturn = Topic(
        id: snapshot.id,
        name: data['name'],
        roles: data['roles'],
      );
    } catch (e) {
      toReturn = null;
    }

    _setLoading(false);
    return toReturn;
  }
}
