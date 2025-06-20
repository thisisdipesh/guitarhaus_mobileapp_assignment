import 'package:bloc/bloc.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/domain/use_case/user_register_usecase.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupViewModel extends Bloc<SignupEvent, SignupState> {
  final UserRegisterUsecase registerUseCase;

  SignupViewModel({required this.registerUseCase}) : super(SignupInitial()) {
    on<SignupSubmitted>((event, emit) async {
      emit(SignupLoading());
      try {
        await registerUseCase(event.user as RegisterUserParams);
        emit(SignupSuccess());
      } catch (e) {
        emit(SignupFailure(e.toString()));
      }
    });
  }
}