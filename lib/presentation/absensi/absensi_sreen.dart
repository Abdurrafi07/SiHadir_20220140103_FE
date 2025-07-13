import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sihadir/data/model/kelola/absensi_massal_request.dart';
import 'package:sihadir/data/model/kelola/jadwal_model.dart';
import 'package:sihadir/presentation/absensi/bloc/absensi_bloc.dart';
import 'package:sihadir/presentation/absensi/bloc/absensi_event.dart';
import 'package:sihadir/presentation/absensi/bloc/absensi_state.dart';

class PresensiScreen extends StatefulWidget {
  @override
  _PresensiScreenState createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  String selectedHari = '';
  JadwalModel? selectedJadwal;
  File? _image;
  Position? _position;
  final Map<int, String> presensiStatus = {};

  @override
  void initState() {
    super.initState();
    context.read<AbsensiBloc>().add(LoadDataAbsensi());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Presensi Massal')),
      body: BlocBuilder<AbsensiBloc, AbsensiState>(
        builder: (context, state) {
          if (state is AbsensiLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AbsensiLoaded) {
            final jadwal = state.jadwal;
            final siswa = state.siswa;

            final hariList = jadwal.map((e) => e.hari).toSet().toList();
            final mapelByHari = jadwal
                .where((e) => e.hari == selectedHari)
                .toList();

            final siswaKelas = siswa;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pilih Hari:'),
                  DropdownButton<String>(
                    value: selectedHari.isNotEmpty ? selectedHari : null,
                    hint: Text('Pilih Hari'),
                    items: hariList.map((h) => DropdownMenuItem(
                      child: Text(h),
                      value: h,
                    )).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedHari = val!;
                        selectedJadwal = null;
                      });
                    },
                  ),
                  SizedBox(height: 12),
                  Text('Pilih Mapel:'),
                  DropdownButton<JadwalModel>(
                    value: selectedJadwal,
                    hint: Text('Pilih Mapel'),
                    items: mapelByHari.map((j) => DropdownMenuItem(
                      child: Text(j.namaMapel ?? '-'),
                      value: j,
                    )).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedJadwal = val;
                      });
                    },
                  ),
                  if (selectedJadwal != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                          'Jam: ${selectedJadwal!.jamMulai} - ${selectedJadwal!.jamSelesai}'),
                    ),
                  SizedBox(height: 16),
                  Divider(),
                  Text('Daftar Siswa:'),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: siswaKelas.length,
                    itemBuilder: (context, index) {
                      final s = siswaKelas[index];
                      return ListTile(
                        title: Text(s.nama),
                        subtitle: Text('NISN: ${s.nisn}'),
                        trailing: DropdownButton<String>(
                          value: presensiStatus[s.id],
                          hint: Text('Status'),
                          items: ['hadir', 'izin', 'sakit', 'alfa'].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              presensiStatus[s.id] = val!;
                            });
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  _image != null
                      ? Image.file(_image!, height: 150)
                      : ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: Icon(Icons.camera_alt),
                          label: Text('Ambil Foto'),
                        ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _ambilLokasi,
                    icon: Icon(Icons.location_on),
                    label: Text('Ambil Lokasi'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submitAbsensi,
                    child: Text('Kirim Presensi'),
                  )
                ],
              ),
            );
          } else if (state is AbsensiSubmitting) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AbsensiSuccess) {
            return Center(child: Text(state.message));
          } else if (state is AbsensiError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Container();
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _ambilLokasi() async {
    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _position = pos;
    });
  }

  void _submitAbsensi() {
    if (selectedJadwal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pilih hari dan mapel terlebih dahulu')));
      return;
    }

    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final presensi = presensiStatus.entries.map((e) {
      return PresensiItem(
        siswaId: e.key,
        status: e.value,
      );
    }).toList();

    context.read<AbsensiBloc>().add(SubmitAbsensiMassal(
          jadwalId: selectedJadwal!.id,
          tanggal: now,
          presensi: presensi,
          fotoPath: _image?.path,
          latitude: _position?.latitude,
          longitude: _position?.longitude,
        ));
  }
}
