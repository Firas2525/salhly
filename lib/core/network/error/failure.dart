import 'package:equatable/equatable.dart';
import '../../../app.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
  ServerFailure.openFun(super.message) {
    App.snackBar(body: message, isSucess: false);
  }
}

class DataBaseFailure extends Failure {
  const DataBaseFailure(super.message);
}
