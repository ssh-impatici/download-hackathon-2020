import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hackathon/classes/role.dart';
import 'package:hackathon/classes/topic.dart';

class OpenRoleDialog extends StatefulWidget {
  final List<Topic> topics;

  OpenRoleDialog(this.topics);

  @override
  _OpenRoleDialogState createState() => _OpenRoleDialogState();
}

class _OpenRoleDialogState extends State<OpenRoleDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _quantityController = TextEditingController();

  int _quantity;
  String _role = '';
  String _roleErrorMessage;
  ScrollController _controller;

  FocusNode _focus;

  @override
  void initState() {
    _focus = FocusNode();
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Available Roles"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _controller,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 15.0),
              TextFormField(
                focusNode: _focus,
                controller: _quantityController,
                decoration: InputDecoration(
                  hintText: "How many bees?",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers can be entered
                // ignore: missing_return
                validator: (String value) {
                  if (value.isEmpty) return 'You must enter the quantity!';
                  if (int.tryParse(value) == null)
                    return 'The quantity must BEE a number';
                },
                onSaved: (String value) {
                  _quantity = int.parse(value);
                  _quantityController..text = value;
                },
              ),
              SizedBox(height: 15.0),
              _roleErrorMessage != null ? _roleError() : Container(),
              _rolePicker(),
            ],
          ),
        ),
      ),
      actions: [
        FlatButton(
            textColor: Colors.deepOrange,
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        FlatButton(
          textColor: Theme.of(context).textTheme.button.color,
          child: Text("Add"),
          onPressed: _onSubmit,
        ),
      ],
    );
  }

  void addRole(String role) {
    setState(() {
      _role = role;
      _roleErrorMessage = null;
    });
  }

  Widget _rolePicker() {
    List<dynamic> roles =
        widget.topics.map((topic) => topic.roles).expand((i) => i).toList();

    List<Widget> choices = List();

    roles.forEach((item) {
      bool isSelected = _role == item;

      choices.add(
        Container(
          padding: const EdgeInsets.all(2.0),
          child: ChoiceChip(
            label: Text(
              item,
              style: TextStyle(
                  color: Colors.grey.shade800, fontWeight: FontWeight.bold),
            ),
            selected: isSelected,
            backgroundColor: Colors.grey.shade300,
            selectedColor: Colors.yellow,
            onSelected: (selected) {
              setState(() {
                if (_role == '') {
                  _role = item;
                  _roleErrorMessage = null;
                  _focus.requestFocus();
                  _controller.animateTo(0.0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                } else {
                  _role = '';
                  _focus.unfocus();
                }
              });
            },
          ),
        ),
      );
    });
    return Wrap(children: choices);
  }

  Widget _roleError() {
    return Container(
      margin: EdgeInsets.only(top: 4.0, bottom: 5),
      child: Row(
        children: [
          Text(
            _roleErrorMessage,
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  _onSubmit() {
    if (_role == null || _role == '') {
      setState(() {
        _roleErrorMessage = 'Please pick a role';
      });

      return;
    }

    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    Navigator.of(context).pop(OpenRole(name: _role, quantity: _quantity));
  }
}
