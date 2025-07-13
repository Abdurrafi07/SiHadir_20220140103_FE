import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sihadir/presentation/jadwal/bloc/jadwal_event.dart';
import 'package:sihadir/presentation/jadwal/bloc/jadwal_state.dart';
import 'package:sihadir/services/jadwal_service.dart';


class JadwalBloc extends Bloc<JadwalEvent, JadwalState> {
  final JadwalService _jadwalService;

  JadwalBloc(this._jadwalService) : super(JadwalInitial()) {
    on<FetchJadwal>(_onFetchJadwal);
    on<AddJadwal>(_onAddJadwal);
    on<UpdateJadwal>(_onUpdateJadwal);
    on<DeleteJadwal>(_onDeleteJadwal);
  }

  Future<void> _onFetchJadwal(FetchJadwal event, Emitter<JadwalState> emit) async {
    emit(JadwalLoading());
    try {
      final data = await _jadwalService.getAllJadwal();
      emit(JadwalLoaded(data));
    } catch (e) {
      emit(JadwalError("Gagal memuat data: $e"));
    }
  }

  Future<void> _onAddJadwal(AddJadwal event, Emitter<JadwalState> emit) async {
    try {
      await _jadwalService.createJadwal(
        kelasId: event.kelasId,
        mapelId: event.mapelId,
        hari: event.hari,
        jamMulai: event.jamMulai,
        jamSelesai: event.jamSelesai,
      );
      add(FetchJadwal());
    } catch (e) {
      emit(JadwalError("Gagal menambahkan jadwal: $e"));
    }
  }

  Future<void> _onUpdateJadwal(UpdateJadwal event, Emitter<JadwalState> emit) async {
    try {
      await _jadwalService.updateJadwal(
        id: event.id,
        kelasId: event.kelasId,
        mapelId: event.mapelId,
        hari: event.hari,
        jamMulai: event.jamMulai,
        jamSelesai: event.jamSelesai,
      );
      add(FetchJadwal());
    } catch (e) {
      emit(JadwalError("Gagal mengupdate jadwal: $e"));
    }
  }

  Future<void> _onDeleteJadwal(DeleteJadwal event, Emitter<JadwalState> emit) async {
    try {
      await _jadwalService.deleteJadwal(event.id);
      add(FetchJadwal());
    } catch (e) {
      emit(JadwalError("Gagal menghapus jadwal: $e"));
    }
  }
}
