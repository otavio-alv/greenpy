import 'package:flutter/material.dart';

class HowToRecycleScreen extends StatelessWidget {
  const HowToRecycleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'COMO RECICLAR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 30),
            const Text(
              'GUIA PARA RECICLAR CORRETAMENTE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Passo 1
            _buildStepCard(
              stepNumber: 1,
              title: 'Separe os materiais',
              description: 'Separe seus resíduos recicláveis em categorias: plástico, papel, metal e vidro. Evite misturar materiais diferentes.',
              icon: Icons.sort,
            ),
            const SizedBox(height: 20),

            // Passo 2
            _buildStepCard(
              stepNumber: 2,
              title: 'Limpe os materiais',
              description: 'Lave os itens recicláveis para remover restos de comida ou sujeira. Materiais limpos são mais fáceis de processar.',
              icon: Icons.cleaning_services,
            ),
            const SizedBox(height: 20),

            // Passo 3
            _buildStepCard(
              stepNumber: 3,
              title: 'Leve ao ponto de coleta',
              description: 'Dirija-se a um ponto de coleta Greenpy mais próximo. Use o app para localizar os pontos disponíveis.',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 20),

            // Passo 4
            _buildStepCard(
              stepNumber: 4,
              title: 'Escanear QR Code',
              description: 'No coletor, escaneie o QR Code para registrar sua reciclagem e ganhar pontos.',
              icon: Icons.qr_code_scanner,
            ),
            const SizedBox(height: 20),

            // Dicas extras
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                children: [
                  Text(
                    'DICAS EXTRAS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    '• Não recicle materiais contaminados\n• Remova tampas e rótulos de garrafas\n• Achate caixas de papelão para economizar espaço\n• Verifique se o material é reciclável antes de descartar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$stepNumber. $title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}