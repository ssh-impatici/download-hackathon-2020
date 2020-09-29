import 'package:hackathon/scopedmodels/auth.dart';
import 'package:hackathon/scopedmodels/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class MainModel extends Model with ConnectedModel, AuthModel {}

// class MainModel extends Model with ConnectedModel, AnyModel, SuperModel {}
// mixin AnyModel on ConnectedModel {}
// mixin SuperModel on ConnectedModel {}
