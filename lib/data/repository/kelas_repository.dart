import 'package:sihadir/data/model/kelola/kelas_model.dart';
import 'package:sihadir/services/kelas_service.dart';

class KelasRepository {
  final KelasService service;

  KelasRepository(this.service);

  Future<List<KelasModel>> getAll() => service.getAllKelas();
  Future<void> create(String nama, List<int> mapelIds) => service.createKelas(nama, mapelIds);
  Future<void> update(int id, String nama, List<int> mapelIds) => service.updateKelas(id, nama, mapelIds);
  Future<void> delete(int id) => service.deleteKelas(id);
}

