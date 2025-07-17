import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:guitarhaus_mobileapp_assignment/core/network/hive_service.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/data/data_source/local_datasource/user-hive_data_source.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/data/data_source/user_data_source.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/data/repository/local_repository/user_local_repository.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/repository/user_repository.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/use_case/user_login_usecase.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/use_case/user_register_usecase.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart';
import 'package:guitarhaus_mobileapp_assignment/features/home/view_model/homepage_viewmodel.dart';
import 'package:guitarhaus_mobileapp_assignment/features/splash/splash_viewmodel.dart/splash_viewmodel.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  await _initHiveService();
  await _initSplashModule();
  await _initAuthModule();
  await _initHomeModule();
}

Future<void> _initHiveService() async {
  serviceLocator.registerLazySingleton(() => HiveService());
}

Future<void> _initAuthModule() async {
  serviceLocator.registerLazySingleton<IUserDataSource>(
    () => UserHiveDataSource(hiveService: serviceLocator<HiveService>()),
  );

  serviceLocator.registerLazySingleton<IUserRepository>(
    () => UserLocalRepository(dataSource: serviceLocator<IUserDataSource>()),
  );

  serviceLocator.registerLazySingleton<UserLoginUsecase>(
    () => UserLoginUsecase(userRepository: serviceLocator<IUserRepository>()),
  );

  serviceLocator.registerLazySingleton<UserRegisterUsecase>(
    () =>
        UserRegisterUsecase(userRepository: serviceLocator<IUserRepository>()),
  );

  serviceLocator.registerFactory<LoginViewModel>(
    () => LoginViewModel(userLoginUsecase: serviceLocator<UserLoginUsecase>()),
  );

  serviceLocator.registerFactory<SignupViewModel>(
    () =>
        SignupViewModel(registerUseCase: serviceLocator<UserRegisterUsecase>()),
  );
}

Future<void> _initSplashModule() async {
  // If SplashViewModel has dependencies, inject them here
  serviceLocator.registerFactory<SplashViewModel>(() => SplashViewModel());
}

Future<void> _initHomeModule() async {
  // If HomePageViewModel has dependencies, inject them here
  serviceLocator.registerFactory<HomeViewModel>(() => HomeViewModel());
}

class FavoritesProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _favoriteGuitars = [];

  List<Map<String, dynamic>> get favoriteGuitars =>
      List.unmodifiable(_favoriteGuitars);

  void addFavorite(Map<String, dynamic> guitar) {
    if (!_favoriteGuitars.any((g) => g['id'] == guitar['id'])) {
      _favoriteGuitars.add(guitar);
      notifyListeners();
    }
  }

  void removeFavorite(String guitarId) {
    _favoriteGuitars.removeWhere((g) => g['id'] == guitarId);
    notifyListeners();
  }

  bool isFavorite(String guitarId) {
    return _favoriteGuitars.any((g) => g['id'] == guitarId);
  }
}
