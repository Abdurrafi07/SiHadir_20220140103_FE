import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sihadir/data/model/kelola/absensi_massal_request.dart';
import 'package:sihadir/services/absensi_service.dart';
import 'package:sihadir/services/jadwal_guru_service.dart';
import 'absensi_event.dart';
import 'absensi_state.dart';

class AbsensiBloc extends Bloc<AbsensiEvent, AbsensiState> {
  final JadwalGuruService jadwalService;
  final AbsensiService absensiService;

  AbsensiBloc({required this.jadwalService, required this.absensiService}) : super(AbsensiInitial()) {
    on<LoadDataAbsensi>(_onLoadData);
    on<SubmitAbsensiMassal>(_onSubmit);
  }

  Future<void> _onLoadData(LoadDataAbsensi event, Emitter<AbsensiState> emit) async {
    emit(AbsensiLoading());
    try {
      final result = await jadwalService.fetchJadwalDanSiswa();
      emit(AbsensiLoaded(
        jadwal: result['jadwal'],
        siswa: result['siswa'],
      ));
    } catch (e) {
      emit(AbsensiError(e.toString()));
    }
  }

  Future<void> _onSubmit(SubmitAbsensiMassal event, Emitter<AbsensiState> emit) async {
    emit(AbsensiSubmitting());
    try {
      final req = AbsensiMassalRequest(
        jadwalId: event.jadwalId,
        tanggal: event.tanggal,
        presensi: event.presensi,
        fotoPath: event.fotoPath,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      final response = await absensiService.kirimMassal(req);
      if (response.statusCode == 201) {
        emit(AbsensiSuccess("Presensi berhasil dikirim"));
      } else {
        emit(AbsensiError("Gagal kirim presensi: ${response.body}"));
      }
    } catch (e) {
      emit(AbsensiError(e.toString()));
    }
  }
}
