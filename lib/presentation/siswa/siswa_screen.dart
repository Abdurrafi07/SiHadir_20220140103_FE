import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sihadir/data/model/kelola/kelas_model.dart';
import 'package:sihadir/data/model/kelola/siswa_model.dart';
import 'package:sihadir/presentation/siswa/bloc/siswa_bloc.dart';
import 'package:sihadir/presentation/siswa/bloc/siswa_event.dart';
import 'package:sihadir/presentation/siswa/bloc/siswa_state.dart';
import 'package:sihadir/services/kelas_service.dart';

class SiswaScreen extends StatefulWidget {
  const SiswaScreen({super.key});

  @override
  State<SiswaScreen> createState() => _SiswaScreenState();
}

class _SiswaScreenState extends State<SiswaScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nisnController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  String? _jenisKelamin;
  int? _selectedKelasId;
  List<KelasModel> _kelasList = [];

  @override
  void initState() {
    super.initState();
    context.read<SiswaBloc>().add(FetchSiswa());
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    final service = KelasService();
    try {
      final data = await service.getAllKelas();
      setState(() => _kelasList = data);
    } catch (e) {
      debugPrint("[ERROR LOAD KELAS] $e");
    }
  }

  Future<void> _selectTanggalLahir(BuildContext context) async {
    final initialDate =
        DateTime.tryParse(_tanggalLahirController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        _tanggalLahirController.text = formatted;
      });
    }
  }

  void _showSiswaForm({SiswaModel? siswa}) async {
    if (_kelasList.isEmpty) {
      await _loadKelas();
      if (!mounted) return;
    }

    _namaController.text = siswa?.nama ?? '';
    _nisnController.text = siswa?.nisn ?? '';
    _tanggalLahirController.text = siswa?.tanggalLahir ?? '';
    _alamatController.text = siswa?.alamat ?? '';
    _jenisKelamin = siswa?.jenisKelamin;

    _selectedKelasId =
        (siswa?.kelas != null)
            ? _kelasList
                .firstWhere(
                  (k) => k.namaKelas == siswa!.kelas,
                  orElse: () => KelasModel(id: 0, namaKelas: '', mapel: []),
                )
                .id
            : null;

    String? namaErrorText;
    String? nisnErrorText;
    String? jenisKelaminErrorText;
    String? tanggalLahirErrorText;
    String? alamatErrorText;
    String? kelasErrorText;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: Text(siswa == null ? 'Tambah Siswa' : 'Edit Siswa'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _namaController,
                        decoration: InputDecoration(
                          labelText: 'Nama',
                          errorText: namaErrorText,
                        ),
                        onChanged: (_) {
                          if (namaErrorText != null) {
                            setState(() => namaErrorText = null);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nisnController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'NISN',
                          errorText: nisnErrorText,
                        ),
                        onChanged: (_) {
                          if (nisnErrorText != null) {
                            setState(() => nisnErrorText = null);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _jenisKelamin,
                        items: const [
                          DropdownMenuItem(
                            value: 'laki-laki',
                            child: Text('Laki-laki'),
                          ),
                          DropdownMenuItem(
                            value: 'perempuan',
                            child: Text('Perempuan'),
                          ),
                        ],
                        onChanged: (val) => setState(() => _jenisKelamin = val),
                        decoration: InputDecoration(
                          labelText: 'Jenis Kelamin',
                          errorText: jenisKelaminErrorText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _tanggalLahirController,
                        readOnly: true,
                        onTap: () => _selectTanggalLahir(context),
                        decoration: InputDecoration(
                          labelText: 'Tanggal Lahir',
                          hintText: 'YYYY-MM-DD',
                          errorText: tanggalLahirErrorText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _alamatController,
                        decoration: InputDecoration(
                          labelText: 'Alamat',
                          errorText: alamatErrorText,
                        ),
                        onChanged: (_) {
                          if (alamatErrorText != null) {
                            setState(() => alamatErrorText = null);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _selectedKelasId,
                        items:
                            _kelasList
                                .map(
                                  (kelas) => DropdownMenuItem(
                                    value: kelas.id,
                                    child: Text(kelas.namaKelas),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => _selectedKelasId = val),
                        decoration: InputDecoration(
                          labelText: 'Kelas',
                          errorText: kelasErrorText,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final nama = _namaController.text.trim();
                      final nisn = _nisnController.text.trim();
                      final tgl = _tanggalLahirController.text.trim();
                      final alamat = _alamatController.text.trim();

                      bool valid = true;

                      setState(() {
                        namaErrorText = null;
                        nisnErrorText = null;
                        jenisKelaminErrorText = null;
                        tanggalLahirErrorText = null;
                        alamatErrorText = null;
                        kelasErrorText = null;
                      });

                      if (nama.isEmpty) {
                        setState(() => namaErrorText = 'Nama wajib diisi');
                        valid = false;
                      }

                      if (nisn.isEmpty) {
                        setState(() => nisnErrorText = 'NISN wajib diisi');
                        valid = false;
                      } else if (nisn.length != 10 ||
                          int.tryParse(nisn) == null) {
                        setState(
                          () => nisnErrorText = 'NISN harus 10 digit angka',
                        );
                        valid = false;
                      } else {
                        final state = context.read<SiswaBloc>().state;
                        if (state is SiswaLoaded) {
                          final isDuplicate = state.siswaList.any(
                            (s) =>
                                s.nisn == nisn &&
                                (siswa == null || s.id != siswa.id),
                          );
                          if (isDuplicate) {
                            setState(
                              () => nisnErrorText = 'NISN sudah digunakan',
                            );
                            valid = false;
                          }
                        }
                      }

                      if (_jenisKelamin == null) {
                        setState(
                          () => jenisKelaminErrorText = 'Pilih jenis kelamin',
                        );
                        valid = false;
                      }

                      if (tgl.isEmpty) {
                        setState(
                          () =>
                              tanggalLahirErrorText =
                                  'Tanggal lahir wajib diisi',
                        );
                        valid = false;
                      }

                      if (alamat.isEmpty) {
                        setState(() => alamatErrorText = 'Alamat wajib diisi');
                        valid = false;
                      }

                      if (_selectedKelasId == null || _selectedKelasId == 0) {
                        setState(() => kelasErrorText = 'Pilih kelas');
                        valid = false;
                      }

                      if (!valid) return;

                      if (siswa == null) {
                        context.read<SiswaBloc>().add(
                          AddSiswa(
                            nama: nama,
                            nisn: nisn,
                            jenisKelamin: _jenisKelamin!,
                            tanggalLahir: tgl,
                            alamat: alamat,
                            kelasId: _selectedKelasId,
                          ),
                        );
                      } else {
                        context.read<SiswaBloc>().add(
                          UpdateSiswa(
                            id: siswa.id,
                            nama: nama,
                            nisn: nisn,
                            jenisKelamin: _jenisKelamin!,
                            tanggalLahir: tgl,
                            alamat: alamat,
                            kelasId: _selectedKelasId,
                          ),
                        );
                      }

                      Navigator.pop(ctx);
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              ),
        );
      },
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nisnController.dispose();
    _tanggalLahirController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Siswa')),
      body: BlocBuilder<SiswaBloc, SiswaState>(
        builder: (context, state) {
          if (state is SiswaLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SiswaLoaded) {
            if (state.siswaList.isEmpty) {
              return const Center(child: Text("Belum ada data siswa."));
            }
            return ListView.builder(
              itemCount: state.siswaList.length,
              itemBuilder: (ctx, index) {
                final siswa = state.siswaList[index];
                return ListTile(
                  title: Text(siswa.nama),
                  subtitle: Text(
                    '${siswa.nisn} | Kelas: ${siswa.kelas ?? "-"}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showSiswaForm(siswa: siswa),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            () => context.read<SiswaBloc>().add(
                              DeleteSiswa(siswa.id),
                            ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is SiswaError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const Center(child: Text("Tidak ada data."));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSiswaForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
