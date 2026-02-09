import 'package:flutter/material.dart';
import 'simulation_screen.dart';

class RecycleScreen extends StatelessWidget {
  const RecycleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Icon(
              Icons.qr_code_scanner_rounded,
              size: 100,
              color: Colors.white,
            ),
            
            const SizedBox(height: 30),

            // Texto Explicativo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                children: [
                  Text(
                    'Como funciona?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Para registrar sua reciclagem, leve seus resíduos (Plástico, Papel, Metal ou Vidro) até o ponto de coleta Greenpy mais próximo.\n\nAo chegar lá, clique no botão abaixo para abrir a câmera e escanear o QR Code fixado no coletor.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Botão Principal de Ação
            SizedBox(
              width: double.infinity,
              height: 65,
              child: FilledButton.icon(
                onPressed: () {
                  // Navega para a tela de simulação
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimulationScreen(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.camera_alt_outlined,),
                label: const Text(
                  'ESCANEAR QR CODE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}