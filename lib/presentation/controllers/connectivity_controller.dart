import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityController extends GetxController {
  final isOnline = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void onInit() {
    super.onInit();
    Connectivity().checkConnectivity().then((r) {
      isOnline.value = r.any((e) => e != ConnectivityResult.none);
    });
    _sub = Connectivity().onConnectivityChanged.listen((r) {
      isOnline.value = r.any((e) => e != ConnectivityResult.none);
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
