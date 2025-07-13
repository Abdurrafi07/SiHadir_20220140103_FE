import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sihadir/data/model/kelola/siswa_model.dart';
import 'package:sihadir/presentation/siswa/bloc/siswa_event.dart';
import 'package:sihadir/presentation/siswa/bloc/siswa_state.dart';
import 'package:sihadir/services/siswa_service.dart';

class SiswaBloc extends Bloc<SiswaEvent, SiswaState> {
  final SiswaService siswaService;

  SiswaBloc(this.siswaService) : super(SiswaInitial()) {
    on<FetchSiswa>((event, emit) async {
      emit(SiswaLoading());
      try {
        final data = await siswaService.getAllSiswa();
        emit(SiswaLoaded(data));
      } catch (e) {
        emit(SiswaError(e.toString()));
      }
    });

    on<AddSiswa>((event, emit) async {
      try {
        await siswaService.addSiswa(SiswaModel(
          id: 0,
          nama: event.nama,
          nisn: event.nisn,
          jenisKelamin: event.jenisKelamin,
          tanggalLahir: event.tanggalLahir,
          alamat: event.alamat,
          kelasId: event.kelasId,
          kelas: null,
        ));
        add(FetchSiswa());
      } catch (e) {
        emit(SiswaError(e.toString()));
      }
    });

    on<UpdateSiswa>((event, emit) async {
      try {
        await siswaService.updateSiswa(SiswaModel(
          id: event.id,
          nama: event.nama,
          nisn: event.nisn,
          jenisKelamin: event.jenisKelamin,
          tanggalLahir: event.tanggalLahir,
          alamat: event.alamat,
          kelasId: event.kelasId,
          kelas: null,
        ));
        add(FetchSiswa());
      } catch (e) {
        emit(SiswaError(e.toString()));
      }
    });

    on<DeleteSiswa>((event, emit) async {
      try {
        await siswaService.deleteSiswa(event.id);
        add(FetchSiswa());
      } catch (e) {
        emit(SiswaError(e.toString()));
      }
    });
  }
}
