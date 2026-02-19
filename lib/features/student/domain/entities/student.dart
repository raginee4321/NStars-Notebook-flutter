import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String id;
  final String uid;
  final String name;
  final String doj; // Date of Joining
  final String gender;
  final String phone;
  final String belt;
  final String batch;
  final String role; // 'admin' or 'student'
  final String? profileImageUrl;

  const Student({
    required this.id,
    required this.uid,
    required this.name,
    required this.doj,
    required this.gender,
    required this.phone,
    required this.belt,
    required this.batch,
    required this.role,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [id, uid, name, doj, gender, phone, belt, batch, role, profileImageUrl];
}
