import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guitarhaus_mobileapp_assignment/app/use_case/usecase.dart';
import 'package:guitarhaus_mobileapp_assignment/core/error/faliure.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/entity/user_entity.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/repository/user_repository.dart';


/// ------------------- PARAMS -------------------

class RegisterUserParams extends Equatable {
  final String email;
  final String username;
  final int studentId;
  final String password;
  final String? profilePhoto;
  final String? bio;
  final String role;

  const RegisterUserParams({
    required this.email,
    required this.username,
    required this.studentId,
    required this.password,
    this.profilePhoto,
    this.bio,
    this.role = 'normal',
  });

  @override
  List<Object?> get props => [
        email,
        username,
        studentId,
        password,
        profilePhoto,
        bio,
        role,
      ];
}

/// ------------------- USE CASE -------------------

class UserRegisterUsecase
    implements UsecaseWithParams<void, RegisterUserParams> {
  final IUserRepository _userRepository;

  UserRegisterUsecase({required IUserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Either<Failure, void>> call(RegisterUserParams params) {
    final user = UserEntity(
      email: params.email,
      username: params.username,
      studentId: params.studentId,
      password: params.password,
      profilePhoto: params.profilePhoto,
      bio: params.bio,
      role: params.role,
    );
    return _userRepository.registerUser(user);
  }
}
