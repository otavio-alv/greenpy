import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'admin_users_screen.dart';
import 'admin_partners_screen.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key, required this.adminEmail});

  final String adminEmail;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _loading = true;
  String? _error;
  int totalPoints = 0;
  int totalRecycledItems = 0;
  int totalUsers = 0;
  int totalPartnersActive = 0;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _logout() async {
    // Mostra diálogo de confirmação
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Você deseja sair da conta de admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Fecha o diálogo
              
              // Faz o logout
              await _authService.logout();
              
              // Volta para a tela de login
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadMetrics() async {
    setState(() => _loading = true);

    final firestore = FirebaseFirestore.instance;

    try {
      final usersSnap = await firestore.collection('users').get();
      int pointsSum = 0;
      int itemsSum = 0;

      int _toInt(dynamic v) {
        if (v == null) return 0;
        if (v is int) return v;
        if (v is double) return v.toInt();
        if (v is num) return v.toInt();
        if (v is String) {
          final parsed = int.tryParse(v);
          if (parsed != null) return parsed;
          final parsedDouble = double.tryParse(v);
          if (parsedDouble != null) return parsedDouble.toInt();
        }
        return 0;
      }

      print('📊 Total de documentos em users: ${usersSnap.docs.length}');

      for (final doc in usersSnap.docs) {
        final data = doc.data();
        final points = _toInt(data['points']);
        final plastic = _toInt(data['plastic']);
        final paper = _toInt(data['paper']);
        final metal = _toInt(data['metal']);
        final glass = _toInt(data['glass']);

        print('👤 ${data['name'] ?? 'Sem nome'} - Pontos: $points, Plástico: $plastic, Papel: $paper, Metal: $metal, Vidro: $glass');

        pointsSum += points;
        itemsSum += plastic + paper + metal + glass;
      }

      print('📈 Totais: Pontos=$pointsSum, Itens=$itemsSum, Usuários=${usersSnap.docs.length}');

      int partnersCount = 0;
      try {
        final partnersSnap = await firestore.collection('partners').where('active', isEqualTo: true).get();
        partnersCount = partnersSnap.docs.length;
      } catch (e) {
        print('⚠️ Erro ao carregar parceiros: $e');
        partnersCount = 0;
      }

      setState(() {
        totalPoints = pointsSum;
        totalRecycledItems = itemsSum;
        totalUsers = usersSnap.docs.length;
        totalPartnersActive = partnersCount;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      print('❌ ERRO ao carregar métricas: $e');
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: false,
        title: AppBarTitle(colorScheme: colorScheme, nome: widget.adminEmail.split('@').first),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Sair da conta',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Mostrar erro se houver
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚠️ Erro ao carregar dados',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: TextStyle(color: Colors.red[700], fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadMetrics,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    // Top metrics row
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MetricCard(
                          icon: Icons.stacked_bar_chart,
                          title: 'Pontos totais',
                          value: '$totalPoints',
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(height: 16),
                        _MetricCard(
                          icon: Icons.recycling,
                          title: 'Itens reciclados',
                          value: '$totalRecycledItems',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _MetricCard(
                          icon: Icons.people,
                          title: 'Usuários',
                          value: '$totalUsers',
                          color: Colors.deepPurple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Small stats and actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Row(children: [const Icon(Icons.store_mall_directory, color: Colors.black54), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Parceiros ativos', style: TextStyle(fontWeight: FontWeight.w600)), Text('$totalPartnersActive')])]),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Row(children: [const Icon(Icons.history, color: Colors.black54), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Atualizado', style: TextStyle(fontWeight: FontWeight.w600)), Text('Agora')])]),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Action buttons row (uses same button visual)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GreenpySquareButton(
                          icon: Icons.business,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPartnersScreen()));
                          },
                          text: 'Parceiros',
                        ),
                        const SizedBox(width: 25),
                        GreenpySquareButton(
                          icon: Icons.people,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()));
                          },
                          text: 'Usuários', 
                        ),
                        const SizedBox(width: 25),
                        GreenpySquareButton(
                          icon: Icons.refresh,
                          onTap: _loadMetrics,
                          text: 'Atualizar',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.title, required this.value, required this.color});

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.15,
            height: 56,
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
