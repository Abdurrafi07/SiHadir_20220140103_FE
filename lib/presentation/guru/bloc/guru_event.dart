abstract class GuruEvent {}

class FetchGuru extends GuruEvent {}

class AddGuru extends GuruEvent {
  final String name;
  final String email;
  final String password;
  final int? idKelas;

  AddGuru({required this.name, required this.email, required this.password, this.idKelas});
}

class UpdateGuru extends GuruEvent {
  final int id;
  final String? name;
  final String? email;
  final String? password;
  final int? idKelas;

  UpdateGuru({
    required this.id,
    this.name,
    this.email,
    this.password,
    this.idKelas,
  });
}

class DeleteGuru extends GuruEvent {
  final int id;

  DeleteGuru(this.id);
}
