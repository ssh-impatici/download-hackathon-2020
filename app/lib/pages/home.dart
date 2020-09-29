import 'package:flutter/material.dart';
import 'package:hackathon/pages/hives.dart';
import 'package:hackathon/pages/map.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:hackathon/widgets/bottom_bar.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return SafeArea(
          child: Scaffold(
            bottomNavigationBar: BottomBar(_controller.jumpToPage),
            body: Container(
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _controller,
                children: <Widget>[MapPage(), HivesPage()],
              ),
            ),
          ),
        );
      },
    );
  }
}
