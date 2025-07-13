import 'package:flutter_test/flutter_test.dart';
import 'package:guitarhaus_mobileapp_assignment/features/auth/presentation/view_model/login_viewmodel/login_state.dart';

void main() {
  group('LoginState Tests', () {
    group('Initial State Tests', () {
      test('should create initial state with default values', () {
        final state = LoginState.initial();
        
        expect(state.isLoading, false);
        expect(state.isSuccess, false);
        expect(state.errorMessage, isNull);
      });

      test('should create state with custom values', () {
        final state = LoginState(
          isLoading: true,
          isSuccess: false,
          errorMessage: 'Test error',
        );
        
        expect(state.isLoading, true);
        expect(state.isSuccess, false);
        expect(state.errorMessage, 'Test error');
      });
    });

    group('CopyWith Tests', () {
      test('should create new state with updated loading status', () {
        final initialState = LoginState.initial();
        final newState = initialState.copyWith(isLoading: true);
        
        expect(newState.isLoading, true);
        expect(newState.isSuccess, false);
        expect(newState.errorMessage, isNull);
        expect(newState, isNot(equals(initialState)));
      });

      test('should create new state with updated success status', () {
        final initialState = LoginState.initial();
        final newState = initialState.copyWith(isSuccess: true);
        
        expect(newState.isLoading, false);
        expect(newState.isSuccess, true);
        expect(newState.errorMessage, isNull);
        expect(newState, isNot(equals(initialState)));
      });

      test('should create new state with updated error message', () {
        final initialState = LoginState.initial();
        final newState = initialState.copyWith(errorMessage: 'Login failed');
        
        expect(newState.isLoading, false);
        expect(newState.isSuccess, false);
        expect(newState.errorMessage, 'Login failed');
        expect(newState, isNot(equals(initialState)));
      });

      test('should create new state with multiple updated properties', () {
        final initialState = LoginState.initial();
        final newState = initialState.copyWith(
          isLoading: true,
          isSuccess: true,
          errorMessage: 'Success',
        );
        
        expect(newState.isLoading, true);
        expect(newState.isSuccess, true);
        expect(newState.errorMessage, 'Success');
        expect(newState, isNot(equals(initialState)));
      });

      test('should keep original values when copyWith is called with null', () {
        final initialState = LoginState(
          isLoading: true,
          isSuccess: true,
          errorMessage: 'Test error',
        );
        final newState = initialState.copyWith(errorMessage: null);
        
        expect(newState.isLoading, true);
        expect(newState.isSuccess, true);
        expect(newState.errorMessage, isNull);
        expect(newState, isNot(equals(initialState)));
      });
    });

    group('Equality Tests', () {
      test('should be equal when all properties are the same', () {
        final state1 = LoginState(
          isLoading: true,
          isSuccess: false,
          errorMessage: 'Error',
        );
        final state2 = LoginState(
          isLoading: true,
          isSuccess: false,
          errorMessage: 'Error',
        );
        
        expect(state1, equals(state2));
      });

      test('should not be equal when properties are different', () {
        final state1 = LoginState(
          isLoading: true,
          isSuccess: false,
          errorMessage: 'Error',
        );
        final state2 = LoginState(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'Error',
        );
        
        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when error messages are different', () {
        final state1 = LoginState(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'Error 1',
        );
        final state2 = LoginState(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'Error 2',
        );
        
        expect(state1, isNot(equals(state2)));
      });

      test('should be equal when both have null error messages', () {
        final state1 = LoginState(
          isLoading: false,
          isSuccess: false,
          errorMessage: null,
        );
        final state2 = LoginState(
          isLoading: false,
          isSuccess: false,
          errorMessage: null,
        );
        
        expect(state1, equals(state2));
      });
    });

    group('State Scenarios Tests', () {
      test('should represent loading state', () {
        final loadingState = LoginState(
          isLoading: true,
          isSuccess: false,
          errorMessage: null,
        );
        
        expect(loadingState.isLoading, true);
        expect(loadingState.isSuccess, false);
        expect(loadingState.errorMessage, isNull);
      });

      test('should represent success state', () {
        final successState = LoginState(
          isLoading: false,
          isSuccess: true,
          errorMessage: null,
        );
        
        expect(successState.isLoading, false);
        expect(successState.isSuccess, true);
        expect(successState.errorMessage, isNull);
      });

      test('should represent error state', () {
        final errorState = LoginState(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'Invalid credentials',
        );
        
        expect(errorState.isLoading, false);
        expect(errorState.isSuccess, false);
        expect(errorState.errorMessage, 'Invalid credentials');
      });

      test('should represent initial state', () {
        final initialState = LoginState.initial();
        
        expect(initialState.isLoading, false);
        expect(initialState.isSuccess, false);
        expect(initialState.errorMessage, isNull);
      });
    });

    group('Props Tests', () {
      test('should return correct props list', () {
        final state = LoginState(
          isLoading: true,
          isSuccess: false,
          errorMessage: 'Test error',
        );
        
        expect(state.props, [true, false, 'Test error']);
      });

      test('should return correct props for initial state', () {
        final state = LoginState.initial();
        
        expect(state.props, [false, false, null]);
      });
    });
  });
} 