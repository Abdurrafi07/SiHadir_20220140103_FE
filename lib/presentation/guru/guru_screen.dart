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
      setState(() => _kelasList = data);
    } catch (e) {
      debugPrint("[ERROR LOAD KELAS] $e");
    }
  }

  void _showGuruForm({GuruModel? guru}) async {
    if (_kelasList.isEmpty) await _loadKelas();

    _nameController.text = guru?.nama ?? '';
    _emailController.text = guru?.email ?? '';
    _passwordController.clear();

    _selectedKelasId = guru?.kelasDiampu != null
        ? _kelasList.firstWhere(
            (k) => k.namaKelas == guru?.kelasDiampu,
            orElse: () => KelasModel(id: 0, namaKelas: '', mapel: []),
          ).id
        : null;

    // Error states
    String? _nameError;
    String? _emailError;
    String? _passwordError;
    String? _kelasError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(guru == null ? 'Tambah Guru' : 'Edit Guru'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      errorText: _nameError,
                    ),
                    onChanged: (_) {
                      if (_nameError != null) setState(() => _nameError = null);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: _emailError,
                    ),
                    onChanged: (_) {
                      if (_emailError != null) setState(() => _emailError = null);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: guru == null ? null : 'Kosongkan jika tidak diubah',
                      errorText: _passwordError,
                    ),
                    obscureText: true,
                    onChanged: (_) {
                      if (_passwordError != null) setState(() => _passwordError = null);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _selectedKelasId,
                    items: _kelasList
                        .map((kelas) => DropdownMenuItem<int>(
                              value: kelas.id,
                              child: Text(kelas.namaKelas),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedKelasId = val),
                    decoration: InputDecoration(
                      labelText: 'Kelas Diampu',
                      errorText: _kelasError,
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
                    _nameError = null;
                    _emailError = null;
                    _passwordError = null;
                    _kelasError = null;
                  });

                  if (nama.isEmpty) {
                    _nameError = 'Nama wajib diisi';
                    valid = false;
                  }

                  if (email.isEmpty) {
                    _emailError = 'Email wajib diisi';
                    valid = false;
                  } else {
                    final state = context.read<GuruBloc>().state;
                    if (state is GuruLoaded) {
                      final isDuplicate = state.guruList.any(
                        (g) => g.email == email && (guru == null || g.id != guru.id),
                      );
                      if (isDuplicate) {
                        _emailError = 'Email sudah digunakan';
                        valid = false;
                      }
                    }
                  }

                  if (guru == null && pass.isEmpty) {
                    _passwordError = 'Password wajib diisi';
                    valid = false;
                  }

                  if (_selectedKelasId == null || _selectedKelasId == 0) {
                    _kelasError = 'Pilih kelas yang diampu';
                    valid = false;
                  }

                  if (!valid) {
                    setState(() {});
                    return;
                  }

                  if (guru == null) {
                    context.read<GuruBloc>().add(AddGuru(
                          name: nama,
                          email: email,
                          password: pass,
                          idKelas: _selectedKelasId,
                        ));
                  } else {
                    context.read<GuruBloc>().add(UpdateGuru(
                          id: guru.id,
                          name: nama,
                          email: email,
                          password: pass.isNotEmpty ? pass : null,
                          idKelas: _selectedKelasId,
                        ));
                  }

                  Navigator.pop(ctx);
                },
                child: const Text('Simpan'),
              )
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
      appBar: AppBar(title: const Text('Data Guru')),
      body: BlocBuilder<GuruBloc, GuruState>(
        builder: (context, state) {
          if (state is GuruLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GuruLoaded) {
            if (state.guruList.isEmpty) {
              return const Center(child: Text("Belum ada data guru."));
            }
            return ListView.builder(
              itemCount: state.guruList.length,
              itemBuilder: (ctx, index) {
                final guru = state.guruList[index];
                return ListTile(
                  title: Text(guru.nama),
                  subtitle: Text('${guru.email} | Kelas: ${guru.kelasDiampu ?? "-"}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showGuruForm(guru: guru),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            context.read<GuruBloc>().add(DeleteGuru(guru.id)),
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
