import 'package:sihadir/data/model/kelola/guru_model.dart';

abstract class GuruState {}

class GuruInitial extends GuruState {}

class GuruLoading extends GuruState {}

class GuruLoaded extends GuruState {
  final List<GuruModel> guruList;

  GuruLoaded(this.guruList);
}

class GuruSuccess extends GuruState {
  final String message;

  GuruSuccess(this.message);
}

class GuruError extends GuruState {
  final String message;

  GuruError(this.message);
}
