import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sihadir/data/model/kelola/guru_model.dart';
import 'package:sihadir/data/model/kelola/kelas_model.dart';
import 'package:sihadir/presentation/guru/bloc/guru_bloc.dart';
import 'package:sihadir/presentation/guru/bloc/guru_event.dart';
import 'package:sihadir/presentation/guru/bloc/guru_state.dart';
import 'package:sihadir/services/kelas_service.dart';

class GuruScreen extends StatefulWidget {
  const GuruScreen({super.key});

  @override
  State<GuruScreen> createState() => _GuruScreenState();
}

class _GuruScreenState extends State<GuruScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<KelasModel> _kelasList = [];
  int? _selectedKelasId;
  String? _kelasFilter;

  @override
  void initState() {
    super.initState();
    context.read<GuruBloc>().add(FetchGuru());
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    final service = KelasService();
    try {
      final data = await service.getAllKelas();
      if (!mounted) return;
      setState(() => _kelasList = data);
    } catch (e) {
      debugPrint("[ERROR LOAD KELAS] $e");
    }
  }

  void _showGuruForm({GuruModel? guru}) async {
    if (_kelasList.isEmpty) await _loadKelas();
    if (!mounted) return;

    _nameController.text = guru?.nama ?? '';
    _emailController.text = guru?.email ?? '';
    _passwordController.clear();

    _selectedKelasId =
        guru?.kelasDiampu != null
            ? _kelasList
                .firstWhere(
                  (k) => k.namaKelas == guru?.kelasDiampu,
                  orElse: () => KelasModel(id: 0, namaKelas: '', mapel: []),
                )
                .id
            : null;

    String? nameError;
    String? emailError;
    String? passwordError;
    String? kelasError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: Text(guru == null ? 'Tambah Guru' : 'Edit Guru'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama',
                          errorText: nameError,
                        ),
                        onChanged: (_) {
                          if (nameError != null)
                            setState(() => nameError = null);
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          errorText: emailError,
                        ),
                        onChanged: (_) {
                          if (emailError != null)
                            setState(() => emailError = null);
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText:
                              guru == null
                                  ? null
                                  : 'Kosongkan jika tidak diubah',
                          errorText: passwordError,
                        ),
                        obscureText: true,
                        onChanged: (_) {
                          if (passwordError != null)
                            setState(() => passwordError = null);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _selectedKelasId,
                        items:
                            _kelasList
                                .map(
                                  (kelas) => DropdownMenuItem<int>(
                                    value: kelas.id,
                                    child: Text(kelas.namaKelas),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => _selectedKelasId = val),
                        decoration: InputDecoration(
                          labelText: 'Kelas Diampu',
                          errorText: kelasError,
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
                      final nama = _nameController.text.trim();
                      final email = _emailController.text.trim();
                      final pass = _passwordController.text.trim();

                      bool valid = true;

                      setState(() {
                        nameError = null;
                        emailError = null;
                        passwordError = null;
                        kelasError = null;
                      });

                      if (nama.isEmpty) {
                        nameError = 'Nama wajib diisi';
                        valid = false;
                      }

                      if (email.isEmpty) {
                        emailError = 'Email wajib diisi';
                        valid = false;
                      } else {
                        final state = context.read<GuruBloc>().state;
                        if (state is GuruLoaded) {
                          final isDuplicate = state.guruList.any(
                            (g) =>
                                g.email == email &&
                                (guru == null || g.id != guru.id),
                          );
                          if (isDuplicate) {
                            emailError = 'Email sudah digunakan';
                            valid = false;
                          }
                        }
                      }

                      if (guru == null && pass.isEmpty) {
                        passwordError = 'Password wajib diisi';
                        valid = false;
                      }

                      if (_selectedKelasId == null || _selectedKelasId == 0) {
                        kelasError = 'Pilih kelas yang diampu';
                        valid = false;
                      }

                      if (!valid) {
                        setState(() {});
                        return;
                      }

                      if (guru == null) {
                        context.read<GuruBloc>().add(
                          AddGuru(
                            name: nama,
                            email: email,
                            password: pass,
                            idKelas: _selectedKelasId,
                          ),
                        );
                      } else {
                        context.read<GuruBloc>().add(
                          UpdateGuru(
                            id: guru.id,
                            name: nama,
                            email: email,
                            password: pass.isNotEmpty ? pass : null,
                            idKelas: _selectedKelasId,
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Guru'),
        actions: [
          if (_kelasList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: DropdownButton<String?>(
                hint: const Text('Filter Kelas'),
                value: _kelasFilter,
                onChanged: (val) => setState(() => _kelasFilter = val),
                items: [
                  const DropdownMenuItem(value: null, child: Text("Semua")),
                  ..._kelasList.map(
                    (k) => DropdownMenuItem(
                      value: k.namaKelas,
                      child: Text(k.namaKelas),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: BlocBuilder<GuruBloc, GuruState>(
        builder: (context, state) {
          if (state is GuruLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GuruLoaded) {
            final list =
                _kelasFilter == null
                    ? state.guruList
                    : state.guruList
                        .where((g) => g.kelasDiampu == _kelasFilter)
                        .toList();

            if (list.isEmpty) {
              return const Center(child: Text("Tidak ada data guru."));
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (ctx, index) {
                final guru = list[index];
                return ListTile(
                  title: Text(guru.nama),
                  subtitle: Text(
                    '${guru.email} | Kelas: ${guru.kelasDiampu ?? "-"}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showGuruForm(guru: guru),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text('Konfirmasi Hapus'),
                                  content: Text(
                                    'Apakah Anda yakin ingin menghapus guru "${guru.nama}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        context.read<GuruBloc>().add(
                                          DeleteGuru(guru.id),
                                        );
                                        Navigator.pop(ctx);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is GuruError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const Center(child: Text("Tidak ada data."));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGuruForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
