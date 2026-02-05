import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String id;
  final String name;
  final String doj; // Date of Joining
  final String gender;
  final String phone;
  final String? profileImageUrl;

  const Student({
    required this.id,
    required this.name,
    required this.doj,
    required this.gender,
    required this.phone,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [id, name, doj, gender, phone, profileImageUrl];
}
