import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guitarhaus_mobileapp_assignment/app/service_locator/service_locator.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view/login_screen.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'package:guitarhaus_mobileapp_assignment/features/home/view/HomePage.dart';
import 'package:guitarhaus_mobileapp_assignment/features/home/view_model/homepage_viewmodel.dart';
import 'package:guitarhaus_mobileapp_assignment/features/splash/splash_viewmodel.dart/splash_viewmodel.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  void initState() {
    super.initState();
    context.read<SplashViewModel>().decideNavigation();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashViewModel, SplashState>(
      listener: (context, state) {
        if (state == SplashState.navigateToHome) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider<HomeViewModel>(
                create: (_) => serviceLocator<HomeViewModel>(),
                child: const HomePage(),
              ),
            ),
          );
        } else if (state == SplashState.navigateToLogin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider<LoginViewModel>(
                create: (_) => serviceLocator<LoginViewModel>(),
                child: LoginScreen(),
              ),
            ),
          );
        }
      },
      // child: Scaffold(
      //   body: Center(
      //     child: Lottie.asset('assets/animations/softConnect.json'),
      //   ),
      // ),
    );
  }
}
