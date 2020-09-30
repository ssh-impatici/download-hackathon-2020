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

  Future<Position> getPosition() async {
    LocationPermission permission = await checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return await getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
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
          return null;
        } else {
          position = LatLng(position.latitude, position.longitude);
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

  Future<List<Hive>> getHives() async {
    _setLoading(true);
    List<Hive> toReturn = [];

    try {
      const url = '$apiEndpoint/getHivesList';

      List<dynamic> json;

      Position position = await getPosition();
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
    } catch (e) {
      errorMessage = e.toString();
    }

    _setLoading(false);
    return toReturn;
  }

  // still have to test this
  Future<Hive> joinHive({String hiveId, String roleId, String userId}) async {
    _setLoading(true);

    Hive createdHive;
    dynamic json;

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
      json = response.data;
      createdHive = await _parseHive(json);
    } catch (e) {
      errorMessage = e.toString();
    }

    _setLoading(false);
    return createdHive;
  }

  Future<Hive> _parseHive(Map<String, dynamic> data) async {
    // Build open roles list
    List<OpenRole> openRoles = [];
    for (dynamic openRole in data['openRoles']) {
      openRoles.add(OpenRole(
        name: openRole['name'],
        quantity: openRole['quantity'],
      ));
    }

    // Build taken roles list
    List<TakenRole> takenRoles = [];
    for (dynamic takenRole in data['takenRoles']) {
      User user = await _retrieveUserFromPath(takenRole['userRef']);

      takenRoles.add(TakenRole(
        name: takenRole['name'],
        user: user,
      ));
    }

    // Build creator and topics list
    User creator = await _retrieveUserFromPath(data['creator']);
    List<Topic> topics = await _retrieveTopicsFromNames(
      List<String>.from(data['topics']),
    );

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

        for (dynamic topic in data['topics']) {
          topics.add(UserTopic(
            id: topic['id'],
            reviews: topic['reviews'],
            stars: topic['stars'],
          ));
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
