import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/classes/topic.dart';
import 'package:hackathon/classes/user.dart' as Model;
import 'package:hackathon/scopedmodels/connected.dart';
import 'package:hackathon/utils/enums.dart';

mixin AuthModel on ConnectedModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  _setLoading(bool newState) {
    loading = newState;
    notifyListeners();
  }

  // Firebase email/password auth methods

  Future<AuthResult> createUserWithEmailAndPassword({
    String email,
    String password,
  }) async {
    _setLoading(true);
    AuthResult result;

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set the authenticated flag in connected model
      authenticated = true;

      result = AuthResult.SIGNEDUP;
    } catch (e) {
      authenticated = false;
      result = AuthResult.UNAUTHORIZED;
      errorMessage = e.toString();
    }

    _setLoading(false);
    return result;
  }

  Future<AuthResult> login({
    String email,
    String password,
  }) async {
    _setLoading(true);
    AuthResult result;

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set the authenticated flag in connected model
      authenticated = true;

      user = await retrieveUserInfo();

      if (user != null) {
        result = AuthResult.SIGNEDIN;
      } else {
        result = AuthResult.SIGNEDUP;
      }
    } catch (e) {
      authenticated = false;
      result = AuthResult.UNAUTHORIZED;
      errorMessage = e.toString();
    }

    _setLoading(false);
    return result;
  }

  Future<AuthResult> logout() async {
    _setLoading(true);

    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      if (_auth.currentUser != null) {
        await _auth.signOut();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      authenticated = false;
    }

    _setLoading(false);
    return AuthResult.UNAUTHORIZED;
  }

  // Firebase google sign-in methods

  Future<AuthResult> signInWithGoogle() async {
    _setLoading(true);
    AuthResult result;

    try {
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      await _auth.signInWithCredential(credential);

      // Set the authenticated flag in connected model
      authenticated = true;

      // Set the user info in connected model
      user = await retrieveUserInfo();

      if (user != null) {
        result = AuthResult.SIGNEDIN;
      } else {
        result = AuthResult.SIGNEDUP;
      }
    } catch (e) {
      authenticated = false;
      result = AuthResult.UNAUTHORIZED;
      errorMessage = e.toString();
    }

    _setLoading(false);
    return result;
  }

  // Cloud Firestore user methods

  Future<Model.User> retrieveUserInfo() async {
    User user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    DocumentSnapshot result =
        await _firestore.collection('users').doc(user.uid).get();

    if (result != null) {
      Map<String, dynamic> data = result.data();

      if (data == null) {
        return null;
      }

      List<UserTopic> topics = [];

      for (dynamic topic in data['topics']) {
        topics.add(UserTopic(
          id: topic['id'],
          reviews: topic['reviews'],
          stars: topic['stars'],
        ));
      }

      List<Hive> hives = data['hives'] != null
          ? await _retrieveHivesFromPaths(List<String>.from(data['hives']))
          : null;

      return Model.User(
        id: result.id,
        name: data['name'],
        surname: data['surname'],
        email: data['email'],
        bio: data['bio'],
        topics: topics,
        hives: hives,
      );
    } else {
      return null;
    }
  }

  Future<AuthResult> addUserInfo({
    String name,
    String surname,
    String bio,
    List<String> topics,
  }) async {
    User currentUser = _auth.currentUser;

    if (currentUser == null) {
      return AuthResult.SIGNEDUP;
    }

    _setLoading(true);
    AuthResult result;

    try {
      await _firestore.collection('users').doc(currentUser.uid).set({
        'name': name,
        'surname': surname,
        'email': currentUser.email,
        'bio': bio,
        'topics': topics
            .map(
              (topic) => {'id': topic, 'reviews': 0, 'stars': 0},
            )
            .toList(),
      });

      // Set the authenticated flag in connected model
      authenticated = true;

      // Set the user info in connected model
      user = await retrieveUserInfo();

      if (user != null) {
        result = AuthResult.SIGNEDIN;
      } else {
        result = AuthResult.SIGNEDUP;
      }
    } catch (e) {
      result = AuthResult.SIGNEDUP;
    }

    _setLoading(false);
    return result;
  }

  Future<List<Hive>> _retrieveHivesFromPaths(List<String> paths) async {
    if (paths == null) {
      return null;
    }

    List<Hive> toReturn = [];

    for (String path in paths) {
      Hive toAdd = await _retrieveHiveFromPath(path);

      if (toAdd != null) {
        toReturn.add(toAdd);
      }
    }

    return toReturn;
  }

  Future<Hive> _retrieveHiveFromPath(String path) async {
    try {
      DocumentSnapshot result = await _firestore.doc(path).get();

      if (result != null) {
        Map<String, dynamic> data = result.data();

        List<OpenRole> openRoles = [];
        for (dynamic openRole in data['openRoles']) {
          openRoles.add(OpenRole(
            name: openRole['name'],
            quantity: openRole['quantity'],
          ));
        }

        List<TakenRole> takenRoles = [];
        for (dynamic takenRole in data['takenRoles']) {
          Model.User user = await _retrieveUserFromPath(takenRole['userRef']);

          takenRoles.add(TakenRole(
            name: takenRole['name'],
            user: user,
          ));
        }

        Model.User creator = await _retrieveUserFromPath(data['creator']);
        List<Topic> topics =
            await _retrieveTopicsFromNames(List<String>.from(data['topics']));

        return Hive(
          id: result.id,
          name: data['name'],
          creator: creator,
          active: data['active'],
          description: data['description'],
          latitude: data['latitude'],
          longitude: data['longitude'],
          openRoles: openRoles,
          takenRoles: takenRoles,
          topics: topics,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Model.User> _retrieveUserFromPath(String path) async {
    try {
      DocumentSnapshot result = await _firestore.doc(path).get();

      if (result != null) {
        Map<String, dynamic> data = result.data();

        List<UserTopic> topics = [];

        for (dynamic topic in data['topics']) {
          topics.add(UserTopic(
            id: topic['id'],
            reviews: topic['reviews'],
            stars: topic['stars'],
          ));
        }

        return Model.User(
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
