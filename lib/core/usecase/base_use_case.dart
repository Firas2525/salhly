import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';

import '../network/error/failure.dart';

abstract class BaseUseCase<T, Parameters> {
  Future<Either<Failure, T>> call(Parameters parameters);
}

abstract class BaseUseCaseInside<T, Parameters> {
  T change(Parameters parameters);
}

class NoParameters extends Equatable {
  const NoParameters();
  @override
  List<Object> get props => [];
}
