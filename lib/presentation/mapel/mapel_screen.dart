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
  List<int> _selectedKelasIds = [];

  int? _filterKelasId;

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
    _selectedKelasIds = [];

    if (mapel != null) {
      for (var namaKelas in mapel.kelas) {
        final kelas = _kelasList.firstWhere(
          (k) => k.namaKelas == namaKelas,
          orElse: () => KelasModel(id: -1, namaKelas: '', mapel: []),
        );
        if (kelas.id != -1) {
          _selectedKelasIds.add(kelas.id);
        }
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(mapel == null ? 'Tambah Mapel' : 'Edit Mapel'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) => SingleChildScrollView(
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
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Pilih Kelas", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ..._kelasList.map((kelas) => CheckboxListTile(
                        value: _selectedKelasIds.contains(kelas.id),
                        title: Text(kelas.namaKelas),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (val) {
                          setStateDialog(() {
                            if (val == true) {
                              _selectedKelasIds.add(kelas.id);
                            } else {
                              _selectedKelasIds.remove(kelas.id);
                            }
                          });
                        },
                      )),
                ],
              ),
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
                if (nama.isEmpty || _selectedKelasIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama mapel dan minimal 1 kelas wajib diisi')),
                  );
                  return;
                }

                if (mapel == null) {
                  context.read<MapelBloc>().add(AddMapel(
                        namaMapel: nama,
                        kelasIds: _selectedKelasIds,
                      ));
                } else {
                  context.read<MapelBloc>().add(UpdateMapel(
                        id: mapel.id,
                        namaMapel: nama,
                        kelasIds: _selectedKelasIds,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<int?>(
              value: _filterKelasId,
              decoration: const InputDecoration(
                labelText: "Filter berdasarkan kelas",
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text("Semua Kelas"),
                ),
                ..._kelasList.map((k) => DropdownMenuItem<int?>(
                      value: k.id,
                      child: Text(k.namaKelas),
                    )),
              ],
              onChanged: (val) => setState(() => _filterKelasId = val),
            ),
          ),
          Expanded(
            child: BlocBuilder<MapelBloc, MapelState>(
              builder: (context, state) {
                if (state is MapelLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MapelLoaded) {
                  final filtered = _filterKelasId == null
                      ? state.mapel
                      : state.mapel.where((m) => m.kelas.any(
                            (nama) => _kelasList
                                .any((k) => k.id == _filterKelasId && k.namaKelas == nama),
                          ));

                  if (filtered.isEmpty) {
                    return const Center(child: Text("Belum ada data mapel."));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, index) {
                      final mapel = filtered.elementAt(index);
                      return ListTile(
                        title: Text(mapel.namaMapel),
                        subtitle: _filterKelasId == null
                            ? Text('Kelas: ${mapel.kelas.join(", ")}')
                            : null,
                        trailing: _filterKelasId == null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showMapelForm(mapel: mapel),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text("Konfirmasi"),
                                          content: Text("Yakin ingin menghapus mapel '${mapel.namaMapel}'?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: const Text("Batal"),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white,),
                                              onPressed: () {
                                                Navigator.pop(ctx); // Tutup dialog
                                                context.read<MapelBloc>().add(DeleteMapel(mapel.id));
                                              },
                                              child: const Text("Hapus"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )

                                ],
                              )
                            : null,
                      );
                    },
                  );
                } else if (state is MapelError) {
                  return Center(child: Text("Error: ${state.message}"));
                }
                return const Center(child: Text("Tidak ada data."));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _filterKelasId == null
          ? FloatingActionButton(
              onPressed: () => _showMapelForm(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
