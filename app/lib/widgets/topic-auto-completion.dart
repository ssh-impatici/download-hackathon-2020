import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:hackathon/classes/topic.dart';

class TopicAutoCompletion extends StatefulWidget {
  //
  final List options;
  final Function callback;
  final String hint;
  TopicAutoCompletion(this.options, this.callback, {this.hint});

  @override
  _TopicAutoCompletionState createState() => _TopicAutoCompletionState();
}

class _TopicAutoCompletionState extends State<TopicAutoCompletion> {
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
        decoration: InputDecoration(
          hintText: widget.hint,
        ),
        itemBuilder: (context, item) => Container(
          child: Text(
            item.id,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
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
