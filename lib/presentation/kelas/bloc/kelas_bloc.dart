import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sihadir/presentation/kelas/bloc/kelas_event.dart';
import 'package:sihadir/presentation/kelas/bloc/kelas_state.dart';
import 'package:sihadir/services/kelas_service.dart';

class KelasBloc extends Bloc<KelasEvent, KelasState> {
  final KelasService service;

  KelasBloc(this.service) : super(KelasInitial()) {
    // Fetch all kelas
    on<FetchKelas>((event, emit) async {
      emit(KelasLoading());
      try {
        final result = await service.getAllKelas();
        emit(KelasLoaded(result));
      } catch (e) {
        emit(KelasError(e.toString()));
      }
    });

    on<AddKelas>((event, emit) async {
      try {
        emit(KelasLoading());
        await service.createKelas(event.namaKelas, []);
        debugPrint("[BLOC] Kelas '${event.namaKelas}' berhasil ditambahkan.");
        add(FetchKelas());
      } catch (e) {
        debugPrint("[BLOC ERROR] Gagal tambah kelas: $e");
        emit(KelasError(e.toString()));
      }
    });

    on<UpdateKelas>((event, emit) async {
      try {
        emit(KelasLoading());
        await service.updateKelas(event.id, event.namaKelas, []);
        debugPrint(
          "[BLOC] Kelas ID ${event.id} berhasil diupdate ke '${event.namaKelas}'",
        );
        add(FetchKelas());
      } catch (e) {
        debugPrint("[BLOC ERROR] Gagal update kelas: $e");
        emit(KelasError(e.toString()));
      }
    });

    // Hapus kelas
    on<DeleteKelas>((event, emit) async {
      try {
        await service.deleteKelas(event.id);
        add(FetchKelas());
      } catch (e) {
        emit(KelasError(e.toString()));
      }
    });
  }
}
