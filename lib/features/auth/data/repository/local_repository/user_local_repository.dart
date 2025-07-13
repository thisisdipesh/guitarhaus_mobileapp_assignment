import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:guitarhaus_mobileapp_assignment/core/error/faliure.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/data/data_source/user_data_source.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/entity/user_entity.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/repository/user_repository.dart';

class UserLocalRepository implements IUserRepository {
  final IUserDataSource _dataSource;

  UserLocalRepository({required IUserDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await _dataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> loginUser(String username, String password) async {
    try {
      final message = await _dataSource.loginUser(username, password);
      return Right(message);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
    }
    
      @override
      Future<Either<Failure, void>> registerUser(UserEntity user) async{
    try {
      await _dataSource.registerUser(user);
      return const Right(null);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
      }
    
      @override
      Future<Either<Failure, String>> uploadProfilePicture(File file) {
    // TODO: implement uploadProfilePicture
    throw UnimplementedError();
      }
    
    
  }


