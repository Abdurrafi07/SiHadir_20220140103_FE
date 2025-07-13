import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sihadir/presentation/absensi/bloc/absensi_bloc.dart';
import 'package:sihadir/presentation/absensi/bloc/absensi_event.dart';
import 'package:sihadir/presentation/absensi/bloc/absensi_state.dart';
import 'package:intl/intl.dart';

class AbsensiListScreen extends StatefulWidget {
  const AbsensiListScreen({super.key});

  @override
  State<AbsensiListScreen> createState() => _AbsensiListScreenState();
}

class _AbsensiListScreenState extends State<AbsensiListScreen> {
  String? selectedMapel;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    context.read<AbsensiBloc>().add(FetchAllAbsensi());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Absensi')),
      body: BlocConsumer<AbsensiBloc, AbsensiState>(
        listener: (context, state) {
          if (state is AbsensiSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<AbsensiBloc>().add(FetchAllAbsensi());
          } else if (state is AbsensiError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is AbsensiLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AbsensiListLoaded) {
            final data = state.absensi;

            if (data.isEmpty) {
              return Center(child: Text('Belum ada data presensi.'));
            }

            // Extract unique mapel
            final List<String> mapelList = data
                .map<String>((e) => e['jadwal']['mapel']?['nama_mapel']?.toString() ?? '-')
                .toSet()
                .toList();

            // Apply filter
            final filteredData = data.where((item) {
              final mapel = item['jadwal']['mapel']?['nama_mapel']?.toString() ?? '';
              final tanggal = item['tanggal']?.toString() ?? '';

              final mapelMatch = selectedMapel == null || selectedMapel == mapel;
              final dateMatch = selectedDate == null ||
                  tanggal == DateFormat('yyyy-MM-dd').format(selectedDate!);

              return mapelMatch && dateMatch;
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedMapel,
                        decoration: InputDecoration(labelText: 'Filter Mapel'),
                        items: mapelList
                            .map((mapel) => DropdownMenuItem<String>(
                                  value: mapel,
                                  child: Text(mapel),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedMapel = val;
                          });
                        },
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.date_range),
                        label: Text(selectedDate == null
                            ? 'Pilih Tanggal'
                            : DateFormat('dd MMM yyyy').format(selectedDate!)),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                      if (selectedDate != null || selectedMapel != null)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedDate = null;
                              selectedMapel = null;
                            });
                          },
                          icon: Icon(Icons.clear),
                          tooltip: 'Reset Filter',
                        )
                    ],
                  ),
                ),
                Expanded(
                  child: filteredData.isEmpty
                      ? Center(child: Text('Tidak ada data sesuai filter.'))
                      : ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final item = filteredData[index];
                            return Card(
                              margin: EdgeInsets.all(8),
                              child: ListTile(
                                title: Text('${item['siswa']['nama']} (${item['status']})'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tanggal: ${item['tanggal']}'),
                                    Text('Mapel: ${item['jadwal']['mapel']?['nama_mapel'] ?? '-'}'),
                                    Text('Alamat: ${item['alamat'] ?? '-'}'),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'update') {
                                      _showUpdateDialog(item['id']);
                                    } else if (value == 'delete') {
                                      _confirmDelete(item['id']);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    PopupMenuItem(value: 'update', child: Text('Edit')),
                                    PopupMenuItem(value: 'delete', child: Text('Hapus')),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          } else if (state is AbsensiError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Container();
        },
      ),
    );
  }

  void _showUpdateDialog(int id) {
    String? selectedStatus;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update Presensi'),
        content: DropdownButtonFormField<String>(
          value: selectedStatus,
          hint: Text('Pilih Status Baru'),
          items: ['hadir', 'izin', 'sakit', 'alfa'].map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (val) {
            selectedStatus = val;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedStatus != null) {
                context.read<AbsensiBloc>().add(UpdateAbsensi(
                      id: id,
                      status: selectedStatus,
                    ));
                Navigator.pop(context);
              }
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AbsensiBloc>().add(DeleteAbsensi(id));
              Navigator.pop(context);
            },
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
