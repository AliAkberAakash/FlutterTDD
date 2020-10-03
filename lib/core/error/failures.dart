import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
abstract class Failure extends Equatable {

  List<Object> args = [];

  Failure([this.args]);

  @override
  List<Object> get props => args;

}

//General Failures
// ignore: must_be_immutable
class ServerFailure extends Failure {}

// ignore: must_be_immutable
class CacheFailure extends Failure {}