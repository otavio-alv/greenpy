import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    if (v is String) {
      final p = int.tryParse(v);
      if (p != null) return p;
      final pd = double.tryParse(v);
      if (pd != null) return pd.toInt();
    }
    return 0;
  }

  int _calculateTotalRecycled(int plastic, int paper, int metal, int glass) {
    return plastic + paper + metal + glass;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: false,
        title: const Text('Usuários', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          // Se está aguardando e não tem dados ainda
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Se tem dados, exibe independente de erro
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            // Ordena os documentos por nome localmente
            final docs = snapshot.data!.docs;
            docs.sort((a, b) {
              final nameA = (a['name'] ?? '').toString().toLowerCase();
              final nameB = (b['name'] ?? '').toString().toLowerCase();
              return nameA.compareTo(nameB);
            });

            return Column(
              children: [
                // Header com estatísticas
                Container(
                  padding: const EdgeInsets.all(24),
                  color: colorScheme.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Total de Usuários',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${docs.length}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                // Lista de usuários
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: List.generate(docs.length, (index) {
                          final data = docs[index].data();
                          final name = (data['name'] ?? '') as String;
                          final email = (data['email'] ?? '') as String;
                          final points = _toInt(data['points']);
                          final plastic = _toInt(data['plastic']);
                          final paper = _toInt(data['paper']);
                          final metal = _toInt(data['metal']);
                          final glass = _toInt(data['glass']);
                          final totalRecycled = _calculateTotalRecycled(plastic, paper, metal, glass);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header do card com nome e pontos
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: colorScheme.primary,
                                          radius: 24,
                                          child: Text(
                                            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : email.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name.isNotEmpty ? name : email,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                email,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '$points',
                                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Text(
                                              'Pontos',
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Métricas de reciclagem
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Total reciclado:',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                              ),
                                              Text(
                                                '$totalRecycled itens',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Grid de itens reciclados
                                          GridView.count(
                                            crossAxisCount: 4,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            mainAxisSpacing: 8,
                                            crossAxisSpacing: 8,
                                            childAspectRatio: 1,
                                            children: [
                                              _MetricItem(
                                                icon: Icons.shopping_bag,
                                                color: Colors.red,
                                                label: 'Plástico',
                                                value: plastic,
                                              ),
                                              _MetricItem(
                                                icon: Icons.description,
                                                color: Colors.blue,
                                                label: 'Papel',
                                                value: paper,
                                              ),
                                              _MetricItem(
                                                icon: Icons.local_drink,
                                                color: Colors.amber,
                                                label: 'Metal',
                                                value: metal,
                                              ),
                                              _MetricItem(
                                                icon: Icons.wine_bar,
                                                color: Colors.green,
                                                label: 'Vidro',
                                                value: glass,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Se não tem dados
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhum usuário encontrado.'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 8),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
