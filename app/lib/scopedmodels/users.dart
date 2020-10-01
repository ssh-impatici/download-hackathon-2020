import 'package:hackathon/scopedmodels/connected.dart';
import 'package:hackathon/utils/api.dart';
import 'package:dio/dio.dart';

mixin UsersModel on ConnectedModel {
  _setLoading(bool newState) {
    loading = newState;
    notifyListeners();
  }

  Future<void> setUserRating({
    String userId,
    String topic,
    String role,
    int stars,
  }) async {
    _setLoading(true);

    try {
      const url = '$apiEndpoint/modifyStars';

      await Dio().post(
        url,
        data: {
          'userRef': 'users/$userId',
          'topic': topic,
          'role': role,
          'stars': stars
        },
      );
    } catch (e) {
      errorMessage = e.toString();
    }

    _setLoading(false);
  }
}
