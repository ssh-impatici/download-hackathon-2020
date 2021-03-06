import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/classes/topic.dart';
import 'package:hackathon/classes/user.dart';
import 'package:hackathon/scopedmodels/connected.dart';
import 'package:hackathon/utils/api.dart';
import 'package:dio/dio.dart';

mixin HivesModel on ConnectedModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  _setLoading(bool newState) {
    loading = newState;
    notifyListeners();
  }

  Future<void> initHives() async {
    await getHives();
    await getMapHives();
  }

  Future<Position> getPosition() async {
    try {
      LocationPermission permission = await checkPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        position = await getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        );
        return position;
      }

      permission = await requestPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        position = await getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        );
        return position;
      }
    } catch (e) {
      // Time limit reached
      return position;
    }

    return position;
  }

  Future<List<Hive>> getMapHives({LatLng latLng}) async {
    _setLoading(true);
    List<Hive> toReturn = [];

    try {
      const url = '$apiEndpoint/getHivesMap';

      LatLng position = latLng;

      if (position == null) {
        Position pos = await getPosition();

        if (pos == null) {
          _setLoading(false);
          return null;
        } else {
          position = LatLng(pos.latitude, pos.longitude);
        }
      }

      Response response = await Dio().get(
        url,
        queryParameters: {
          'zoom': 2,
          'latitude': position.latitude,
          'longitude': position.longitude
        },
      );

      List<dynamic> json = response.data;

      // Loop through the hives
      for (Map<String, dynamic> element in json) {
        toReturn.add(await _parseHive(element));
      }
    } catch (e) {
      errorMessage = e.toString();
      toReturn = null;
    }

    // Set the hives list in connected to the retrieved ones
    hivesMap = toReturn;

    _setLoading(false);
    return toReturn;
  }

  Future<List<Hive>> getHives({LatLng latLng}) async {
    _setLoading(true);
    List<Hive> toReturn = [];

    try {
      const url = '$apiEndpoint/getHivesList';

      List<dynamic> json;

      LatLng position = latLng;

      if (position == null) {
        Position pos = await getPosition();

        if (pos != null) {
          position = LatLng(pos.latitude, pos.longitude);
        }
      }

      if (position == null) {
        Response response = await Dio().get(
          url,
          queryParameters: {
            'userRef': 'users/${user.id}',
          },
        );

        json = response.data;
      } else {
        Response response = await Dio().get(
          url,
          queryParameters: {
            'userRef': 'users/${user.id}',
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        );

        json = response.data;
      }

      // Loop through the hives
      for (Map<String, dynamic> element in json) {
        toReturn.add(await _parseHive(element));
      }
    } catch (e) {
      errorMessage = e.toString();
      toReturn = null;
    }

    // Set the hives list in connected to the retrieved ones
    hivesList = toReturn;

    _setLoading(false);
    return toReturn;
  }

  Future<Hive> createHive({
    String name,
    String description,
    double latitude,
    double longitude,
    String address,
    List<OpenRole> openRoles,
    List<String> topics,
  }) async {
    _setLoading(true);
    Hive toReturn;

    try {
      const url = '$apiEndpoint/createHive';

      Response response = await Dio().post(
        url,
        data: {
          'name': name,
          'creator': 'users/${user.id}',
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          'openRoles': openRoles,
          'topics': topics,
          'address': address
        },
      );

      Map<String, dynamic> json = response.data;
      toReturn = await _parseHive(json);
      addNotificationTopics([toReturn.id]);
    } catch (e) {
      errorMessage = e.toString();
    }

    _setLoading(false);
    return toReturn;
  }

  Future<Hive> joinHive({String hiveId, String roleId, String userId}) async {
    _setLoading(true);
    Hive joinedHive;

    try {
      const url = '$apiEndpoint/joinHive';

      Response response = await Dio().post(
        url,
        data: {
          'hiveRef': 'hives/$hiveId',
          'roleRef': roleId,
          'userRef': 'users/$userId'
        },
      );

      Map<String, dynamic> json = response.data;

      joinedHive = await _parseHive(json);

      // Update hives map
      hivesMap.where((hive) => hive.id == hiveId).forEach((hive) {
        hive.openRoles = joinedHive.openRoles;
        hive.takenRoles = joinedHive.takenRoles;
      });

      // Update hives list
      hivesList.where((hive) => hive.id == hiveId).forEach((hive) {
        hive.openRoles = joinedHive.openRoles;
        hive.takenRoles = joinedHive.takenRoles;
      });
    } catch (e) {
      errorMessage = e.toString();
    }

    _setLoading(false);
    return joinedHive;
  }

  Future<Hive> leaveHive({String hiveId, String roleId, String userId}) async {
    _setLoading(true);
    Hive leftHive;

    try {
      const url = '$apiEndpoint/leaveHive';

      Response response = await Dio().post(
        url,
        data: {
          'hiveRef': 'hives/$hiveId',
          'roleRef': roleId,
          'userRef': 'users/$userId'
        },
      );

      Map<String, dynamic> json = response.data;

      leftHive = await _parseHive(json);

      // Update hives map
      hivesMap.where((hive) => hive.id == hiveId).forEach((hive) {
        hive.openRoles = leftHive.openRoles;
        hive.takenRoles = leftHive.takenRoles;
      });

      // Update hives list
      hivesList.where((hive) => hive.id == hiveId).forEach((hive) {
        hive.openRoles = leftHive.openRoles;
        hive.takenRoles = leftHive.takenRoles;
      });
    } catch (e) {
      errorMessage = e.toString();
    }

    _setLoading(false);
    return leftHive;
  }

  Future<void> giveUpHive({String hiveId}) async {
    if (user.hives == null || user.hives.isEmpty) {
      return;
    }

    Hive hive = user.hives.firstWhere((hive) => hive.id == hiveId);

    if (hive == null || hive.takenRoles == null || hive.takenRoles.isEmpty) {
      return;
    }

    for (TakenRole role in hive.takenRoles) {
      await leaveHive(hiveId: hiveId, roleId: role.name, userId: user.id);
    }
  }

  Future<Hive> _parseHive(Map<String, dynamic> data) async {
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
        User user = await _retrieveUserFromPath(takenRole['userRef']);

        takenRoles.add(TakenRole(
          name: takenRole['name'],
          user: user,
        ));
      }
    }

    // Build creator and topics list
    User creator = data['creator'] != null
        ? await _retrieveUserFromPath(data['creator'])
        : null;
    List<Topic> topics = data['topics'] != null
        ? await _retrieveTopicsFromNames(List<String>.from(data['topics']))
        : [];

    return Hive(
      id: data['hiveId'],
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
  }

  Future<User> _retrieveUserFromPath(String path) async {
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
