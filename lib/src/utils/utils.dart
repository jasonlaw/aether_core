import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../app.dart';
import 'custom.dart';
import 'uuid.dart';

//final isProgressIndicatorShowing = false.obs;

extension AppServiceUtils on AppService {
  String newUuid() => Uuid().v1();
  String newDigits(int size, {int seed = -1}) =>
      Uuid().digits(size, seed: seed);

  Future<void> error(dynamic error, {String? title}) =>
      Custom.notifyError(error, title: title);

  Future<void> info(String info, {String? title}) =>
      Custom.notifyInfo(info, title: title);

  Future<bool> confirm(
    String question, {
    String? title,
    String? okButtonTitle,
    String? cancelButtonTitle,
  }) =>
      Custom.askConfirm(question,
          title: title,
          okButtonTitle: okButtonTitle,
          cancelButtonTitle: cancelButtonTitle);

  void showProgressIndicator({String? status}) {
    if (EasyLoading.instance.overlayEntry != null) {
      // EasyLoading.addStatusCallback((value) =>
      //     isProgressIndicatorShowing(value == EasyLoadingStatus.show));
      EasyLoading.show(status: status);
    }
  }

  void dismissProgressIndicator() => EasyLoading.dismiss();
}
