import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sihadir/data/model/kelola/kelas_model.dart';
import 'package:sihadir/data/model/kelola/mapel_model.dart';
import 'package:sihadir/presentation/mapel/bloc/mapel_bloc.dart';
import 'package:sihadir/presentation/mapel/bloc/mapel_event.dart';
import 'package:sihadir/presentation/mapel/bloc/mapel_state.dart';
import 'package:sihadir/services/kelas_service.dart';

class MapelScreen extends StatefulWidget {
  const MapelScreen({super.key});

  @override
  State<MapelScreen> createState() => _MapelScreenState();
}

class _MapelScreenState extends State<MapelScreen> {
  final TextEditingController _namaMapelController = TextEditingController();
  List<KelasModel> _kelasList = [];
  int? _selectedKelasId;

  @override
  void initState() {
    super.initState();
    context.read<MapelBloc>().add(FetchMapel());
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    final kelasService = KelasService();
    try {
      final data = await kelasService.getAllKelas();
      setState(() => _kelasList = data);
    } catch (e) {
      debugPrint("[ERROR LOAD KELAS] $e");
    }
  }

  void _showMapelForm({MapelModel? mapel}) {
    _namaMapelController.text = mapel?.namaMapel ?? '';
    _selectedKelasId = null;

    // Jika mode edit dan ada kelas
    if (mapel != null && mapel.kelas.isNotEmpty) {
      final kelas = _kelasList.firstWhere(
        (k) => k.namaKelas == mapel.kelas.first,
        orElse: () => KelasModel(id: -1, namaKelas: '', mapel: []),
      );
      if (kelas.id != -1) _selectedKelasId = kelas.id;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(mapel == null ? 'Tambah Mapel' : 'Edit Mapel'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _namaMapelController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Mapel',
                    border: OutlineInputBorder(),
                  ),
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
                  decoration: const InputDecoration(
                    labelText: 'Pilih Kelas',
                    border: OutlineInputBorder(),
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
                final nama = _namaMapelController.text.trim();
                if (nama.isEmpty || _selectedKelasId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama mapel dan kelas wajib diisi')),
                  );
                  return;
                }

                if (mapel == null) {
                  context.read<MapelBloc>().add(AddMapel(
                        namaMapel: nama,
                        kelasIds: [_selectedKelasId!],
                      ));
                } else {
                  context.read<MapelBloc>().add(UpdateMapel(
                        id: mapel.id,
                        namaMapel: nama,
                        kelasIds: [_selectedKelasId!],
                      ));
                }

                Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _namaMapelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Mapel')),
      body: BlocBuilder<MapelBloc, MapelState>(
        builder: (context, state) {
          if (state is MapelLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MapelLoaded) {
            if (state.mapel.isEmpty) {
              return const Center(child: Text("Belum ada data mapel."));
            }
            return ListView.builder(
              itemCount: state.mapel.length,
              itemBuilder: (ctx, index) {
                final mapel = state.mapel[index];
                return ListTile(
                  title: Text(mapel.namaMapel),
                  subtitle: Text('Kelas: ${mapel.kelas.join(", ")}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showMapelForm(mapel: mapel),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => context.read<MapelBloc>().add(DeleteMapel(mapel.id)),
                      )
                    ],
                  ),
                );
              },
            );
          } else if (state is MapelError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const Center(child: Text("Tidak ada data."));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMapelForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
