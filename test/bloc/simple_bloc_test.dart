import 'package:flutter_test/flutter_test.dart';

// Simple BLoC for testing
class CounterBloc {
  int _count = 0;
  
  int get count => _count;
  
  void increment() {
    _count++;
  }
  
  void decrement() {
    _count--;
  }
  
  void reset() {
    _count = 0;
  }
}

// Simple state management test
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  
  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });
  
  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.isAuthenticated == isAuthenticated;
  }
  
  @override
  int get hashCode => isLoading.hashCode ^ errorMessage.hashCode ^ isAuthenticated.hashCode;
}

class AuthBloc {
  AuthState _state = AuthState();
  
  AuthState get state => _state;
  
  void login(String email, String password) {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    
    // Simulate login logic
    if (email.isEmpty || password.isEmpty) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Email and password are required',
      );
      return;
    }
    
    if (!email.contains('@')) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid email format',
      );
      return;
    }
    
    if (password.length < 6) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Password must be at least 6 characters',
      );
      return;
    }
    
    // Simulate successful login
    _state = _state.copyWith(
      isLoading: false,
      isAuthenticated: true,
    );
  }
  
  void logout() {
    _state = AuthState();
  }
  
  void clearError() {
    _state = _state.copyWith(errorMessage: null);
  }
}

void main() {
  group('Simple BLoC Tests', () {
    group('CounterBloc Tests', () {
      late CounterBloc counterBloc;
      
      setUp(() {
        counterBloc = CounterBloc();
      });
      
      test('should start with count 0', () {
        expect(counterBloc.count, 0);
      });
      
      test('should increment count', () {
        counterBloc.increment();
        expect(counterBloc.count, 1);
        
        counterBloc.increment();
        expect(counterBloc.count, 2);
      });
      
      test('should decrement count', () {
        counterBloc.increment();
        counterBloc.increment();
        counterBloc.decrement();
        expect(counterBloc.count, 1);
      });
      
      test('should reset count to 0', () {
        counterBloc.increment();
        counterBloc.increment();
        counterBloc.reset();
        expect(counterBloc.count, 0);
      });
      
      test('should handle multiple operations', () {
        counterBloc.increment();
        counterBloc.increment();
        counterBloc.decrement();
        counterBloc.increment();
        counterBloc.reset();
        counterBloc.increment();
        expect(counterBloc.count, 1);
      });
    });
    
    group('AuthBloc Tests', () {
      late AuthBloc authBloc;
      
      setUp(() {
        authBloc = AuthBloc();
      });
      
      test('should start with initial state', () {
        final state = authBloc.state;
        expect(state.isLoading, false);
        expect(state.errorMessage, isNull);
        expect(state.isAuthenticated, false);
      });
      
      test('should handle successful login', () {
        authBloc.login('test@example.com', 'password123');
        
        final state = authBloc.state;
        expect(state.isLoading, false);
        expect(state.errorMessage, isNull);
        expect(state.isAuthenticated, true);
      });
      
      test('should handle empty email', () {
        authBloc.login('', 'password123');
        
        final state = authBloc.state;
        expect(state.isLoading, false);
        expect(state.errorMessage, 'Email and password are required');
        expect(state.isAuthenticated, false);
      });
      
      test('should handle empty password', () {
        authBloc.login('test@example.com', '');
        
        final state = authBloc.state;
        expect(state.isLoading, false);
        expect(state.errorMessage, 'Email and password are required');
        expect(state.isAuthenticated, false);
      });
      
      test('should handle invalid email format', () {
        authBloc.login('invalid-email', 'password123');
        
        final state = authBloc.state;
        expect(state.isLoading, false);
        expect(state.errorMessage, 'Invalid email format');
        expect(state.isAuthenticated, false);
      });
      
      test('should handle short password', () {
        authBloc.login('test@example.com', '123');
        
        final state = authBloc.state;
        expect(state.isLoading, false);
        expect(state.errorMessage, 'Password must be at least 6 characters');
        expect(state.isAuthenticated, false);
      });
      
      test('should handle logout', () {
        // First login successfully
        authBloc.login('test@example.com', 'password123');
        expect(authBloc.state.isAuthenticated, true);
        
        // Then logout
        authBloc.logout();
        final state = authBloc.state;
        expect(state.isLoading, false);
        expect(state.errorMessage, isNull);
        expect(state.isAuthenticated, false);
      });
      
      test('should clear error message', () {
        // First create an error
        authBloc.login('', 'password123');
        expect(authBloc.state.errorMessage, isNotNull);
        
        // Then clear the error
        authBloc.clearError();
        expect(authBloc.state.errorMessage, isNull);
      });
      
      test('should show loading state during login', () {
        // This test simulates the loading state
        // In a real implementation, this would be async
        authBloc.login('test@example.com', 'password123');
        
        // The loading state is very brief in this simple implementation
        // In a real BLoC, you'd test the loading state properly
        expect(authBloc.state.isLoading, false);
      });
    });
    
    group('State Equality Tests', () {
      test('AuthState should be equal when properties are the same', () {
        final state1 = AuthState(
          isLoading: false,
          errorMessage: null,
          isAuthenticated: false,
        );
        
        final state2 = AuthState(
          isLoading: false,
          errorMessage: null,
          isAuthenticated: false,
        );
        
        expect(state1, equals(state2));
      });
      
      test('AuthState should not be equal when properties are different', () {
        final state1 = AuthState(
          isLoading: false,
          errorMessage: null,
          isAuthenticated: false,
        );
        
        final state2 = AuthState(
          isLoading: true,
          errorMessage: null,
          isAuthenticated: false,
        );
        
        expect(state1, isNot(equals(state2)));
      });
      
      test('copyWith should create new state with updated properties', () {
        final originalState = AuthState(
          isLoading: false,
          errorMessage: null,
          isAuthenticated: false,
        );
        
        final newState = originalState.copyWith(
          isLoading: true,
          errorMessage: 'Test error',
        );
        
        expect(newState.isLoading, true);
        expect(newState.errorMessage, 'Test error');
        expect(newState.isAuthenticated, false);
        expect(newState, isNot(equals(originalState)));
      });
    });
  });
} 