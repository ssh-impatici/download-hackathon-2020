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

  _setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  Future<void> initUser() async {
    await retrieveUserInfo();
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

      await retrieveUserInfo();

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

  Future<AuthResult> autoSignIn() async {
    _setLoading(true);
    AuthResult result;

    try {
      User currentUser = _auth.currentUser;

      if (currentUser != null) {
        authenticated = true;

        await retrieveUserInfo();

        if (user != null) {
          result = AuthResult.SIGNEDIN;
        } else {
          result = AuthResult.SIGNEDUP;
        }
      } else {
        authenticated = false;
        result = AuthResult.UNAUTHORIZED;
      }
    } catch (e) {
      authenticated = false;
      result = AuthResult.UNAUTHORIZED;
      errorMessage = e.toString();
    }

    authenticated = false;

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

    authenticated = false;

    _setLoading(false);
    return AuthResult.UNAUTHORIZED;
  }

  // Firebase google sign-in methods

  Future<AuthResult> signInWithGoogle() async {
    _setGoogling(true);
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
      await retrieveUserInfo();

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

    _setGoogling(false);
    return result;
  }

  // Cloud Firestore user methods

  Future<Model.User> retrieveUserInfo() async {
    User currentUser = _auth.currentUser;

    if (currentUser == null) {
      return null;
    }

    DocumentSnapshot result =
        await _firestore.collection('users').doc(currentUser.uid).get();

    if (result != null) {
      Map<String, dynamic> data = result.data();

      if (data == null) {
        return null;
      }

      List<UserTopic> topics = [];

      if (data['topics'] != null) {
        for (Map<String, dynamic> topic in data['topics']) {
          String id = topic.keys.first;
          List<RoleScoring> scorings = [];

          for (Map<String, dynamic> scoringData in topic[id]) {
            scorings.add(RoleScoring(
              name: scoringData['name'],
              reviews: scoringData['reviews'],
              stars: scoringData['stars'].toDouble(),
            ));
          }

          topics.add(UserTopic(
            id: id,
            scorings: scorings,
          ));
        }
      }

      List<Hive> hives = [];

      if (data['hives'] != null) {
        for (dynamic hiveData in data['hives']) {
          hives.add(await _retrieveHiveFromPath(hiveData['hiveRef']));
        }
      }

      user = Model.User(
        id: result.id,
        name: data['name'],
        surname: data['surname'],
        email: data['email'],
        bio: data['bio'],
        topics: topics,
        hives: hives,
      );

      return user;
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
              (topic) => {topic: []},
            )
            .toList(),
      });

      // Set the authenticated flag in connected model
      authenticated = true;

      // Set the user info in connected model
      await retrieveUserInfo();

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

  Future<Hive> _retrieveHiveFromPath(String path) async {
    try {
      DocumentSnapshot result = await _firestore.doc(path).get();

      if (result != null) {
        Map<String, dynamic> data = result.data();

        // Build open roles list
        List<OpenRole> openRoles = [];
        if (data['openRoles'] != null) {
          for (dynamic openRole in data['openRoles']) {
            openRoles.add(OpenRole(
              name: openRole['name'],
              quantity: openRole['quantity'],
            ));
          }
        }

        // Build taken roles list
        List<TakenRole> takenRoles = [];
        if (data['takenRoles'] != null) {
          for (dynamic takenRole in data['takenRoles']) {
            Model.User user = await _retrieveUserFromPath(takenRole['userRef']);

            takenRoles.add(TakenRole(
              name: takenRole['name'],
              user: user,
            ));
          }
        }

        // Build creator and topics list
        Model.User creator = data['creator'] != null
            ? await _retrieveUserFromPath(data['creator'])
            : null;
        List<Topic> topics = data['topics'] != null
            ? await _retrieveTopicsFromNames(List<String>.from(data['topics']))
            : [];

        return Hive(
          id: result.id,
          name: data['name'],
          creator: creator,
          active: data['active'],
          description: data['description'],
          address: data['address'],
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

        if (data['topics'] != null) {
          for (Map<String, dynamic> topic in data['topics']) {
            String id = topic.keys.first;
            List<RoleScoring> scorings = [];

            for (Map<String, dynamic> scoringData in topic[id]) {
              scorings.add(RoleScoring(
                name: scoringData['name'],
                reviews: scoringData['reviews'],
                stars: scoringData['stars'].toDouble(),
              ));
            }

            topics.add(UserTopic(
              id: id,
              scorings: scorings,
            ));
          }
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

  void _setGoogling(bool value) {
    googling = value;
    notifyListeners();
  }
}
