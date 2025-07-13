import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sihadir/services/mapel_service.dart';
import 'mapel_event.dart';
import 'mapel_state.dart';

class MapelBloc extends Bloc<MapelEvent, MapelState> {
  final MapelService service;

  MapelBloc(this.service) : super(MapelInitial()) {
    on<FetchMapel>((event, emit) async {
      emit(MapelLoading());
      try {
        final data = await service.getAllMapel();
        emit(MapelLoaded(data));
      } catch (e) {
        emit(MapelError("Gagal mengambil data: $e"));
      }
    });

on<AddMapel>((event, emit) async {
  emit(MapelLoading());
  try {
    await service.createMapel(event.namaMapel, event.kelasIds);
    add(FetchMapel()); // Sukses → muat ulang data
  } catch (e) {
    emit(MapelError("Gagal tambah mapel: $e")); // Gagal → kirim error
  }
});



    on<UpdateMapel>((event, emit) async {
      try {
        await service.updateMapel(event.id, event.namaMapel, event.kelasIds);
        emit(MapelSuccess("Mapel berhasil diupdate"));
        add(FetchMapel());
      } catch (e) {
        emit(MapelError("Gagal update mapel: $e"));
      }
    });

    on<DeleteMapel>((event, emit) async {
      try {
        await service.deleteMapel(event.id);
        emit(MapelSuccess("Mapel berhasil dihapus"));
        add(FetchMapel());
      } catch (e) {
        emit(MapelError("Gagal hapus mapel: $e"));
      }
    });
  }
}
