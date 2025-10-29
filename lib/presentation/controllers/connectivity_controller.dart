// lib/presentation/controllers/connectivity_controller.dart
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityController extends GetxController {
  final isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _watch();
  }

  Future<void> _watch() async {
    final initial = await Connectivity().checkConnectivity();
    isOnline.value = initial != ConnectivityResult.none;

    Connectivity().onConnectivityChanged.listen((results) {
      final any = results.any((r) => r != ConnectivityResult.none);
      isOnline.value = any;
    });
  }
}
