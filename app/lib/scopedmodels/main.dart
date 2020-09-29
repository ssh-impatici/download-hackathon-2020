import 'package:hackathon/scopedmodels/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class MainModel extends Model with ConnectedModel {}

// class MainModel extends Model with ConnectedModel, AnyModel, SuperModel {}
// mixin AnyModel on ConnectedModel {}
// mixin SuperModel on ConnectedModel {}
