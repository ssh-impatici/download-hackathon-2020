import 'dart:convert';

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

  Future<List<Hive>> getMapHives() async {
    _setLoading(true);
    List<Hive> toReturn = [];

    try {
      const url = '$apiEndpoint/getHivesMap';

      LocationPermission permission = await checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      Position position = await getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      Response response = await Dio().get(
        url,
        queryParameters: {
          'zoom': 2,
          'latitude': position.latitude,
          'longitude': position.longitude
        },
      );

      List<dynamic> json = response.data;

      for (Map<String, dynamic> element in json) {
        List<OpenRole> openRoles = [];
        for (dynamic openRole in element['openRoles']) {
          openRoles.add(OpenRole(
            name: openRole['name'],
            quantity: openRole['quantity'],
          ));
        }

        List<TakenRole> takenRoles = [];
        for (dynamic takenRole in element['takenRoles']) {
          User user = await _retrieveUserFromPath(takenRole['userRef']);

          takenRoles.add(TakenRole(
            name: takenRole['name'],
            user: user,
          ));
        }

        User creator = await _retrieveUserFromPath(element['creator']);
        List<Topic> topics = await _retrieveTopicsFromNames(
          List<String>.from(element['topics']),
        );

        toReturn.add(Hive(
          id: element['id'],
          creator: creator,
          name: element['name'],
          active: element['active'],
          description: element['description'],
          latitude: element['latitude'],
          longitude: element['longitude'],
          openRoles: openRoles,
          takenRoles: takenRoles,
          topics: topics,
        ));
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
    List<Hive> toReturn;

    try {
      const url = '$apiEndpoint/getHivesList';

      LocationPermission permission = await checkPermission();

      Map<String, dynamic> json;

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Response response = await Dio().request(
          url,
          data: jsonEncode({'userRef': 'users/${user.id}'}),
        );

        json = jsonDecode(response.data.toString());
      } else {
        Position position = await getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        Response response = await Dio().request(
          url,
          data: jsonEncode({
            'userRef': 'users/${user.id}',
            'userPosition': {
              'latitude': position.latitude,
              'longitude': position.longitude,
            }
          }),
        );

        json = jsonDecode(response.data.toString());
      }

      // TODO: Parse response
    } catch (e) {
      errorMessage = e.toString();
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
