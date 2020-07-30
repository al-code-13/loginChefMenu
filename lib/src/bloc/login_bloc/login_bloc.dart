import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loginchefmenu/src/utils/validators.dart';
import 'bloc.dart';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../repository/user_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  UserRepository _userRepository;
  LoginBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(Empty());

  @override
  Stream<Transition<LoginEvent, LoginState>> transformEvents(
    Stream<LoginEvent> events,
    TransitionFunction<LoginEvent, LoginState> transitionFn,
  ) {
    final nonDebounceStream = events.where((event) {
      return (event is! EmailorPasswordChanged);
    });

    final debounceStream = events.where((event) {
      return (event is EmailorPasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));

    return super.transformEvents(
      nonDebounceStream.mergeWith([debounceStream]),
      transitionFn,
    );
  }

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is EmailorPasswordChanged) {
      yield* _mapEmailorPasswordChangedToState(event.email,event.password);
    }
    if (event is PhoneChanged) {
      yield* _mapPhoneChangedToState(event.phone);
    }
    if (event is LoginWithPhone) {
      yield* _mapLoginWithPhone(
          phoneNumber: event.phoneNumber, context: event.context);
    }
    if (event is LoginWithPhoneSucces) {
      yield Success();
    }
    if (event is LoginWithEmailAndPassword) {
      yield* _mapLoginWithEmailAndPasswordToState(
          email: event.email, password: event.password);
    }
    if (event is SignUpWithEmailAndPassowrd) {
      yield* _mapSignUpWithEmailAndPassowrd(
          email: event.email,
          password: event.password,
          userinfo: event.userinfo);
    }
    if (event is LoginWithGoogle) {
      yield* _mapLoginWithGoogleToState();
    }
    if (event is LoginWithFacebook) {
      yield* _mapLoginWithFacebookToState();
    }
  }

  Stream<LoginState> _mapPhoneChangedToState(String phone) async* {
    yield RegistringWithPhone(isValidPhone: Validators.isValidPhone(phone));
  }

  Stream<LoginState> _mapEmailorPasswordChangedToState(String email,String password) async* {
    yield Registring(isValidEmail: Validators.isValidEmail(email),isValidPassword: Validators.isValidPassword(password));
  }


  Stream<LoginState> _mapLoginWithPhone(
      {String phoneNumber, BuildContext context}) async* {
    yield Loading();
    try {
      yield Success();
    } catch (e) {
      print(e);
      yield Failure(error: e.toString());
    }
  }

  Stream<LoginState> _mapLoginWithEmailAndPasswordToState(
      {String email, String password}) async* {
    yield Loading();
    try {
      await _userRepository.logInEmail(email, password);
      yield Success();
    } catch (e) {
      yield Failure(error: e.toString());
    }
  }

  Stream<LoginState> _mapSignUpWithEmailAndPassowrd(
      {String email, String password, UserUpdateInfo userinfo}) async* {
    yield Loading();
    try {
      await _userRepository.signUpWithEmail(email, password, userinfo);
      yield Success();
    } catch (e) {
      yield Failure(error: e.toString());
    }
  }

  Stream<LoginState> _mapLoginWithGoogleToState() async* {
    Loading();
    try {
      var itsOk=false;
      final googleUser = await _userRepository.signInWithGoogle();
      final _auth = FirebaseAuth.instance;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      //obtener credenciales del proveedor de google
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      //Validar si existe un usuario autenticado
      _auth.currentUser().then((value) async {
        //En caso de que este intentando vincular la cuenta
        if (value != null) {
          //en caso de que el email que intenta vincular sea el mismo que ya esta dentro
          if (googleUser.email == value.email) {
            //enlace de las cuentas (requiere de un inicio de sesion reciente)
            await value.linkWithCredential(credential).then((value) {
              //Aqui debe mostrar la alerta de que todo fue exitoso
              print(
                "Cuenta vinculada exitosamente.",
              );
              itsOk = true;
            })
                //Aqui debe informar al usuario que se produjo un error
                .catchError((e) {
              itsOk = false;
            });
          }
          //en caso de que el email no sea el mismo
          else {
            itsOk = false;
          }
        }
        //En caso que desee iniciar sesion con la cuenta
        else {
          //Es necesario validar si el email ya existe con el fin de evitar que google sobrescriba las cuentas
          _auth
              .fetchSignInMethodsForEmail(email: googleUser.email)
              .then((value) async {
            //En caso de que si este vinculada anteriormente
            if (value != null && value.length > 0) {
              //En caso de que el email este vinculado, validar que este vinculado con google
              if (value.contains("google.com")) {
                //En caso de que sea exitoso (Se debe informar al usuario) todo
                await _auth.signInWithCredential(credential).then((value) {
                  itsOk = true;
                });
              }
              //En caso de que el correo este vinculado pero no con la cuenta de google  (Se debe informar al usuario) todo
              else {
                itsOk = false;
              }
            }
            //En caso de que no este vinculada se debe evitar que se sobrescriba  (Se debe informar al usuario) todo
            else {
              itsOk = false;
            }
          });
        }
      });
      if (itsOk) {
        yield Success();
      } else {
        yield Failure(error: "Error iniciando Sesión");
      }
    } catch (e) {
      yield Failure(error: e.toString());
    }
  }

  Stream<LoginState> _mapLoginWithFacebookToState() async* {
    Loading();
    try {
      await _userRepository.loginWithFacebook();
      yield Success();
    } catch (e) {
      yield Failure(error: e.toString());
    }
  }

  Stream<LoginState> _mapLoginWithPhoneSuccess() async* {
    try {
      yield Success();
    } catch (e) {
      print(e);
      yield Failure(error: e.toString());
    }
  }
}
