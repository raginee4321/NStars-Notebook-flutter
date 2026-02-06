import 'package:equatable/equatable.dart';

class Fee extends Equatable {
  final String id;
  final String studentId;
  final double amount;
  final String month;
  final String mode; // e.g., GPay, Cash
  final String paymentDate;
  final DateTime createdAt;

  const Fee({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.month,
    required this.mode,
    required this.paymentDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, studentId, amount, month, mode, paymentDate, createdAt];
}
