import 'package:sihadir/data/model/request/auth/register_request_model.dart';

sealed class RegisterEvent {}

class RegisterRequested extends RegisterEvent{
  final RegisterRequestModel requestModel;

  RegisterRequested({required this.requestModel});
}