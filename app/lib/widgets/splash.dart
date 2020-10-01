import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:hackathon/utils/enums.dart';

class SplashBeelder extends StatefulWidget {
  final MainModel model;

  SplashBeelder(this.model);

  @override
  _SplashBeelderState createState() => _SplashBeelderState();
}

class _SplashBeelderState extends State<SplashBeelder> {
  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Image(
                image: AssetImage('assets/icons/icon.png'),
                height: 150.0,
                width: 150.0,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: CircularProgressIndicator(),
            )
          ],
        ),
      ),
    );
  }

  _initialize() async {
    MainModel model = widget.model;

    AuthResult result = await model.autoSignIn();

    switch (result) {
      case AuthResult.SIGNEDIN:
        // Get position once
        Position pos = await model.getPosition();

        LatLng latLng;
        if (pos != null) {
          latLng = LatLng(pos.latitude, pos.longitude);
        }

        await model.getTopics();
        await model.getHives(latLng: latLng);
        await model.getMapHives(latLng: latLng);

        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case AuthResult.SIGNEDUP:
        await model.getTopics();
        Navigator.of(context).pushReplacementNamed('/info');
        break;
      case AuthResult.UNAUTHORIZED:
        Navigator.of(context).pushReplacementNamed('/auth');
        break;
      default:
    }
  }
}
