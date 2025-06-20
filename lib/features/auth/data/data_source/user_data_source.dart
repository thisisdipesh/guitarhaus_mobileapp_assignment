import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/entity/user_entity.dart';

abstract interface class IUserDataSource {
  Future<void> registerUser(UserEntity user);

  Future<String> loginUser(String username, String password);

  Future<String> uploadProfilePicture(String filePath);

  Future<UserEntity> getCurrentUser();
}