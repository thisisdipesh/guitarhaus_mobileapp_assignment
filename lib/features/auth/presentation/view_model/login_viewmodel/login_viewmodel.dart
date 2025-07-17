import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guitarhaus_mobileapp_assignment/app/service_locator/service_locator.dart';
import 'package:guitarhaus_mobileapp_assignment/core/utils/mysnackbar.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/use_case/user_login_usecase.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/signup_screen.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart';
import 'package:guitarhaus_mobileapp_assignment/features/home/view/HomePage.dart';
import 'package:guitarhaus_mobileapp_assignment/features/home/view_model/homepage_viewmodel.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/bottom_navigation_screen/dashboard_screen.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginViewModel extends Bloc<LoginEvent, LoginState> {
  final UserLoginUsecase _userLoginUsecase;

  LoginViewModel({required UserLoginUsecase userLoginUsecase})
    : _userLoginUsecase = userLoginUsecase,
      super(LoginState.initial()) {
    on<LoginUserEvent>(_onLoginUser);
    on<NavigateToSignUpEvent>(_onNavigateToSignUp); // 👈 Register the event
  }

  Future<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, errorMessage: null));

    final result = await _userLoginUsecase.call(
      UserLoginParams(username: event.username, password: event.password),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            errorMessage: failure.message,
          ),
        );
        showMySnackBar(
          context: event.context,
          message: failure.message,
          color: Colors.red,
        );
      },
      (user) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
        showMySnackBar(
          context: event.context,
          message: 'Login Successful!',
          color: Colors.green,
        );

        // Navigate to HomePage here:
        Navigator.of(event.context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      },
    );
  }

  void _onNavigateToSignUp(
    NavigateToSignUpEvent event,
    Emitter<LoginState> emit,
  ) {
    Navigator.of(event.context).push(
      MaterialPageRoute(
        builder:
            (context) => BlocProvider(
              create: (_) => serviceLocator<SignupViewModel>(),
              child: SignupScreen(),
            ),
      ),
    );
  }
}
