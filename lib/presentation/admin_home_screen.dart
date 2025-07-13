import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sihadir/core/core.dart';
import 'package:sihadir/presentation/auth/login_screen.dart';
import 'package:sihadir/presentation/guru/guru_screen.dart';
import 'package:sihadir/presentation/jadwal/jadwal_screen.dart';
import 'package:sihadir/presentation/kelas/kelas_screen.dart';
import 'package:sihadir/presentation/mapel/mapel_screen.dart';
import 'package:sihadir/presentation/siswa/siswa_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await _storage.read(key: 'userName');
    setState(() {
      userName = name ?? 'Admin';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard - $userName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.pushAndRemoveUntil(const LoginScreen(), (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Halo Admin $userName 👋\nSelamat datang di Dashboard!',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildMenuButton(
                    icon: Icons.class_,
                    label: 'Kelas',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const KelasScreen()),
                      );
                    },
                  ),
                  _buildMenuButton(
                    icon: Icons.book,
                    label: 'Mapel',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MapelScreen()),
                      );
                    },
                  ),
                  _buildMenuButton(
                    icon: Icons.schedule,
                    label: 'Jadwal',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const JadwalScreen()),
                      );
                    },
                  ),
                  _buildMenuButton(
                    icon: Icons.school,
                    label: 'Siswa',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SiswaScreen()),
                      );
                    },
                  ),
                  _buildMenuButton(
                    icon: Icons.people,
                    label: 'Guru',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GuruScreen()),
                      );
                    },
                  ),
                  _buildMenuButton(
                    icon: Icons.check_circle_outline,
                    label: 'Absensi',
                    onTap: () {
                      // TODO: Navigate to Absensi page
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: AppColors.primary.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
