import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sihadir/presentation/absensi/absensi_sreen.dart';
import 'package:sihadir/presentation/auth/login_screen.dart';

class GuruHomeScreen extends StatefulWidget {
  const GuruHomeScreen({super.key});

  @override
  State<GuruHomeScreen> createState() => _GuruHomeScreenState();
}

class _GuruHomeScreenState extends State<GuruHomeScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String userName = 'Guru';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await _storage.read(key: 'userName');
    setState(() {
      userName = name ?? 'Guru';
    });
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _navigateToAbsensi() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PresensiScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda Guru - $userName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hai $userName 👩‍🏫\nSelamat mengajar!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuButton(
                    icon: Icons.check_circle_outline,
                    label: 'Absensi',
                    onTap: _navigateToAbsensi,
                  ),
                  // Tambahkan menu lainnya di sini jika diperlukan
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
