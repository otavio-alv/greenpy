// lib/screens/account_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 
import '../services/auth_service.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Minha Conta')),

      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: authService.getDadosUsuario(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Se os dados ainda não existem no banco, evita o erro de null
          var dados = snapshot.data?.data();
          if (dados == null) return const Center(child: Text("Dados não encontrados."));

          // Formatação segura da data
          String dataFormatada = "---";
          if (dados['createdIn'] != null) {
             DateTime data = (dados['createdIn'] as Timestamp).toDate();
             dataFormatada = DateFormat('MMMM yyyy', 'pt_BR').format(data);
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: colorScheme.primary,
                  child: const Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "${dados['name']} ${dados['surname']}", 
                textAlign: TextAlign.center, 
                style: const TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold
                )
              ),

              Text(dados['email'], textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Center(child: Chip(label: Text("Membro desde $dataFormatada"))),
              const SizedBox(height: 30),
              
              // Botão de Sair
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.black),
                title: const Text('Sair'),
                onTap: () async {
                  await authService.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),

              // Botão de Excluir com tratamento de erro
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text("Excluir Conta", style: TextStyle(color: Colors.red)),
                onTap: () => _confirmarExclusao(context, authService),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tem certeza?"),
        content: const Text("Sua conta e pontos serão apagados permanentemente."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              String? erro = await authService.excluirConta();
              if (erro == "requires-recent-login") {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Por segurança, saia e entre novamente no app antes de excluir."))
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text("EXCLUIR"),
          ),
        ],
      ),
    );
  }
}