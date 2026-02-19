import 'package:n_stars_notebook/features/student/domain/entities/student.dart';

class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.uid,
    required super.name,
    required super.doj,
    required super.gender,
    required super.phone,
    required super.belt,
    required super.batch,
    required super.role,
    super.profileImageUrl,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      doj: json['doj'] ?? '',
      gender: json['gender'] ?? '',
      phone: json['phone'] ?? '',
      belt: json['belt'] ?? '',
      batch: json['batch'] ?? '',
      role: json['role'] ?? 'student',
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'doj': doj,
      'gender': gender,
      'phone': phone,
      'belt': belt,
      'batch': batch,
      'role': role,
      'profileImageUrl': profileImageUrl,
    };
  }
  
  // Factory for converting Entity to Model if needed, or use as subclass
  factory StudentModel.fromEntity(Student student) {
    return StudentModel(
      id: student.id,
      uid: student.uid,
      name: student.name,
      doj: student.doj,
      gender: student.gender,
      phone: student.phone,
      belt: student.belt,
      batch: student.batch,
      role: student.role,
      profileImageUrl: student.profileImageUrl,
    );
  }
}
