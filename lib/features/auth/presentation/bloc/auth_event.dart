import 'package:equatable/equatable.dart';
import 'package:n_stars_notebook/features/student/domain/entities/student.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String uid;
  final String password;

  AuthLoginRequested({required this.uid, required this.password});

  @override
  List<Object?> get props => [uid, password];
}

class AuthLogoutRequested extends AuthEvent {}
