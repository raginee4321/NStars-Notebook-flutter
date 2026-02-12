import 'package:n_stars_notebook/features/student/domain/entities/fee.dart';

abstract class FeeRepository {
  Future<void> addFee(Fee fee);
  Stream<List<Fee>> watchFees(String studentId);
  Future<void> deleteFee(String feeId);
}