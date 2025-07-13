import 'package:sihadir/data/model/response/auth/login_response_model.dart'; // Ganti ke model login

sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final LoginResponseModel responseModel;

  LoginSuccess({required this.responseModel});
}

final class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});
}
