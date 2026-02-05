import 'package:n_stars_notebook/features/student/domain/entities/student.dart';

class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    required super.doj,
    required super.gender,
    required super.phone,
    super.profileImageUrl,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      doj: json['doj'] ?? '',
      gender: json['gender'] ?? '',
      phone: json['phone'] ?? '',
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'doj': doj,
      'gender': gender,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
    };
  }
  
  // Factory for converting Entity to Model if needed, or use as subclass
  factory StudentModel.fromEntity(Student student) {
    return StudentModel(
      id: student.id,
      name: student.name,
      doj: student.doj,
      gender: student.gender,
      phone: student.phone,
      profileImageUrl: student.profileImageUrl,
    );
  }
}
