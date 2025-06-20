import 'package:dartz/dartz.dart';
import 'package:guitarhaus_mobileapp_assignment/core/error/faliure.dart';

abstract interface class UsecaseWithParams<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

abstract interface class UsecaseWithoutParams<SuccessType> {
  Future<Either<Failure, SuccessType>> call();
}