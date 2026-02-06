import 'package:n_stars_notebook/features/student/domain/entities/student.dart';

abstract class StudentRepository {
  Future<List<Student>> getStudents();
  Stream<List<Student>> watchStudents();
  Future<Student?> getStudentById(String id);
  Future<void> addStudent(Student student);
  Future<void> updateStudent(Student student);
  Future<void> deleteStudent(String id);
  Future<String> uploadProfileImage(String studentId, List<int> imageBytes, String extension);
}
