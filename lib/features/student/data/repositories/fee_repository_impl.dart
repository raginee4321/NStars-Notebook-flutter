import 'package:n_stars_notebook/features/student/data/datasources/fee_remote_data_source.dart';
import 'package:n_stars_notebook/features/student/data/models/fee_model.dart';
import 'package:n_stars_notebook/features/student/domain/entities/fee.dart';
import 'package:n_stars_notebook/features/student/domain/repositories/fee_repository.dart';

class FeeRepositoryImpl implements FeeRepository {
  final FeeRemoteDataSource remoteDataSource;

  FeeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addFee(Fee fee) async {
    await remoteDataSource.addFee(FeeModel.fromEntity(fee));
  }

  @override
  Stream<List<Fee>> watchFees(String studentId) {
    return remoteDataSource.watchFeesByStudentId(studentId);
  }

  @override
  Future<void> deleteFee(String feeId) async {
    await remoteDataSource.deleteFee(feeId);
  }
}