import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {

  final List<Object> args;

  Failure(this.args);

  @override
  List<Object> get props => args;

}