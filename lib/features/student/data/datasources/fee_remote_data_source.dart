import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:n_stars_notebook/core/constants/constants.dart';
import 'package:n_stars_notebook/features/student/data/models/fee_model.dart';

abstract class FeeRemoteDataSource {
  Future<void> addFee(FeeModel fee);
  Stream<List<FeeModel>> watchFeesByStudentId(String studentId);
  Future<void> deleteFee(String feeId);
}

class FeeRemoteDataSourceImpl implements FeeRemoteDataSource {
  final SupabaseClient supabase;

  FeeRemoteDataSourceImpl({required this.supabase});

  @override
  Future<void> addFee(FeeModel fee) async {
    await supabase.from(AppConstants.feesCollection).insert(fee.toJson());
  }

  @override
  Stream<List<FeeModel>> watchFeesByStudentId(String studentId) {
    return supabase
        .from(AppConstants.feesCollection)
        .stream(primaryKey: ['id'])
        .eq('student_id', studentId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => FeeModel.fromJson(json)).toList());
  }

  @override
  Future<void> deleteFee(String feeId) async {
    await supabase.from(AppConstants.feesCollection).delete().eq('id', feeId);
  }
}