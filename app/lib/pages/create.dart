import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackathon/classes/hive.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/classes/topic.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:hackathon/utils/location.dart';
import 'package:hackathon/widgets/topic-auto-completion.dart';
import 'package:hackathon/widgets/open-role-dialog.dart';
import 'package:scoped_model/scoped_model.dart';

class CreateHivePage extends StatefulWidget {
  @override
  _CreateHivePageState createState() => _CreateHivePageState();
}

class _CreateHivePageState extends State<CreateHivePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  ScrollController _controller;

  String name;
  String description;
  String address;
  List<OpenRole> openRoles = [];
  List<Topic> topics = [];

  String _topicsErrorMessage;
  String _openRolesErrorMessage;

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          controller: _controller,
          child: Container(
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
                          'Create Hive',
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
                      _topicsErrorMessage != null
                          ? _errorMessage(_topicsErrorMessage)
                          : Container(),
                      _selectedTopics(topics),
                      SizedBox(height: 15),
                      topics.isNotEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _title('Open roles'),
                                InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: addOpenRole,
                                  child: Icon(
                                    Icons.add_circle,
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      _openRolesErrorMessage != null
                          ? _errorMessage(_openRolesErrorMessage)
                          : Container(),
                      _openRoles(openRoles),
                      _button(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  addOpenRole() async {
    if (topics == null || topics.isEmpty) {
      setState(() {
        _openRolesErrorMessage = 'Please pick at least one topic before';
      });

      return;
    }

    OpenRole result = await showDialog(
      context: context,
      builder: (ctx) => OpenRoleDialog(topics),
    );

    if (result != null) {
      bool match = false;

      openRoles.forEach((openRole) {
        if (openRole.name == result.name) {
          openRole.quantity++;
          match = true;
        }
      });

      if (!match) {
        openRoles.add(result);
      }

      setState(() {
        _openRolesErrorMessage = null;
      });
    }
  }

  Widget _title(String title) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
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
        },
      ),
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
        },
      ),
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

  Widget _errorMessage(String errorMessage) {
    return Container(
      margin: EdgeInsets.only(top: 6.0),
      child: Row(
        children: [
          Text(
            errorMessage,
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _interests(List<Topic> options) {
    return Container(
      child: TopicAutoCompletion(options, addTopic, onFocus: onFocusCallback),
    );
  }

  void onFocusCallback() {
    _controller.animateTo(_controller.offset,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void addTopic(Topic topic) {
    setState(() {
      if (!topics.any((t) => t.id == topic.id)) {
        topics.add(topic);
      }

      _topicsErrorMessage = null;
    });
  }

  void removeTopic(Topic toRemove) {
    setState(() {
      topics.removeWhere((item) => item.id == toRemove.id);
    });
  }

  Widget _selectedTopics(List<Topic> selected) {
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
                topic.id,
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
          ),
        ),
      );
    });

    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Wrap(children: topics),
    );
  }

  Widget _openRoles(List<OpenRole> openRoles) {
    List<Widget> roles = List<Widget>();

    openRoles.forEach((role) {
      roles.add(_openRole(role, context));
    });

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: roles,
      ),
    );
  }

  Widget _openRole(OpenRole role, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.grey.shade800),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            role.toString(),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              setState(() {
                openRoles.removeWhere((element) => element.name == role.name);
              });
            },
            child: Icon(
              Icons.delete,
              color: Colors.yellow,
            ),
          ),
        ],
      ),
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
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
            ),
            onPressed: () => _submit(model),
          ),
        );
      },
    );
  }

  void _submit(MainModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    if (topics == null || topics.isEmpty) {
      setState(() {
        _topicsErrorMessage = 'Please pick at least one topic';
      });

      return;
    }

    if (openRoles == null || openRoles.isEmpty) {
      setState(() {
        _openRolesErrorMessage = 'Please add at least one open role';
      });

      return;
    }

    bool shouldCreateLocation = address != null && address.isNotEmpty;
    LatLng location = shouldCreateLocation
        ? randomLocation(
            aroundPosition: LatLng(
              model.position.latitude,
              model.position.longitude,
            ),
          )
        : null;

    Hive created = await model.createHive(
      name: name,
      description: description,
      latitude: shouldCreateLocation ? location.latitude : null,
      longitude: shouldCreateLocation ? location.longitude : null,
      address: address,
      openRoles: openRoles,
      topics: topics.map((topic) => topic.id).toList(),
    );
    await model.getMapHives();
    await model.getHives();
    Navigator.of(context).pop(created);
  }
}
