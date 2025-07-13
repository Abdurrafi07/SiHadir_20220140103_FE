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


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jadwal = await _jadwalService.getAllJadwal();
      final kelas = await _kelasService.getAllKelas();
      final mapel = await _mapelService.getAllMapel();

      setState(() {
        _jadwalList = jadwal;
        _kelasList = kelas;
        _mapelList = mapel;
      });
    } catch (e) {
      debugPrint("[ERROR LOAD DATA] $e");
    }
  }

  void _showForm({JadwalModel? jadwal}) {
    int? selectedKelasId = jadwal?.kelasId;
    int? selectedMapelId = jadwal?.mapelId;
    String hari = jadwal?.hari ?? '';
    String jamMulai = jadwal?.jamMulai ?? '';
    String jamSelesai = jadwal?.jamSelesai ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(jadwal == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                DropdownButtonFormField<int>(
                  value: selectedKelasId,
                  decoration: const InputDecoration(labelText: 'Kelas'),
                  items: _kelasList.map((k) => DropdownMenuItem(
                    value: k.id,
                    child: Text(k.namaKelas),
                  )).toList(),
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
                  items: _filteredMapelList(selectedKelasId).map((m) => DropdownMenuItem(
                    value: m.id,
                    child: Text(m.namaMapel),
                  )).toList(),
                  onChanged: (val) => setState(() => selectedMapelId = val),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _hariList.contains(hari) ? hari : null,
                  decoration: const InputDecoration(labelText: 'Hari'),
                  items: _hariList.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                  onChanged: (val) => setState(() => hari = val ?? ''),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: 'Jam Mulai'),
                  controller: TextEditingController(text: jamMulai),
                  onChanged: (val) => jamMulai = val,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: 'Jam Selesai'),
                  controller: TextEditingController(text: jamSelesai),
                  onChanged: (val) => jamSelesai = val,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (selectedKelasId == null || selectedMapelId == null || hari.isEmpty || jamMulai.isEmpty || jamSelesai.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi')));
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
                Navigator.pop(ctx);
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  List<MapelModel> _filteredMapelList(int? kelasId) {
    if (kelasId == null) return [];
    final namaKelas = _kelasList.firstWhere((k) => k.id == kelasId).namaKelas;
    return _mapelList.where((mapel) => mapel.kelas.contains(namaKelas)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen Jadwal")),
      body: ListView.builder(
        itemCount: _jadwalList.length,
        itemBuilder: (ctx, index) {
          final jadwal = _jadwalList[index];
          return ListTile(
            title: Text('${jadwal.namaKelas} - ${jadwal.namaMapel}'),
            subtitle: Text('${jadwal.hari}, ${jadwal.jamMulai} - ${jadwal.jamSelesai}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showForm(jadwal: jadwal),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _jadwalService.deleteJadwal(jadwal.id);
                    _loadData();
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
