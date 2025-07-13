import 'package:sihadir/data/model/kelola/mapel_model.dart';

abstract class MapelState {}

class MapelInitial extends MapelState {}

class MapelLoading extends MapelState {}

class MapelLoaded extends MapelState {
  final List<MapelModel> mapel;
  MapelLoaded(this.mapel);
}

class MapelSuccess extends MapelState {
  final String message;
  MapelSuccess(this.message);
}

class MapelError extends MapelState {
  final String message;
  MapelError(this.message);
}
