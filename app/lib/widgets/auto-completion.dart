import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:hackathon/classes/topic.dart';

class AutoCompletion extends StatefulWidget {
  //
  final List options;
  final Function callback;
  AutoCompletion(this.options, this.callback);

  @override
  _AutoCompletionState createState() => _AutoCompletionState();
}

class _AutoCompletionState extends State<AutoCompletion> {
  //
  GlobalKey<AutoCompleteTextFieldState<Topic>> _key = GlobalKey();
  //
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
      child: AutoCompleteTextField<Topic>(
        itemBuilder: (context, item) => Text(item.id),
        itemFilter: (item, query) =>
            item.id.toLowerCase().startsWith(query.toLowerCase()),
        itemSorter: (a, b) => a.id.compareTo(b.id),
        itemSubmitted: (item) => widget.callback(item),
        key: _key,
        suggestions: widget.options,
      ),
    );
  }
}
