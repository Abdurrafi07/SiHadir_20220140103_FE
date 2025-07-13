abstract class MapelEvent {}

class FetchMapel extends MapelEvent {}

class AddMapel extends MapelEvent {
  final String namaMapel;
  final List<int> kelasIds;

  AddMapel({required this.namaMapel, required this.kelasIds});
}

class UpdateMapel extends MapelEvent {
  final int id;
  final String namaMapel;
  final List<int> kelasIds;

  UpdateMapel({required this.id, required this.namaMapel, required this.kelasIds});
}

class DeleteMapel extends MapelEvent {
  final int id;

  DeleteMapel(this.id);
}
