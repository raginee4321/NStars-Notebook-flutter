import 'package:n_stars_notebook/features/student/domain/entities/student.dart';
import 'package:n_stars_notebook/features/student/domain/repositories/student_repository.dart';

class GetStudents {
  final StudentRepository repository;
  GetStudents(this.repository);
  Future<List<Student>> call() => repository.getStudents();
}

class WatchStudents {
  final StudentRepository repository;
  WatchStudents(this.repository);
  Stream<List<Student>> call() => repository.watchStudents();
}

class AddStudent {
  final StudentRepository repository;
  AddStudent(this.repository);
  Future<void> call(Student student) => repository.addStudent(student);
}

class UpdateStudent {
  final StudentRepository repository;
  UpdateStudent(this.repository);
  Future<void> call(Student student) => repository.updateStudent(student);
}

class DeleteStudent {
  final StudentRepository repository;
  DeleteStudent(this.repository);
  Future<void> call(String id) => repository.deleteStudent(id);
}
