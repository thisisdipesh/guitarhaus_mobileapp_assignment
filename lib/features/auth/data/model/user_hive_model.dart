import 'package:guitarhaus_mobileapp_assignment/app/constants/hive_table_constants.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/entity/user_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';


part 'user_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.userTableId)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final int studentId;

  UserHiveModel({
    required this.username,
    required this.email,
    required this.password,
    required this.studentId,
  });

  factory UserHiveModel.fromEntity(UserEntity entity) {
    return UserHiveModel(
      username: entity.username,
      email: entity.email,
      password: entity.password,
      studentId: entity.studentId,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      username: username,
      email: email,
      password: password,
      studentId: studentId,
    );
  }
}
