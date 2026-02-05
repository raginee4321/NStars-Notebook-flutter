import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:n_stars_notebook/core/constants/constants.dart';
import 'package:n_stars_notebook/features/student/data/models/student_model.dart';

abstract class StudentRemoteDataSource {
  Future<List<StudentModel>> getStudents();
  Stream<List<StudentModel>> getStudentsStream();
  Future<StudentModel?> getStudentById(String id);
  Future<void> addStudent(StudentModel student);
  Future<void> updateStudent(StudentModel student);
  Future<void> deleteStudent(String id);
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final SupabaseClient supabase;

  StudentRemoteDataSourceImpl({required this.supabase});

  @override
  Future<void> addStudent(StudentModel student) async {
    await supabase.from(AppConstants.studentsCollection).insert(student.toJson());
  }

  @override
  Future<void> deleteStudent(String id) async {
    await supabase.from(AppConstants.studentsCollection).delete().eq('id', id);
  }

  @override
  Future<StudentModel?> getStudentById(String id) async {
    final response = await supabase
        .from(AppConstants.studentsCollection)
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response != null) {
      return StudentModel.fromJson(response);
    }
    return null;
  }

  @override
  Future<List<StudentModel>> getStudents() async {
    final response = await supabase
        .from(AppConstants.studentsCollection)
        .select();
    
    return (response as List).map((data) => StudentModel.fromJson(data)).toList();
  }

  @override
  Stream<List<StudentModel>> getStudentsStream() {
    return supabase
        .from(AppConstants.studentsCollection)
        .stream(primaryKey: ['id'])
        .map((data) => data.map((item) => StudentModel.fromJson(item)).toList());
  }

  @override
  Future<void> updateStudent(StudentModel student) async {
    await supabase
        .from(AppConstants.studentsCollection)
        .update(student.toJson())
        .eq('id', student.id);
  }
}
