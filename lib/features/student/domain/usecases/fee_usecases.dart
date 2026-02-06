import 'package:n_stars_notebook/features/student/domain/entities/fee.dart';
import 'package:n_stars_notebook/features/student/domain/repositories/fee_repository.dart';

class AddFee {
  final FeeRepository repository;
  AddFee(this.repository);

  Future<void> call(Fee fee) {
    return repository.addFee(fee);
  }
}

class WatchFees {
  final FeeRepository repository;
  WatchFees(this.repository);

  Stream<List<Fee>> call(String studentId) {
    return repository.watchFees(studentId);
  }
}
