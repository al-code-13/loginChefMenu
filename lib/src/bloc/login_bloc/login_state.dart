import 'package:equatable/equatable.dart';
import 'package:loginchefmenu/src/bloc/login_bloc/bloc.dart';
import 'package:meta/meta.dart';

class LoginState extends Equatable {
  @override
  List<Object> get props =>[props];
}

class Registring extends LoginState {
  final bool isValidEmail;
  final bool isValidPassword;

  Registring({this.isValidEmail, this.isValidPassword});
}

class RegistringWithPhone extends LoginState {
  final bool isValidPhone;

  RegistringWithPhone({this.isValidPhone});
}

class Empty extends LoginState {}

class Success extends LoginState {}

class Loading extends LoginState {}

class Failure extends LoginState {
  final String error;

  Failure({@required this.error});
}
