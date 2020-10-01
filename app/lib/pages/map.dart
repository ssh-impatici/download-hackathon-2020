import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/topic.dart';
import 'package:hackathon/pages/create.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:hackathon/widgets/hive.dart';
import 'package:scoped_model/scoped_model.dart';

class MapPage extends StatefulWidget {
  final MainModel model;
  MapPage(this.model);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController _mapController;
  bool interestingTopics = false;
  Set<Marker> _markers = Set<Marker>();

  LatLng _center = const LatLng(45.6918992, 9.6749658);

  @override
  void initState() {
    _initializeMarkers();
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Automatically move the map camera to the user position
    _moveToMyLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ScopedModelDescendant<MainModel>(
          builder: (context, child, model) => Stack(
            children: [_map(), _controlPanel(), _add()],
          ),
        ),
      ),
    );
  }

  _initializeMarkers() async {
    _markers.clear();

    if (widget.model.hivesMap == null) {
      return null;
    }

    for (Hive hive in widget.model.hivesMap) {
      Marker toAdd = Marker(
        markerId: MarkerId(hive.id),
        position: LatLng(hive.latitude, hive.longitude),
        icon: BitmapDescriptor.fromBytes(
          await _getBytesFromAsset('assets/images/beehive.png', 100),
        ),
        infoWindow: InfoWindow(
          title: hive.name,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HiveDescription(hive.id, FromScreen.MAP),
              ),
            );
          },
        ),
      );

      setState(() {
        _markers.add(toAdd);
      });
    }
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Widget _map() {
    Set<Marker> _showedmarkers;
    if (interestingTopics) {
      _showedmarkers = _filteredMarkers(
          _markers, widget.model.user.topics, widget.model.hivesMap);
    } else
      _showedmarkers = _markers;

    return GoogleMap(
      onMapCreated: _onMapCreated,
      markers: _showedmarkers,
      zoomControlsEnabled: false,
      // Shows the blue dot on the current position
      myLocationEnabled: true,
      // Disables the button to go to current position
      myLocationButtonEnabled: false,
      // Disabled the controls for the markers
      mapToolbarEnabled: false,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 14.0,
      ),
    );
  }

  Widget _controlPanel() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Material(
        elevation: 5,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [_switch(), _reload(), _myPosition()],
          ),
        ),
      ),
    );
  }

  Widget _switch() {
    return Tooltip(
      message: 'Topics Filter',
      child: Switch(
        activeColor: Colors.grey.shade800.withOpacity(1),
        activeTrackColor: Colors.grey.shade600.withOpacity(1),
        inactiveTrackColor: Colors.grey.shade400.withOpacity(1),
        value: interestingTopics,
        onChanged: (value) {
          setState(() {
            interestingTopics = value;
          });
        },
      ),
    );
  }

  Widget _add() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        heroTag: 'createHive',
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.grey.shade200,
        child: Icon(
          Icons.add,
          size: 30,
        ),
        onPressed: () async {
          await widget.model.getTopics();

          Hive created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateHivePage()),
          );

          await _initializeMarkers();

          if (created != null &&
              created.latitude != null &&
              created.longitude != null) {
            _moveToLocation(LatLng(created.latitude, created.longitude));
          }
        },
      ),
    );
  }

  Widget _reload() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: Tooltip(
        message: 'Refresh Hives',
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.refresh,
              color: Colors.grey.shade400,
              size: 30,
            ),
          ),
          onTap: () async {
            LatLngBounds bounds = await _mapController.getVisibleRegion();
            double lat =
                (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
            double lng =
                (bounds.northeast.longitude + bounds.southwest.longitude) / 2;

            LatLng latLng = LatLng(lat, lng);

            widget.model.getMapHives(latLng: latLng).then((_) {
              _initializeMarkers();
            });
          },
        ),
      ),
    );
  }

  Widget _myPosition() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: Tooltip(
        message: 'Current position',
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.gps_fixed,
              color: Colors.grey.shade400,
              size: 30,
            ),
          ),
          onTap: _moveToMyLocation,
        ),
      ),
    );
  }

  Future<void> _moveToMyLocation() async {
    if (_mapController == null) {
      // Map isn't ready
      return null;
    }

    Position position = await widget.model.getPosition();
    if (position == null) {
      // Permission denied
      return null;
    }

    _moveToLocation(LatLng(position.latitude, position.longitude));
  }

  _moveToLocation(LatLng position) {
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: position,
        zoom: 15.0,
      ),
    ));
  }

  Set<Marker> _filteredMarkers(
      Set<Marker> markers, List<UserTopic> topics, List<Hive> hives) {
    Set<Marker> result = Set<Marker>();
    markers.forEach((marker) {
      Hive selected = _selectHive(hives, marker.markerId.value);

      if (selected != null) {
        selected.topics.forEach((topic) {
          if (topics.map((t) => t.id).contains(topic.id) &&
              !result.contains(marker)) result.add(marker);
        });
      }
    });
    return result;
  }

  Hive _selectHive(List<Hive> hives, String id) {
    Hive result;
    hives.forEach((hive) {
      if (hive.id == id) result = hive;
    });
    return result;
  }
}
