import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:scoped_model/scoped_model.dart';

class MapPage extends StatefulWidget {
  //
  final MainModel model;
  MapPage(this.model);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController _mapController;
  bool bytopic = false;

  final LatLng _center = const LatLng(45.6918992, 9.6749658);

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: ScopedModelDescendant<MainModel>(
                builder: (context, child, model) => Stack(
                      children: [_map(), _controlPanel(), _add()],
                    ))));
  }

  Widget _map() {
    return GoogleMap(
      zoomControlsEnabled: false,
      onMapCreated: _onMapCreated,
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
              color: Colors.grey.withOpacity(0.5)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [_switch(), _myposition()],
          ),
        ),
      ),
    );
  }

  Widget _switch() {
    return Switch(
      activeColor: Colors.grey.shade800.withOpacity(1),
      activeTrackColor: Colors.grey.shade600.withOpacity(1),
      value: bytopic,
      onChanged: (value) {
        setState(() => bytopic = value);
      },
    );
  }

  Widget _add() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        child: Container(
          height: 50,
          width: 50,
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(25)),
          child: Icon(
            Icons.add,
            color: Colors.grey.shade200,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _myposition() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        child: Icon(
          Icons.gps_fixed,
          color: Colors.grey.shade800,
          size: 30,
        ),
        onTap: () => {},
      ),
    );
  }

  /*Future<void> _moveToMyLocation() async {
    final GoogleMapController controller = await _mapController.future;
    await widget.model.getCurrentLocation(moving: true);
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(widget.model.locationData.latitude,
            widget.model.locationData.longitude),
        zoom: 15.0,
      ),
    ));
  }*/
}
