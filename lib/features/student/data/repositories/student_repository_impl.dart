import 'package:n_stars_notebook/features/student/data/datasources/student_remote_data_source.dart';
import 'package:n_stars_notebook/features/student/data/models/student_model.dart';
import 'package:n_stars_notebook/features/student/domain/entities/student.dart';
import 'package:n_stars_notebook/features/student/domain/repositories/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remoteDataSource;

  StudentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addStudent(Student student) async {
    await remoteDataSource.addStudent(StudentModel.fromEntity(student));
  }

  @override
  Future<void> deleteStudent(String id) async {
    await remoteDataSource.deleteStudent(id);
  }

  @override
  Future<Student?> getStudentById(String id) async {
    return await remoteDataSource.getStudentById(id);
  }

  @override
  Future<List<Student>> getStudents() async {
    return await remoteDataSource.getStudents();
  }

  @override
  Stream<List<Student>> watchStudents() {
    return remoteDataSource.getStudentsStream();
  }

  @override
  Future<void> updateStudent(Student student) async {
    await remoteDataSource.updateStudent(StudentModel.fromEntity(student));
  }
}
