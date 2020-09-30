import 'package:firebase_core/firebase_core.dart';
import 'package:hackathon/pages/home.dart';
import 'package:hackathon/pages/info.dart';
import 'package:hackathon/scopedmodels/main.dart';

import 'package:flutter/material.dart';
import 'package:hackathon/utils/theme.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:hackathon/pages/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  final MainModel _model = MainModel();
  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routes: {
          '/': (context) => AuthPage(),
          '/info': (context) => InfoPage(),
          '/home': (context) => HomePage()
        },
      ),
    );
  }
}
