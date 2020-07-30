import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object> get props => [];
}

//Cinco eventos
//Phone Changed
class PhoneChanged extends LoginEvent {
  final String phone;
  const PhoneChanged({@required this.phone});
  @override
  List<Object> get props => [phone];
  @override
  String toString() {
    return 'PhoneChanged {phone :$phone}';
  }
}

//Email Changed
class EmailorPasswordChanged extends LoginEvent {
  final String email;
  final String password;
  const EmailorPasswordChanged({@required this.email,@required this.password});
  
  @override
  List<Object> get props => [email,password];
  @override
  String toString() {
    return 'EmailorPasswordChanged {email:$email,password:$password}';
  }
}

//Submittign
class Submitted extends LoginEvent {
  final String email;
  final String password;
  const Submitted({@required this.email, this.password});
  @override
  List<Object> get props => [email, password];
  @override
  String toString() {
    return 'Submitted {email:$email,password:$password}';
  }
}

//Login with phone number
class LoginWithPhone extends LoginEvent {
  final String phoneNumber;
  final BuildContext context;
  const LoginWithPhone({@required this.phoneNumber,@required this.context});
  @override
  List<Object> get props => [phoneNumber,context];
  @override
  String toString() {
    return 'LoginWithPhone {phoneNumber:$phoneNumber,context:$context}';
  }
}

class LoginWithPhoneSucces extends LoginEvent {}
//Login with email
class LoginWithEmailAndPassword extends LoginEvent {
  final String email;
  final String password;
  const LoginWithEmailAndPassword({@required this.email, this.password});
  @override
  List<Object> get props => [email, password];
  @override
  String toString() {
    return 'LoginWithEmailAndPassword {email:$email,password:$password}';
  }
}

//Registro con email
class SignUpWithEmailAndPassowrd extends LoginEvent {
  final String email;
  final String password;
  final UserUpdateInfo userinfo;
  const SignUpWithEmailAndPassowrd({@required this.email,@required this.password,@required this.userinfo});
  @override
  List<Object> get props => [email, password,userinfo];
  @override
  String toString() {
    return 'SignUpWithEmailAndPassword {email:$email,password:$password,userinfo:$userinfo}';
  }
}

//Login With Google
class LoginWithGoogle extends LoginEvent {}

//Login with facebook
class LoginWithFacebook extends LoginEvent {}
