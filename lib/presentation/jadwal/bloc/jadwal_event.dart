abstract class JadwalEvent {}

class FetchJadwal extends JadwalEvent {}

class AddJadwal extends JadwalEvent {
  final int kelasId;
  final int mapelId;
  final String hari;
  final String jamMulai;
  final String jamSelesai;

  AddJadwal({
    required this.kelasId,
    required this.mapelId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
  });
}

class UpdateJadwal extends JadwalEvent {
  final int id;
  final int kelasId;
  final int mapelId;
  final String hari;
  final String jamMulai;
  final String jamSelesai;

  UpdateJadwal({
    required this.id,
    required this.kelasId,
    required this.mapelId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
  });
}

class DeleteJadwal extends JadwalEvent {
  final int id;
  DeleteJadwal(this.id);
}
