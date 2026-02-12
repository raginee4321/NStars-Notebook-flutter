import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:n_stars_notebook/features/student/domain/entities/fee.dart';
import 'package:n_stars_notebook/features/student/domain/usecases/fee_usecases.dart';

// Events
abstract class FeeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFees extends FeeEvent {
  final String studentId;
  LoadFees(this.studentId);
  @override
  List<Object?> get props => [studentId];
}

class UpdateFeesList extends FeeEvent {
  final List<Fee> fees;
  UpdateFeesList(this.fees);
  @override
  List<Object?> get props => [fees];
}

// States
abstract class FeeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeeInitial extends FeeState {}
class FeeLoading extends FeeState {}
class FeeLoaded extends FeeState {
  final List<Fee> fees;
  FeeLoaded(this.fees);
  @override
  List<Object?> get props => [fees];
}
class FeeError extends FeeState {
  final String message;
  FeeError(this.message);
  @override
  List<Object?> get props => [message];
}

class FeeBloc extends Bloc<FeeEvent, FeeState> {
  final WatchFees watchFees;
  final AddFee addFeeUseCase;
  final DeleteFee deleteFeeUseCase;
  StreamSubscription? _feesSubscription;

  FeeBloc({
    required this.watchFees,
    required this.addFeeUseCase,
    required this.deleteFeeUseCase,
  }) : super(FeeInitial()) {

    on<LoadFees>((event, emit) async {
      emit(FeeLoading());
      await _feesSubscription?.cancel();
      _feesSubscription = watchFees(event.studentId).listen((fees) {
        add(UpdateFeesList(fees));
      });
    });

    on<UpdateFeesList>((event, emit) {
      emit(FeeLoaded(event.fees));
    });
  }

  Future<void> submitFee(Fee fee) {
    return addFeeUseCase(fee);
  }

  Future<void> deleteFee(String feeId) {
    return deleteFeeUseCase(feeId);
  }

  @override
  Future<void> close() {
    _feesSubscription?.cancel();
    return super.close();
  }
}