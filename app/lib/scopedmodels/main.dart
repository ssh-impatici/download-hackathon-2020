import 'package:hackathon/scopedmodels/auth.dart';
import 'package:hackathon/scopedmodels/connected.dart';
import 'package:hackathon/scopedmodels/hives.dart';
import 'package:hackathon/scopedmodels/notification.dart';
import 'package:hackathon/scopedmodels/topics.dart';
import 'package:hackathon/scopedmodels/users.dart';
import 'package:scoped_model/scoped_model.dart';

class MainModel extends Model
    with
        ConnectedModel,
        AuthModel,
        TopicsModel,
        HivesModel,
        UsersModel,
        NotificationModel {}

// class MainModel extends Model with ConnectedModel, AnyModel, SuperModel {}
// mixin AnyModel on ConnectedModel {}
// mixin SuperModel on ConnectedModel {}
