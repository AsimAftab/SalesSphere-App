import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/auth/models/login.models.dart';

part 'user_controller.g.dart';

@Riverpod(keepAlive: true)
class UserController extends _$UserController {
  @override
  User? build() => null;

  void setUser(User user) => state = user;
  void clearUser() => state = null;
}
