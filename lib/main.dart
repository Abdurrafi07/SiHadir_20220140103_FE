import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sihadir/data/repository/auth_repository.dart';
import 'package:sihadir/presentation/auth/login/bloc/login_bloc.dart';
import 'package:sihadir/presentation/auth/login_screen.dart';
import 'package:sihadir/presentation/auth/register/bloc/register_bloc.dart';
import 'package:sihadir/presentation/kelas/bloc/kelas_bloc.dart';
import 'package:sihadir/presentation/mapel/bloc/mapel_bloc.dart';
import 'package:sihadir/services/kelas_service.dart';
import 'package:sihadir/services/mapel_service.dart';
import 'package:sihadir/services/service_http_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => LoginBloc(
                authRepository: AuthRepository(ServiceHttpClient()),
              ),
        ),

        BlocProvider(
          create:
              (context) => RegisterBloc(
                authRepository: AuthRepository(ServiceHttpClient()),
              ),
        ),

        BlocProvider(
          create: (_) => KelasBloc(KelasService()),
        ),

        BlocProvider(
          create: (_) => MapelBloc(MapelService()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
