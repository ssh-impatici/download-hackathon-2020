import 'package:flutter/material.dart';
import 'package:hackathon/classes/user.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ReviewDialog extends StatefulWidget {
  final String role;
  final User user;
  final Function callback;

  ReviewDialog(this.user, this.role, this.callback);

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  double _stars = 5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Review ${widget.user.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 15.0),
          SmoothStarRating(
            allowHalfRating: false,
            onRated: (v) {
              setState(() {
                _stars = v;
              });
            },
            starCount: 5,
            rating: _stars,
            color: Colors.yellow,
            borderColor: Colors.yellow,
            // size: 40.0,
            // spacing: 0.0,
          ),
        ],
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
          child: Text("Confirm"),
          onPressed: _stars != null ? _onSubmit : null,
        ),
      ],
    );
  }

  _onSubmit() async {
    if (await widget.callback(_stars.toInt())) {
      Navigator.of(context).pop();
    }
  }
}
