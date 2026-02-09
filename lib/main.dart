import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_dashboard.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as configurações específicas da plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('pt_BR', null);

  // Executa o aplicativo
  runApp(const GreenpyApp());
}

/// Widget raiz do aplicativo Greenpy.
class GreenpyApp extends StatelessWidget {
  const GreenpyApp({super.key});

  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greenpy',
      debugShowCheckedModeBanner: false, 
      theme: AppTheme.lightTheme,

      // Tela inicial baseada no estado de autenticação
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Exibe carregamento enquanto verifica o estado de autenticação
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Se há usuário logado, vai para HomeScreen; caso contrário, LoginScreen
          if (snapshot.hasData) {
            final user = snapshot.data;
            final email = user?.email ?? '';
            final localPart = email.split('@').first;
            final isAdmin = localPart.toLowerCase().contains('admin');

            if (isAdmin) {
              return AdminDashboard(adminEmail: email);
            }

            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}