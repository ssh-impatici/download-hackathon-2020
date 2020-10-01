import 'package:flutter/material.dart';
import 'package:hackathon/pages/hives.dart';
import 'package:hackathon/pages/map.dart';
import 'package:hackathon/pages/myhives.dart';
import 'package:hackathon/pages/user.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:hackathon/widgets/bottom_bar.dart';
import 'package:hackathon/widgets/splash.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  final MainModel model;
  HomePage([this.model]);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _controller = PageController();

  @override
  void initState() {
    if (widget.model != null) {
      widget.model.initUser();
      widget.model.initHives();
      widget.model.initTopics();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return SafeArea(
          child: mounted && model.loading
              ? SplashBeelder()
              : Scaffold(
                  bottomNavigationBar: BottomBar(_controller.jumpToPage),
                  body: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: PageView(
                      physics: NeverScrollableScrollPhysics(),
                      controller: _controller,
                      children: <Widget>[
                        MapPage(model),
                        HivesPage(),
                        MyHivesPage(),
                        UserPage(model.user),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
