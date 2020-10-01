import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String distance({
  @required double lat1,
  @required double lon1,
  @required double lat2,
  @required double lon2,
}) {
  double theta = lon1 - lon2;
  double dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) +
      cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta));
  dist = acos(dist);
  dist = rad2deg(dist);
  dist = dist * 60 * 1.1515;
  // Conversion to Km
  dist = dist * 1.609344;
  return dist.toStringAsFixed(1);
}

double deg2rad(double deg) {
  return (deg * pi / 180.0);
}

double rad2deg(double rad) {
  return (rad * 180.0 / pi);
}

LatLng randomLocation({
  LatLng aroundPosition = const LatLng(45.642389, 9.5858929),
}) {
  return LatLng(
    aroundPosition.latitude + ((Random().nextInt(100) - 50) / 10000),
    aroundPosition.longitude + ((Random().nextInt(100) - 50) / 10000),
  );
}
