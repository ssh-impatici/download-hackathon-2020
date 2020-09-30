import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class RoleAutoCompletion extends StatefulWidget {
  //
  final List options;
  final Function callback;
  final String hint;
  RoleAutoCompletion(this.options, this.callback, {this.hint});

  @override
  _RoleAutoCompletionState createState() => _RoleAutoCompletionState();
}

class _RoleAutoCompletionState extends State<RoleAutoCompletion> {
  GlobalKey<AutoCompleteTextFieldState<String>> _key = GlobalKey();
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [_field()],
      ),
    );
  }

  Widget _field() {
    return Container(
      child: AutoCompleteTextField<String>(
        decoration: InputDecoration(
          hintText: widget.hint,
        ),
        itemBuilder: (context, item) => Container(
          child: Text(
            item,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        itemFilter: (item, query) =>
            item.toLowerCase().startsWith(query.toLowerCase()),
        itemSorter: (a, b) => a.compareTo(b),
        itemSubmitted: (item) {
          _controller.text = item;
          widget.callback(item);
        },
        key: _key,
        controller: _controller,
        suggestions: widget.options,
      ),
    );
  }
}
