import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:guitarhaus_mobileapp_assignment/core/error/faliure.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/entity/user_entity.dart';

abstract interface class IUserRepository {
  Future<Either<Failure, void>> registerUser(UserEntity user);

  Future<Either<Failure, String>> loginUser(
    String username,
    String password,
  );

  Future<Either<Failure, String>> uploadProfilePicture(File file);

  Future<Either<Failure, UserEntity>> getCurrentUser();
}
