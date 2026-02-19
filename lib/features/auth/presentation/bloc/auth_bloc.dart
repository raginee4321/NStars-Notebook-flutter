import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n_stars_notebook/features/auth/domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:n_stars_notebook/core/services/background_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = await authRepository.getCurrentUser();
    if (user != null) {
      if (user.role == 'student') {
        await BackgroundService.scheduleDailyCheck();
      }
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signIn(event.uid, event.password);
      if (user != null) {
        if (user.role == 'student') {
          await BackgroundService.scheduleDailyCheck();
        }
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Invalid UID or Password'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.signOut();
    emit(AuthUnauthenticated());
  }
}
