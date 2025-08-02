import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:guitarhaus_mobileapp_assignment/core/error/faliure.dart';
import 'package:guitarhaus_mobileapp_assignment/core/network/api_service.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/data/data_source/user_data_source.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/entity/user_entity.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLocalRepository implements IUserRepository {
  final IUserDataSource _dataSource;
  final ApiService _apiService = ApiService();

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
  Future<Either<Failure, String>> loginUser(
    String username,
    String password,
  ) async {
    try {
      // Use backend API for authentication instead of local storage
      final response = await _apiService.login(username, password);

      if (response.statusCode == 200) {
        final data = response.data;

        // Store token and user data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('userId', data['userId']);
        await prefs.setString('userRole', data['role']);

        // Set auth token for future API calls
        _apiService.setAuthToken(data['token']);

        return const Right('Login successful');
      } else {
        return Left(
          LocalDatabaseFailure(message: 'Login failed: Invalid credentials'),
        );
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerUser(UserEntity user) async {
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
