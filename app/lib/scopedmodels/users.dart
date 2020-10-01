import 'package:hackathon/scopedmodels/connected.dart';

mixin UsersModel on ConnectedModel {
  _setLoading(bool newState) {
    loading = newState;
    notifyListeners();
  }
}
