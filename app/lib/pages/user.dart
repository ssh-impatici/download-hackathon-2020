import 'package:flutter/material.dart';
import 'package:hackathon/classes/topic.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:scoped_model/scoped_model.dart';

class UserPage extends StatefulWidget {
  //
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  //
  bool editName = false;
  bool editBio = false;
  //
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(model.user.fullName),
              _email(model.user.email),
              _bio(model.user.bio),
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 20),
                child: Text('Interests',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              _topics(model.user.topics),
            ],
          ),
        );
      },
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
            child: Text('Bio',
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

  Widget _topics(List<Topic> userTopics) {
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
}
