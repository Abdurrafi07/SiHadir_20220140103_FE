import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sihadir/presentation/kelas/bloc/kelas_bloc.dart';
import 'package:sihadir/presentation/kelas/bloc/kelas_event.dart';
import 'package:sihadir/presentation/kelas/bloc/kelas_state.dart';

class KelasScreen extends StatefulWidget {
  const KelasScreen({super.key});

  @override
  State<KelasScreen> createState() => _KelasScreenState();
}

class _KelasScreenState extends State<KelasScreen> {
  final TextEditingController _namaKelasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<KelasBloc>().add(FetchKelas());
  }

  void showKelasForm({int? id, String? initialNama}) {
    _namaKelasController.text = initialNama ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? 'Tambah Kelas' : 'Edit Kelas'),
          content: TextFormField(
            controller: _namaKelasController,
            decoration: const InputDecoration(
              labelText: 'Nama Kelas',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
onPressed: () {
  final nama = _namaKelasController.text.trim();
  if (nama.isNotEmpty) {
    try {
      if (id == null) {
        context.read<KelasBloc>().add(AddKelas(nama));
        debugPrint("[INFO] Menambahkan kelas dengan nama: $nama");
      } else {
        context.read<KelasBloc>().add(UpdateKelas(id, nama));
        debugPrint("[INFO] Mengupdate kelas ID: $id dengan nama: $nama");
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(id == null ? 'Berhasil tambah kelas' : 'Berhasil edit kelas')),
      );
    } catch (e) {
      debugPrint("[ERROR] Gagal memproses form: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  } else {
    debugPrint("[WARNING] Form nama kelas kosong.");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nama kelas tidak boleh kosong')),
    );
  }
},

              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _namaKelasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Kelas')),
      body: BlocBuilder<KelasBloc, KelasState>(
        builder: (context, state) {
          if (state is KelasLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is KelasLoaded) {
            if (state.kelas.isEmpty) {
              return const Center(child: Text("Belum ada data kelas."));
            }
            return ListView.builder(
              itemCount: state.kelas.length,
              itemBuilder: (context, index) {
                final kelas = state.kelas[index];
                return ListTile(
                  title: Text(kelas.namaKelas),
                  subtitle: Text('Mapel: ${kelas.mapel.join(", ")}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed:
                            () => showKelasForm(
                              id: kelas.id,
                              initialNama: kelas.namaKelas,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context.read<KelasBloc>().add(DeleteKelas(kelas.id));
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is KelasError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text("Tidak ada data"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showKelasForm(), // ← Tambah kelas
        child: const Icon(Icons.add),
      ),
    );
  }
}
