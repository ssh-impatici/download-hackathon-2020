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

      result = AuthResult.SIGNEDUP;
    } catch (e) {
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

      user = await retrieveUserInfo();

      if (user != null) {
        result = AuthResult.SIGNEDIN;
      } else {
        result = AuthResult.SIGNEDUP;
      }
    } catch (e) {
      result = AuthResult.UNAUTHORIZED;
      errorMessage = e.toString();
    }

    _setLoading(false);
    return result;
  }

  Future<AuthResult> logout() async {
    _setLoading(true);

    try {
      await _auth.signOut();
    } catch (e) {
      errorMessage = e.toString();
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

      user = await retrieveUserInfo();

      if (user != null) {
        result = AuthResult.SIGNEDIN;
      } else {
        result = AuthResult.SIGNEDUP;
      }
    } catch (e) {
      result = AuthResult.UNAUTHORIZED;
      errorMessage = e.toString();
    }

    _setLoading(false);
    return result;
  }

  Future<AuthResult> signoutGoogle() async {
    _setLoading(true);

    try {
      await _googleSignIn.signOut();
    } catch (e) {
      errorMessage = e.toString();
    }

    _setLoading(false);
    return AuthResult.UNAUTHORIZED;
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

      List<Topic> topics = await _retrieveTopicsFromNames(data['topics']);
      List<Hive> hives = await _retrieveHivesFromPaths(data['hives']);

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
    User user = _auth.currentUser;

    if (user == null) {
      return AuthResult.SIGNEDUP;
    }

    _setLoading(true);
    AuthResult result;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'surname': surname,
        'email': user.email,
        'bio': bio,
        'topics': topics,
      });

      result = AuthResult.SIGNEDIN;
    } catch (e) {
      result = AuthResult.SIGNEDUP;
    }

    _setLoading(false);
    return result;
  }

  Future<List<Hive>> _retrieveHivesFromPaths(List<String> paths) async {
    List<Hive> toReturn = [];

    for (String path in paths) {
      toReturn.add(await _retrieveHiveFromPath(path));
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
        List<Topic> topics = await _retrieveTopicsFromNames(data['topics']);

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

        List<Topic> topics = await _retrieveTopicsFromNames(data['topics']);

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
    List<Topic> toReturn = [];

    for (String name in names) {
      toReturn.add(await _retrieveTopicFromPath('topics/$name'));
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
          roles: data['roles'],
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
