import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/entity/user_entity.dart';

abstract class SignupEvent {}

class SignupSubmitted extends SignupEvent {
  final UserEntity user;

  SignupSubmitted(this.user);
}