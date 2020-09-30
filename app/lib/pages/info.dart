import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/classes/topic.dart';
import 'package:hackathon/scopedmodels/main.dart';
import 'package:hackathon/widgets/auto-completion.dart';
import 'package:scoped_model/scoped_model.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  //
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  //
  String name;
  String surname;
  String bio;
  List<Topic> topics = List<Topic>();

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
                        child: Text('One more step',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold))),
                    Container(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(
                            'We need some more additional infos about you!',
                            style: TextStyle(fontSize: 16))),
                    _title('Name'),
                    _name(),
                    SizedBox(height: 15),
                    _title('Surname'),
                    _surname(),
                    SizedBox(height: 15),
                    _title('Bio'),
                    _bio(),
                    SizedBox(height: 15),
                    _title('Interests'),
                    _interests(model.topics),
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
            if (value.isEmpty) return 'You must enter your name!';
          },
          onSaved: (String value) {
            name = value;
            nameController..text = value;
          }),
    );
  }

  Widget _surname() {
    return Container(
      child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: surnameController,
          decoration: InputDecoration(hintText: 'Surname'),
          // ignore: missing_return
          validator: (String value) {
            if (value.isEmpty) return 'You must enter your surname!';
          },
          onSaved: (String value) {
            surname = value;
            nameController..text = value;
          }),
    );
  }

  Widget _bio() {
    return Container(
      child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: bioController,
          maxLines: 5,
          decoration: InputDecoration(hintText: 'Something about you'),
          // ignore: missing_return
          validator: (String value) {
            if (value.isEmpty)
              return 'Let the others know something about you!';
            if (value.length < 10)
              return 'Try to provide a more complete description!';
          },
          onSaved: (String value) {
            bio = value;
            bioController..text = value;
          }),
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
      topics.add(topic);
    });
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
          onPressed: () => _submit(model.addUserInfo, model.errorMessage),
        ),
      );
    });
  }

  void _submit(Function callback, String msg) {}
}
