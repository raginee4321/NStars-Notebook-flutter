import 'package:n_stars_notebook/features/student/domain/entities/fee.dart';

class FeeModel extends Fee {
  const FeeModel({
    required super.id,
    required super.studentId,
    required super.amount,
    required super.month,
    required super.mode,
    required super.paymentDate,
    required super.createdAt,
  });

  factory FeeModel.fromJson(Map<String, dynamic> json) {
    return FeeModel(
      id: json['id'],
      studentId: json['student_id'],
      amount: (json['amount'] as num).toDouble(),
      month: json['month'],
      mode: json['mode'],
      paymentDate: json['payment_date'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'amount': amount,
      'month': month,
      'mode': mode,
      'payment_date': paymentDate,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FeeModel.fromEntity(Fee fee) {
    return FeeModel(
      id: fee.id,
      studentId: fee.studentId,
      amount: fee.amount,
      month: fee.month,
      mode: fee.mode,
      paymentDate: fee.paymentDate,
      createdAt: fee.createdAt,
    );
  }
}
