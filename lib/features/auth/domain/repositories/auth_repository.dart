import 'package:n_stars_notebook/features/student/domain/entities/student.dart';

abstract class AuthRepository {
  Future<Student?> signIn(String uid, String password);
  Future<void> signOut();
  Future<Student?> getCurrentUser();
}
