import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sihadir/services/guru_service.dart';
import 'guru_event.dart';
import 'guru_state.dart';

class GuruBloc extends Bloc<GuruEvent, GuruState> {
  final GuruService service;

  GuruBloc(this.service) : super(GuruInitial()) {
    on<FetchGuru>((event, emit) async {
      emit(GuruLoading());
      try {
        final data = await service.getAllGuru();
        emit(GuruLoaded(data));
      } catch (e) {
        emit(GuruError("Gagal ambil data guru: $e"));
      }
    });

    on<AddGuru>((event, emit) async {
      emit(GuruLoading());
      try {
        await service.createGuru(
          name: event.name,
          email: event.email,
          password: event.password,
          idKelas: event.idKelas,
        );
        emit(GuruSuccess("Guru berhasil ditambahkan"));
        add(FetchGuru());
      } catch (e) {
        emit(GuruError("Gagal tambah guru: $e"));
      }
    });

    on<UpdateGuru>((event, emit) async {
      emit(GuruLoading());
      try {
        await service.updateGuru(
          id: event.id,
          name: event.name,
          email: event.email,
          password: event.password,
          idKelas: event.idKelas,
        );
        emit(GuruSuccess("Guru berhasil diperbarui"));
        add(FetchGuru());
      } catch (e) {
        emit(GuruError("Gagal update guru: $e"));
      }
    });

    on<DeleteGuru>((event, emit) async {
      emit(GuruLoading());
      try {
        await service.deleteGuru(event.id);
        emit(GuruSuccess("Guru berhasil dihapus"));
        add(FetchGuru());
      } catch (e) {
        emit(GuruError("Gagal hapus guru: $e"));
      }
    });
  }
}
