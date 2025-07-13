import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sihadir/core/core.dart';
import 'package:sihadir/presentation/auth/login_screen.dart';

class GuruHomeScreen extends StatefulWidget {
  const GuruHomeScreen({super.key});

  @override
  State<GuruHomeScreen> createState() => _GuruHomeScreenState();
}

class _GuruHomeScreenState extends State<GuruHomeScreen> {
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
      userName = name ?? 'Guru';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda Guru - $userName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.pushAndRemoveUntil(const LoginScreen(), (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Hai $userName 👩‍🏫\nSemangat mengajar hari ini!',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
