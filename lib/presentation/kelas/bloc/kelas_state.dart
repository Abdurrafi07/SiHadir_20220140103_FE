import 'package:sihadir/data/model/kelola/kelas_model.dart';

abstract class KelasState {}

class KelasInitial extends KelasState {}

class KelasLoading extends KelasState {}

class KelasLoaded extends KelasState {
  final List<KelasModel> kelas;
  KelasLoaded(this.kelas);
}

class KelasError extends KelasState {
  final String message;
  KelasError(this.message);
}