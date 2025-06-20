
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:guitarhaus_mobileapp_assignment/app/use_case/usecase.dart';
import 'package:guitarhaus_mobileapp_assignment/core/error/faliure.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/repository/user_repository.dart';

class UserUploadProfilePictureParams {
  final File file;

  const UserUploadProfilePictureParams({required this.file});
}

class UserUploadProfilePictureUsecase
    implements UsecaseWithParams<String, UserUploadProfilePictureParams> {
  final IUserRepository _userRepository;

  UserUploadProfilePictureUsecase({required IUserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Either<Failure, String>> call(UserUploadProfilePictureParams params) {
    return _userRepository.uploadProfilePicture(params.file);
  }
}
