import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/classes/topic.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:hackathon/widgets/auto-completion.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:math';

class CreateHivePage extends StatefulWidget {
  @override
  _CreateHivePageState createState() => _CreateHivePageState();
}

class _CreateHivePageState extends State<CreateHivePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String name;
  String description;
  LatLng location = LatLng(
    45.642389 + ((Random().nextInt(100) - 50) / 100),
    9.5858929 + ((Random().nextInt(100) - 50) / 100),
  );
  String address;
  List<OpenRole> openRoles = [];
  List<String> topics = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              width: MediaQuery.of(context).size.width,
              child: ScopedModelDescendant<MainModel>(
                builder: (context, child, model) => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        'Create hive',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        'Fill the info below to create a new hive!',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    _title('Name'),
                    _name(),
                    SizedBox(height: 15),
                    _title('Description'),
                    _description(),
                    SizedBox(height: 15),
                    _title('Location (optional)'),
                    _address(),
                    SizedBox(height: 15),
                    _title('Topics'),
                    _interests(model.topics),
                    _selected(topics),
                    _button()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(String title) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _name() {
    return Container(
      child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: nameController,
          decoration: InputDecoration(hintText: 'Name'),
          // ignore: missing_return
          validator: (String value) {
            if (value.isEmpty) return 'You must enter the hive name!';
          },
          onSaved: (String value) {
            name = value;
            nameController..text = value;
          }),
    );
  }

  Widget _description() {
    return Container(
      child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: descriptionController,
          decoration: InputDecoration(hintText: 'Description'),
          // ignore: missing_return
          onSaved: (String value) {
            description = value;
            descriptionController..text = value;
          }),
    );
  }

  Widget _address() {
    return Container(
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        controller: addressController,
        decoration: InputDecoration(hintText: 'Address'),
        // ignore: missing_return
        onSaved: (String value) {
          address = value;
          addressController..text = value;
        },
      ),
    );
  }

  Widget _interests(List<Topic> options) {
    print(options);
    return Container(
      child: AutoCompletion(options, addTopic),
    );
  }

  void addTopic(Topic topic) {
    setState(() {
      topics.add(topic.id);
    });
  }

  void removeTopic(String string) {
    setState(() {
      topics.removeWhere((item) => item == string);
    });
  }

  Widget _selected(List<String> selected) {
    List<Widget> topics = [];
    selected.forEach((topic) {
      topics.add(
        Container(
            padding: EdgeInsets.all(6),
            margin: EdgeInsets.only(bottom: 5, top: 5, right: 5),
            decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(5)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  topic,
                  style: TextStyle(
                      color: Colors.yellow.shade400,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  child: Icon(
                    Icons.close,
                    size: 14,
                  ),
                  onTap: () => removeTopic(topic),
                ),
              ],
            )),
      );
    });

    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Wrap(children: topics),
    );
  }

  Widget _button() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
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
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
          onPressed: () => _submit(model),
        ),
      );
    });
  }

  void _submit(MainModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    await model
        .createHive(
          name: name,
          description: description,
          latitude: location.latitude,
          longitude: location.longitude,
          address: address,
          openRoles: openRoles,
          topics: topics,
        )
        .then((value) => Navigator.of(context).pushReplacementNamed('/home'));
  }
}
