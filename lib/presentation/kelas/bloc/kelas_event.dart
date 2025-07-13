abstract class KelasEvent {}

class FetchKelas extends KelasEvent {}

class AddKelas extends KelasEvent {
  final String namaKelas;

  AddKelas(this.namaKelas);
}

class UpdateKelas extends KelasEvent {
  final int id;
  final String namaKelas;

  UpdateKelas(this.id, this.namaKelas);
}

class DeleteKelas extends KelasEvent {
  final int id;

  DeleteKelas(this.id);
}
