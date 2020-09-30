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
  String _role;
  String _roleErrorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("New open role"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15.0),
            _rolePicker(),
            _roleErrorMessage != null ? _roleError() : Container(),
            SizedBox(height: 15.0),
            TextFormField(
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
          ],
        ),
      ),
      actions: [
        FlatButton(
          textColor: Colors.deepOrange,
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
            label: Text(item),
            selected: isSelected,
            backgroundColor: Colors.grey,
            selectedColor: Colors.yellow,
            onSelected: (selected) {
              setState(() {
                _role = item;
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
      margin: EdgeInsets.only(top: 4.0),
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
    if (_role == null) {
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
