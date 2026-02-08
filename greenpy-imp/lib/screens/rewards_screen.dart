import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'qr_code_scan_screen.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabeçalho com Pontos
            Padding(
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: authService.streamDadosUsuario(),
                builder: (context, snapshot) {
                  int pontos = 0;
                  if (snapshot.hasData && snapshot.data!.data() != null) {
                    pontos = snapshot.data!.data()!['points'] ?? 0;
                  }

                  return Column(
                    children: [
                      const Text(
                        'SEU SALDO',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$pontos',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const Text(
                        'pontos disponíveis',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Conteúdo com fundo branco arredondado
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção de Prêmios
                    const Text(
                      'Recompensas Disponíveis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    _buildRewardCard(
                      context,
                      title: "Desconto na Conta de Luz",
                      description: "R\$ 10,00 de desconto na próxima fatura.",
                      pointsCost: 500,
                      icon: Icons.lightbulb_outline,
                      color: Colors.amber,
                    ),
                    _buildRewardCard(
                      context,
                      title: "Vale Transporte",
                      description: "1 Passagem de ônibus municipal.",
                      pointsCost: 350,
                      icon: Icons.directions_bus_filled_outlined,
                      color: Colors.blueAccent,
                    ),
                    _buildRewardCard(
                      context,
                      title: "Copo Ecológico Greenpy",
                      description: "Copo retrátil reutilizável exclusivo.",
                      pointsCost: 1000,
                      icon: Icons.local_cafe_outlined,
                      color: Colors.green,
                    ),
                    _buildRewardCard(
                      context,
                      title: "Muda de Árvore Nativa",
                      description: "Ganhe uma muda para plantar ou doar.",
                      pointsCost: 200,
                      icon: Icons.forest_outlined,
                      color: Colors.brown,
                    ),
                    
                    const SizedBox(height: 30),
                    
            // Seção de QR Code
                    const Text(
                      'Usar Pontos via QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Escanear Código QR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use seus pontos lendo um código QR em um local parceiro.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const QrCodeScanScreen(),
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.camera_alt_outlined, size: 22),
                              label: const Text(
                                'ESCANEAR QR CODE',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, {
    required String title,
    required String description,
    required int pointsCost,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$pointsCost",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "pts",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Você será redirecionado para completar o resgate desta recompensa!',
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'RESGATAR',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}