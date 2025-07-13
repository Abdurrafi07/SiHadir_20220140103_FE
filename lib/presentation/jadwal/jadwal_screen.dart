import 'package:flutter/material.dart';
import 'package:sihadir/data/model/kelola/jadwal_model.dart';
import 'package:sihadir/data/model/kelola/kelas_model.dart';
import 'package:sihadir/data/model/kelola/mapel_model.dart';
import 'package:sihadir/services/jadwal_service.dart';
import 'package:sihadir/services/kelas_service.dart';
import 'package:sihadir/services/mapel_service.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  final JadwalService _jadwalService = JadwalService();
  final KelasService _kelasService = KelasService();
  final MapelService _mapelService = MapelService();

  List<JadwalModel> _jadwalList = [];
  List<KelasModel> _kelasList = [];
  List<MapelModel> _mapelList = [];
  final List<String> _hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

  int? _selectedKelasId;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final jadwal = await _jadwalService.getAllJadwal();
      final kelas = await _kelasService.getAllKelas();
      final mapel = await _mapelService.getAllMapel();

      if (!mounted) return;
      setState(() {
        _jadwalList = jadwal;
        _kelasList = kelas;
        _mapelList = mapel;
        if (_kelasList.isNotEmpty) {
          _selectedKelasId ??= _kelasList.first.id;
        }
      });
    } catch (e) {
      debugPrint("[LOAD ERROR] $e");
    }
  }

  Map<String, List<JadwalModel>> _groupByHari(List<JadwalModel> list) {
    final map = {for (var h in _hariList) h: <JadwalModel>[]};

    for (var j in list) {
      if (_selectedKelasId != null && j.kelasId == _selectedKelasId) {
        map[j.hari]?.add(j);
      }
    }
    return map;
  }

  List<MapelModel> _filteredMapel(int? kelasId) {
    if (kelasId == null) return [];
    final namaKelas = _kelasList.firstWhere((k) => k.id == kelasId).namaKelas;
    return _mapelList.where((m) => m.kelas.contains(namaKelas)).toList();
  }

  Future<String?> _pickTime(BuildContext context, String initial) async {
    final parts = initial.split(":");
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 7,
      minute: int.tryParse(parts.last) ?? 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      return "$hour:$minute";
    }

    return null;
  }

  void _showForm({JadwalModel? jadwal}) {
    int? selectedKelasId = jadwal?.kelasId ?? _selectedKelasId;
    int? selectedMapelId = jadwal?.mapelId;
    String hari = jadwal?.hari ?? '';
    String jamMulai = jadwal?.jamMulai ?? '';
    String jamSelesai = jadwal?.jamSelesai ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(jadwal == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  value: selectedKelasId,
                  decoration: const InputDecoration(labelText: 'Kelas'),
                  items: _kelasList
                      .map((k) => DropdownMenuItem(
                            value: k.id,
                            child: Text(k.namaKelas),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedKelasId = val;
                      selectedMapelId = null;
                    });
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: selectedMapelId,
                  decoration: const InputDecoration(labelText: 'Mapel'),
                  items: _filteredMapel(selectedKelasId)
                      .map((m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.namaMapel),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedMapelId = val),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _hariList.contains(hari) ? hari : null,
                  decoration: const InputDecoration(labelText: 'Hari'),
                  items: _hariList
                      .map((h) => DropdownMenuItem(
                            value: h,
                            child: Text(h),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => hari = val ?? ''),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Jam Mulai'),
                  controller: TextEditingController(text: jamMulai),
                  onTap: () async {
                    final result = await _pickTime(context, jamMulai);
                    if (result != null) setState(() => jamMulai = result);
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Jam Selesai'),
                  controller: TextEditingController(text: jamSelesai),
                  onTap: () async {
                    final result = await _pickTime(context, jamSelesai);
                    if (result != null) setState(() => jamSelesai = result);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if ([selectedKelasId, selectedMapelId, hari, jamMulai, jamSelesai]
                  .any((e) => e == null || (e is String && e.trim().isEmpty))) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Semua field wajib diisi")),
                );
                return;
              }

              try {
                if (jadwal == null) {
                  await _jadwalService.createJadwal(
                    kelasId: selectedKelasId!,
                    mapelId: selectedMapelId!,
                    hari: hari,
                    jamMulai: jamMulai,
                    jamSelesai: jamSelesai,
                  );
                } else {
                  await _jadwalService.updateJadwal(
                    id: jadwal.id,
                    kelasId: selectedKelasId!,
                    mapelId: selectedMapelId!,
                    hari: hari,
                    jamMulai: jamMulai,
                    jamSelesai: jamSelesai,
                  );
                }

                if (!mounted) return;
                Navigator.pop(ctx);
                _loadAllData();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal menyimpan: $e")),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByHari(_jadwalList);

    return Scaffold(
      appBar: AppBar(title: const Text("Jadwal Pelajaran")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<int>(
              value: _selectedKelasId,
              decoration: const InputDecoration(labelText: "Pilih Kelas"),
              items: _kelasList
                  .map((k) => DropdownMenuItem(
                        value: k.id,
                        child: Text(k.namaKelas),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedKelasId = val),
            ),
          ),
          Expanded(
            child: ListView(
              children: grouped.entries.map((entry) {
                final hari = entry.key;
                final list = entry.value;

                return ExpansionTile(
                  title: Text(hari),
                  children: list.isEmpty
                      ? [const ListTile(title: Text("Tidak ada jadwal"))]
                      : list.map((j) {
                          return ListTile(
                            title: Text("${j.jamMulai} - ${j.jamSelesai}"),
                            subtitle: Text(j.namaMapel ?? "-"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showForm(jadwal: j),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await _jadwalService.deleteJadwal(j.id);
                                    if (!mounted) return;
                                    _loadAllData();
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
