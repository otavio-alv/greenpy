import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authService = AuthService();

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'EXTRATO DE ATIVIDADES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: authService.streamHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'Nenhuma atividade registrada ainda.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: docs.length,
              separatorBuilder: (context, index) => const Divider(height: 30),
              itemBuilder: (context, index) {
                final doc = docs[index].data();
                final ts = (docs[index].data()?['createdAt'] as Timestamp?);
                final date = ts != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(ts.toDate())
                    : '-';

                final type = doc['type'] ?? 'other';
                final points = doc['points'] ?? 0;
                final details = doc['details'] ?? {};

                IconData icon;
                Color iconColor;
                String title;
                String subtitle;

                if (type == 'recycle') {
                  icon = Icons.recycling;
                  iconColor = Colors.green;
                  title = 'Reciclagem registrada';
                  subtitle = _buildRecycleSubtitle(details);
                } else if (type == 'redeem') {
                  icon = Icons.shopping_bag;
                  iconColor = Colors.orange;
                  title = details['reward'] ?? 'Resgate';
                  subtitle = 'Uso de pontos • QR: ${details['qr']?.toString().substring(0, 10) ?? ''}';
                } else {
                  icon = Icons.info_outline;
                  iconColor = Colors.grey;
                  title = 'Atividade';
                  subtitle = details.toString();
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      (points >= 0 ? '+${points}' : '${points}') ,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _buildRecycleSubtitle(Map<String, dynamic> details) {
    final parts = <String>[];
    if ((details['plastic'] ?? 0) > 0) parts.add('${details['plastic']} plástico');
    if ((details['paper'] ?? 0) > 0) parts.add('${details['paper']} papel');
    if ((details['metal'] ?? 0) > 0) parts.add('${details['metal']} metal');
    if ((details['glass'] ?? 0) > 0) parts.add('${details['glass']} vidro');
    return parts.isNotEmpty ? parts.join(', ') : 'Detalhes não informados';
  }
}