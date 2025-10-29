import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService service;
  final user = Rxn<User>();

  AuthController(this.service);

  @override
  void onInit() {
    super.onInit();
    user.bindStream(service.userChanges());
  }

  Future<void> login(String email, String password) async {
    try {
      await service.signIn(email, password);
      Get.snackbar('Login', 'Logged in successfully');
    } on FirebaseAuthException catch (e) {
      final m = {
            'invalid-email': 'Invalid email',
            'user-not-found': 'No account found',
            'wrong-password': 'Wrong password',
            'operation-not-allowed': 'Provider disabled in console',
          }[e.code] ??
          'Login failed';
      Get.snackbar('Auth', m);
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await service.signUp(email, password);
      Get.snackbar('Register', 'Account created');
    } on FirebaseAuthException catch (e) {
      final m = {
            'email-already-in-use': 'Email already in use',
            'weak-password': 'Weak password',
            'invalid-email': 'Invalid email',
            'operation-not-allowed': 'Provider disabled in console',
          }[e.code] ??
          'Registration failed';
      Get.snackbar('Auth', m);
    }
  }

  Future<void> logout() async {
    await service.signOut();
    Get.snackbar('Logout', 'Signed out');
  }
}
