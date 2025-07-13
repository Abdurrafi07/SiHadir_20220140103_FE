import 'package:bloc/bloc.dart';
import 'package:sihadir/data/repository/auth_repository.dart';
import 'package:sihadir/presentation/auth/login/bloc/login_event.dart';
import 'package:sihadir/presentation/auth/login/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    final result = await authRepository.login(event.requestModel);

    result.fold(
      (l) => emit(LoginFailure(error: l)),
      (r) => emit(LoginSuccess(responseModel: r)),
    );
  }
}