import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text("Bem-vindo ao Greenpy"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Center(
        child: Text("Olá, $user!\nVamos reciclar!", textAlign: TextAlign.center, style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
