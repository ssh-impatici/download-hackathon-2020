import 'package:flutter/material.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/classes/topic.dart';
import 'package:hackathon/classes/user.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:hackathon/widgets/role_scoring_tile.dart';
import 'package:scoped_model/scoped_model.dart';

class UserPage extends StatefulWidget {
  final User user;

  UserPage(this.user);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    bool shouldShowReview = widget.user.topics
        .map((e) => e.scorings)
        .expand((i) => i)
        .toList()
        .isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(widget.user.fullName),
          _email(widget.user.email),
          _bio(widget.user.bio),
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 20),
            child: Text(
              'Interests',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          _topics(widget.user.topics),
          shouldShowReview
              ? Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: _reviews(widget.user.topics),
                )
              : Container(),
          _button(),
        ],
      ),
    );
  }

  Widget _title(String name) {
    return Container(
      padding: EdgeInsets.only(top: 50, bottom: 30),
      child: Text(
        name,
        style: TextStyle(
            fontSize: 22,
            color: Colors.grey.shade200,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _email(String email) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          Container(
            child: Text('Email',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
          ),
          Container(
            child: Text(email, style: TextStyle(fontSize: 16)),
            padding: EdgeInsets.only(top: 10, bottom: 10),
          )
        ],
      ),
    );
  }

  Widget _bio(String bio) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text('Something about me..',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            padding: EdgeInsets.only(top: 10),
          ),
          Container(
            child: Text(
              bio,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            padding: EdgeInsets.only(top: 10, bottom: 10),
          )
        ],
      ),
    );
  }

  Widget _topics(List<UserTopic> userTopics) {
    List<Widget> topics = [];
    userTopics.forEach((topic) {
      topics.add(
        Container(
          padding: EdgeInsets.all(6),
          margin: EdgeInsets.only(bottom: 5, top: 5, right: 5),
          decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(5)),
          child: Text(
            topic.id,
            style: TextStyle(
                color: Colors.yellow.shade400,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    });

    return Container(
      child: Wrap(children: topics),
    );
  }

  Widget _reviews(List<UserTopic> topics) {
    List<Widget> scoringWidgets = [];

    topics.forEach((topic) {
      if (topic.scorings != null && topic.scorings.isNotEmpty) {
        scoringWidgets.add(_reviewTopic(topic.id));
        topic.scorings.forEach((scoring) {
          scoringWidgets.add(RoleScoringTile(scoring));
        });
      }
    });

    return ListView(shrinkWrap: true, children: scoringWidgets);
  }

  Widget _reviewTopic(String name) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 20),
      child: Text(
        name,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _button() {
    MainModel model = ScopedModel.of<MainModel>(context);

    if (model.user.id != widget.user.id) {
      return Container();
    } else {
      return Container(
        padding: EdgeInsets.only(top: 20, bottom: 15),
        child: RaisedButton(
          color: Colors.grey.shade900,
          child: Center(
            child: model.loading
                ? Container(
                    padding: EdgeInsets.all(10),
                    child: Center(child: CircularProgressIndicator()))
                : Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
          onPressed: () async {
            await model
                .logout()
                .then((_) => Navigator.of(context).pushReplacementNamed('/'));
          },
        ),
      );
    }
  }
}
